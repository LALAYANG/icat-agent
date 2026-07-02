from __future__ import annotations
import json
import re
import shlex
import time
import logging
from pathlib import Path
from typing import Any, Dict, List, Optional
from langchain_core.messages import SystemMessage, HumanMessage, ToolMessage
from .utils import DetailedLogger, create_chat_model, enable_anthropic_tool_caching, llm_text
from .docker_env import DockerEnvironment
from .context_sharing import SharedContextManager, AgentMessageBus
from .context_window import SlidingWindowManager, create_window_manager
from .prompt_loader import get_reproducer_prompt, build_plan_message
from .tools import (
    make_view_file, make_run_python, make_run_regression_tests,
    make_run_command, make_apply_patch,
    make_share_findings, make_check_findings,
)

# Import the test runner from regression_tests_tool
import sys
from pathlib import Path
_tool_lib = Path(__file__).parent.parent / "regression_tests_tool" / "lib"
if str(_tool_lib) not in sys.path:
    sys.path.insert(0, str(_tool_lib))

try:
    from test_runner import RegressionTestRunner, detect_framework, TEST_COMMANDS, convert_test_name_for_framework
    HAS_TEST_RUNNER = True
except ImportError:
    HAS_TEST_RUNNER = False
    RegressionTestRunner = None
    detect_framework = None
    TEST_COMMANDS = {}
    convert_test_name_for_framework = None


# Sentinels returned by the _run_loop sub-handlers to control the loop:
# break out (done) or continue to the next step.
_BREAK_LOOP = object()
_CONTINUE_LOOP = object()


class RegressionTestsManager:
    """
    Manages regression tests from regression_tests/tests.json.
    """

    def __init__(self, tests_file: str = "regression_tests/tests.json"):
        self.tests_file = Path(tests_file)
        self.tests_cache: Dict[str, List[str]] = {}
        self._load_tests()

    def _load_tests(self):
        """Load tests from JSON file."""
        if self.tests_file.exists():
            try:
                with open(self.tests_file, 'r') as f:
                    self.tests_cache = json.load(f)
            except json.JSONDecodeError:
                logging.warning(f"Failed to load regression tests from {self.tests_file}")
                self.tests_cache = {}
        else:
            logging.warning(f"Regression tests file not found: {self.tests_file}")
            self.tests_cache = {}

    def get_tests_for_instance(self, instance_id: str) -> List[str]:
        """Get regression tests for a specific instance."""
        return self.tests_cache.get(instance_id, [])

    def has_tests(self, instance_id: str) -> bool:
        """Check if an instance has regression tests."""
        return instance_id in self.tests_cache and len(self.tests_cache[instance_id]) > 0


class ReproducerAgent:
    """
    Intelligent Reproducer Agent that:
    - Uses LLM to generate minimal reproduction scripts
    - Runs regression tests to ensure patches don't break functionality
    - Validates reproduction via assertions and printed test output
    """

    def __init__(
        self,
        repo_path: str,
        problem: str,
        instance_id: str,
        test_cmds: List[str] = None,
        max_steps: int = 200,
        log_path: str = "reproducer_agent.log",
        log_dir: str = "logs",
        plan: Optional[str] = None,
        shared_docker_id: Optional[str] = None,
        model_name: str = "anthropic:claude-sonnet-4-20250514",
        regression_tests_file: str = "regression_tests/tests.json",
        enable_sliding_window: bool = True,  # Enable sliding window context management
        enable_prompt_caching: bool = True,  # Enable Anthropic prompt caching
        message_bus: Optional[AgentMessageBus] = None,  # Real-time inter-agent communication
        image_name: Optional[str] = None,
        last_n_observations: int = 0,
        max_cost: float = 3.0,  # Total per-instance cost cap (shared across all agents in this process)
        truncate_view: bool = False,
    ):
        self.repo_path = Path(repo_path)
        self.problem = problem
        self.instance_id = instance_id
        self.test_cmds = test_cmds or []
        self.max_steps = max_steps
        self.max_cost = max_cost
        self.plan = plan
        self.shared_docker_id = shared_docker_id
        self.model_name = model_name
        self.message_bus = message_bus  # Real-time inter-agent communication
        self.image_name = image_name
        self.truncate_view = truncate_view
        self._last_bus_check_time = 0.0  # Track when we last checked for messages
        self.enable_sliding_window = enable_sliding_window
        self.enable_prompt_caching = enable_prompt_caching

        # Docker environment
        self.docker_env = None
        self.owns_docker = False

        # Sliding window manager for context management
        self.window_manager: Optional[SlidingWindowManager] = None
        if enable_sliding_window:
            self.window_manager = create_window_manager(
                model_name=model_name,
                enable_prompt_caching=enable_prompt_caching,
                summarization_threshold=0.85,
                min_recent_turns=3,
                last_n_observations=last_n_observations,
            )

        # Logging
        self.log_path = Path(log_path)
        self.log_path.parent.mkdir(parents=True, exist_ok=True)
        with open(self.log_path, "w") as f:
            f.write(f"[ReproducerAgent] {time.ctime()}\n")

        self.detailed_log = DetailedLogger("reproducer", instance_id, log_dir=log_dir, model_name=model_name, max_cost=max_cost)
        self.logger = logging.getLogger(f"ReproducerAgent.{instance_id}")

        # Shared context
        self.shared_context = SharedContextManager.get_instance(instance_id, log_dir)

        # Regression tests manager
        self.regression_tests = RegressionTestsManager(regression_tests_file)
        self.available_regression_tests = self.regression_tests.get_tests_for_instance(instance_id)

        # Trajectory tracking - saves all steps and actions
        self.trajectory: List[Dict[str, Any]] = []
        self.log_dir = Path(log_dir)

        # Initialize model
        self.model = create_chat_model(model_name)

        # Docker-dependent tools are built once the Docker container is ready,
        # via _setup_tools() in run() (factories capture docker_env at creation).
        self.model_with_tools = None

        # Build system prompt
        self._build_system_prompt()

    def _build_system_prompt(self):
        """Build the system prompt for the reproducer agent."""
        regression_tests_info = ""
        if self.available_regression_tests:
            tests_list = "\n".join([f"  - {t}" for t in self.available_regression_tests[:10]])
            if len(self.available_regression_tests) > 10:
                tests_list += f"\n  ... and {len(self.available_regression_tests) - 10} more"
            regression_tests_info = get_reproducer_prompt(
                "regression_tests_template",
                tests_list=tests_list,
            ) or ""

        system_prompt = get_reproducer_prompt("system_prompt")
        if not system_prompt:
            raise ValueError("Missing reproducer.system_prompt in prompts.yaml")

        initial_message = get_reproducer_prompt(
            "initial_message",
            problem=self.problem,
            regression_tests_info=regression_tests_info,
        ) or ""

        # Initialize messages with sliding window if enabled
        if self.window_manager:
            self.window_manager.set_system_message(system_prompt)

            self.window_manager.set_plan_message(build_plan_message(
                get_reproducer_prompt, self.plan, initial_message,
                missing_label="reproducer.plan_injection",
            ))

            # Messages property will be computed from window manager
            self.messages = self.window_manager.get_messages()
        else:
            # Original message list (no sliding window)
            self.messages = [
                SystemMessage(content=system_prompt),
            ]
            self.messages.append(HumanMessage(content=build_plan_message(
                get_reproducer_prompt, self.plan, initial_message,
                missing_label="reproducer.plan_injection",
            )))

    # ==================== Trajectory Logging ====================

    def _log_trajectory_step(
        self,
        action: str,
        action_type: str,
        input_data: Any = None,
        output_data: Any = None,
        metadata: Dict[str, Any] = None
    ):
        """Log a step to the trajectory."""
        step = {
            "timestamp": time.strftime("%Y-%m-%d %H:%M:%S"),
            "action": action,
            "action_type": action_type,
            "input": input_data if isinstance(input_data, (str, dict, list)) else str(input_data),
            "output": output_data,
            "metadata": metadata or {}
        }
        self.trajectory.append(step)
        self.logger.debug(f"Trajectory step: {action_type}/{action}")

    def _save_trajectory(self):
        """Save the full trajectory to a JSON file."""
        traj_dir = self.log_dir / self.instance_id
        traj_dir.mkdir(parents=True, exist_ok=True)
        traj_file = traj_dir / f"{self.instance_id}_reproducer.traj.json"

        traj_data = {
            "instance_id": self.instance_id,
            "agent": "reproducer",
            "timestamp": time.strftime("%Y-%m-%d %H:%M:%S"),
            "steps": self.trajectory,
            "summary": {
                "total_steps": len(self.trajectory),
                "tool_calls": len([s for s in self.trajectory if s["action_type"] == "tool_call"]),
                "llm_calls": len([s for s in self.trajectory if s["action_type"] == "llm_call"]),
                "regression_tests_run": len([s for s in self.trajectory if s["action_type"] == "regression_test"]),
            }
        }

        with open(traj_file, "w") as f:
            json.dump(traj_data, f, indent=2, default=str)

        self.logger.info(f"Trajectory saved to {traj_file}")
        return str(traj_file)

    def _share_tool_findings(self, tool_name: str, args: dict, output: str):
        """
        Share tool findings — only update structured state, no broadcast messages.
        Communication happens via message bus (share_findings tool).
        """
        pass

    # Message types to SKIP (noisy). Everything else is injected.
    _SKIP_TYPES = {
        "test_info", "status_update",
    }

    def _inject_bus_messages(self):
        """Check message bus and inject only actionable messages into context.

        The reproducer only needs to know about: new patches to validate, localization results.
        Skips status updates and other noise.
        """
        if not self.message_bus:
            return
        new_msgs = self.message_bus.read(
            since=self._last_bus_check_time,
            exclude_from="reproducer",
        )
        if not new_msgs:
            return

        self._last_bus_check_time = time.time()

        # Filter out noisy messages, keep everything else
        actionable = [m for m in new_msgs if m["type"] not in self._SKIP_TYPES]
        if not actionable:
            self.logger.debug(f"[Reproducer] Skipped {len(new_msgs)} non-actionable bus messages")
            return

        lines = [f"[{m['from']}] {m['type']}: {str(m['data'])}" for m in actionable]
        injection = HumanMessage(content=f"[UPDATE from other agents]\n" + "\n".join(lines))
        if self.window_manager:
            self.window_manager.add_message(injection)
        else:
            self.messages.append(injection)
        self.logger.info(f"[Reproducer] Injected {len(actionable)} actionable messages (skipped {len(new_msgs) - len(actionable)})")

    # ==================== Regression Tests ====================

    def run_regression_tests(self, phase: str = "before") -> Dict[str, Any]:
        """
        Run all available regression tests using the correct test framework.

        Args:
            phase: "before" or "after" patch

        Returns:
            Dict with test results
        """
        results = {
            "phase": phase,
            "total": len(self.available_regression_tests),
            "passed": 0,
            "failed": 0,
            "errors": 0,
            "details": [],
            "framework": None,
        }

        if not self.available_regression_tests:
            self.logger.info(f"No regression tests available for {self.instance_id}")
            return results

        # Detect framework and get proper test command
        if HAS_TEST_RUNNER and detect_framework:
            framework = detect_framework(self.instance_id)
            base_cmd = TEST_COMMANDS.get(framework, TEST_COMMANDS.get("pytest", "python -m pytest -xvs"))
        else:
            # Fallback: detect based on instance_id prefix
            instance_lower = self.instance_id.lower()
            if instance_lower.startswith("django"):
                base_cmd = "./tests/runtests.py --verbosity 2 --settings=test_sqlite --parallel 1"
                framework = "django"
            elif instance_lower.startswith("sympy"):
                base_cmd = "./bin/test -C --verbose"
                framework = "sympy"
            elif instance_lower.startswith("sphinx"):
                base_cmd = "tox --current-env -epy39 -v --"
                framework = "sphinx"
            else:
                base_cmd = "python -m pytest -xvs"
                framework = "pytest"

        results["framework"] = framework
        self.logger.info(f"Running {len(self.available_regression_tests)} regression tests ({phase} patch) with {framework}")

        for test_name in self.available_regression_tests:
            try:
                # Convert dot notation to framework-specific format
                converted_name = test_name
                if convert_test_name_for_framework is not None:
                    converted_name = convert_test_name_for_framework(test_name, framework)
                # Use the correct test command for this framework
                cmd = f"cd {self.docker_env.repo_path} && {base_cmd} {converted_name} 2>&1"
                returncode, stdout, stderr = self.docker_env.run_command(cmd, timeout=120)

                if returncode == 0:
                    results["passed"] += 1
                    status = "passed"
                else:
                    results["failed"] += 1
                    status = "failed"

                test_detail = {
                    "test": test_name,
                    "status": status,
                    "exit_code": returncode,
                    "output": stdout if stdout else "",
                    "command": f"{base_cmd} {converted_name}"
                }
                results["details"].append(test_detail)

                # Log to trajectory
                self._log_trajectory_step(
                    action=f"regression_test:{phase}:{test_name}",
                    action_type="regression_test",
                    input_data={"test_name": test_name, "converted_name": converted_name, "phase": phase, "command": cmd},
                    output_data=stdout if stdout else "",
                    metadata={"exit_code": returncode, "passed": status == "passed", "framework": framework}
                )

                # Save to shared context
                self.shared_context.add_regression_test_result(
                    phase, test_name, status, stdout if stdout else ""
                )

            except Exception as e:
                results["errors"] += 1
                results["details"].append({
                    "test": test_name,
                    "status": "error",
                    "error": str(e)
                })
                self.logger.error(f"Error running test {test_name}: {e}")

        self.logger.info(
            f"Regression tests ({phase}): {results['passed']} passed, "
            f"{results['failed']} failed, {results['errors']} errors"
        )

        # Post regression test results to message bus for other agents
        if self.message_bus:
            failed_details = []
            for detail in results.get("details", []):
                if detail.get("status") in ("failed", "error"):
                    failed_details.append({
                        "test": detail.get("test", ""),
                        "status": detail.get("status", ""),
                        "exit_code": detail.get("exit_code", -1),
                        "output": detail.get("output", "")[:2000],
                    })
            self.message_bus.post("reproducer", "regression_test_results", {
                "phase": phase,
                "framework": results.get("framework", "unknown"),
                "total": results.get("passed", 0) + results.get("failed", 0) + results.get("errors", 0),
                "passed": results.get("passed", 0),
                "failed": results.get("failed", 0),
                "errors": results.get("errors", 0),
                "failed_details": failed_details,
                "summary": f"{results['passed']}P/{results['failed']}F of {results.get('passed', 0) + results.get('failed', 0)} tests ({phase} patch)",
            })

        return results

    # ==================== Main Run ====================

    def _setup_tools(self):
        """Create docker-dependent tools and bind them to the model.

        Must be called after self.docker_env is initialized (in run()). Tool
        factories capture docker_env at creation time, so they are built here
        rather than in __init__ (where docker_env is still None).
        """
        self.run_python = make_run_python(
            self.docker_env,
            trajectory_callback=self._log_trajectory_step,
            context_callback=lambda role, action, result, meta: self.shared_context.add_trajectory_step(role, action, result, meta),
        )
        self.run_test, self.register_tests = make_run_regression_tests(
            self.docker_env,
            instance_id=self.instance_id,
            available_tests=self.available_regression_tests,
            detect_framework_fn=detect_framework if HAS_TEST_RUNNER else None,
            test_commands=TEST_COMMANDS if HAS_TEST_RUNNER else None,
            convert_test_name_fn=convert_test_name_for_framework,
            trajectory_callback=self._log_trajectory_step,
            context_callback=lambda test, result, output: self.shared_context.add_regression_test_result("before", test, result, output),
            message_bus=self.message_bus,
        )
        self.view_file = make_view_file(self.docker_env, max_lines_cap=100, truncate_output=getattr(self, "truncate_view", False))
        self.run_command = make_run_command(
            self.docker_env,
            trajectory_callback=self._log_trajectory_step,
            context_callback=lambda role, action, result, meta: self.shared_context.add_trajectory_step(role, action, result, meta),
        )
        self.apply_patch = make_apply_patch(
            self.docker_env,
            message_bus=self.message_bus,
            shared_context=self.shared_context,
        )
        self.share_findings = make_share_findings(self.message_bus, agent_name="reproducer")
        self.check_findings = make_check_findings(self.message_bus, agent_name="reproducer")

        all_tools = [self.run_python, self.run_test, self.register_tests, self.view_file, self.run_command, self.apply_patch, self.share_findings, self.check_findings]
        self.model_with_tools = enable_anthropic_tool_caching(
            self.model.bind_tools(all_tools), self.model_name
        )
        self.logger.info("Tools initialized with Docker environment")

    def run(self) -> Dict[str, Any]:
        """Run the reproducer agent."""
        self.detailed_log.log_start({
            "max_steps": self.max_steps,
            "repo": str(self.repo_path),
            "instance_id": self.instance_id,
            "regression_tests_available": len(self.available_regression_tests)
        })

        # Update shared context
        self.shared_context.update_reproducer_status("in_progress")
        if self.available_regression_tests:
            self.shared_context.set_available_regression_tests(self.available_regression_tests)

        # Initialize Docker
        if self.shared_docker_id:
            self.docker_env = DockerEnvironment(self.instance_id, timeout=600, image_name=self.image_name, repo_path=str(self.repo_path))
            self.docker_env.container_id = self.shared_docker_id
            self.owns_docker = False
            self.logger.info(f"Using shared Docker container: {self.shared_docker_id[:12]}")
        else:
            self.docker_env = DockerEnvironment(self.instance_id, timeout=600, image_name=self.image_name, repo_path=str(self.repo_path))
            self.docker_env.__enter__()
            self.owns_docker = True

            if not self.docker_env.container_id:
                self.logger.error("Failed to start Docker container")
                return {
                    "reproducer_status": ["error"],
                    "reproducer_output": ["Docker container failed to start"],
                    "reproducer_script": None,
                    "done_count": 1,
                }
            self.logger.info(f"Docker container started: {self.docker_env.container_id[:12]}")

        # Build docker-dependent tools and bind them to the model now that Docker is ready.
        self._setup_tools()

        # Method-1 retrieval: seed the reproducer with how the repo's EXISTING tests
        # construct/call the code under test, so its reproduction mirrors the real
        # construction instead of inventing setup (mocks/loggers) that masks defects.
        # Repo-derived, no prompt leakage: the extraction logic is identical for every
        # instance; only the retrieved snippets differ.
        try:
            ref = self._retrieve_construction_examples()
            if ref:
                self._add_loop_message(HumanMessage(content=ref))
                self.logger.info(f"[Reproducer] Injected construction reference ({len(ref)} chars)")
            else:
                self.logger.info("[Reproducer] No construction reference retrieved")
        except Exception as e:
            self.logger.debug(f"[Reproducer] construction retrieval skipped: {e}", exc_info=True)

        try:
            return self._run_loop()
        finally:
            if self.owns_docker:
                self.docker_env.__exit__(None, None, None)
                self.logger.info("Docker container cleaned up")

    # Vendored / build dirs to skip when grepping the repo for construction examples,
    # so third-party test files (e.g. node_modules) don't drown out the repo's own tests.
    _GREP_EXCLUDES = ("--exclude-dir=node_modules --exclude-dir=.git --exclude-dir=vendor "
                      "--exclude-dir=dist --exclude-dir=build --exclude-dir=.venv "
                      "--exclude-dir=venv --exclude-dir=__pycache__ --exclude-dir=.tox "
                      "--exclude-dir=site-packages --exclude-dir=third_party --exclude-dir=target")

    def _retrieve_construction_examples(self, max_symbols: int = 18, max_snippets: int = 16) -> Optional[str]:
        """Method-1 retrieval (no prompt leakage): extract, from the repo's OWN
        existing tests, how the code under test is constructed and invoked, and
        return it as a context block to seed the reproducer.

        The same generic extraction runs for every instance; only the snippets
        differ, and they come from files the agent already has full access to
        (existing tests — NOT the hidden gold test patch). This shows the
        reproducer the repo's real object construction (e.g. a bare struct with no
        logger) so it mirrors it rather than adding scaffolding that hides defects.
        """
        env = self.docker_env
        if env is None:
            return None

        def sh(cmd: str, timeout: int = 45) -> str:
            try:
                _, out, _ = env.run_command(cmd, timeout=timeout)
                return out or ""
            except Exception:
                return ""

        # --- text context: localizer findings + plan + problem statement ---
        texts = [self.plan or "", self.problem or ""]
        try:
            lc = self.shared_context.get_localizer_context()
            if lc:
                texts.append(json.dumps(lc) if isinstance(lc, (dict, list)) else str(lc))
        except Exception:
            pass
        blob = "\n".join(texts)

        SRC_EXT = r'(?:go|py|js|jsx|ts|tsx|java|rb|rs|cc|cpp|c|h)'
        _is_src = lambda f: ("_test." not in f and "/test" not in f
                             and ".spec." not in f and not f.startswith("test"))

        # focal files named directly in the issue/plan
        focal_files = []
        for f in re.findall(r'[\w][\w./-]*\.' + SRC_EXT, blob):
            f = f.lstrip("./")
            if _is_src(f) and f not in focal_files:
                focal_files.append(f)

        # candidate symbols mentioned in the issue text (camelCase, or snake_case foo()
        text_syms = set(re.findall(r'\b([A-Za-z_][A-Za-z0-9_]*[a-z0-9][A-Z][A-Za-z0-9_]*)\b', blob))
        text_syms |= set(re.findall(r'\b([a-z_][a-z0-9_]{4,})\s*\(', blob))
        text_syms = {s for s in text_syms if 4 < len(s) < 40}

        # locate focal files by where those symbols are DEFINED (source, not tests)
        if text_syms:
            alt = "|".join(re.escape(s) for s in list(text_syms)[:20])
            out = sh("grep -rlE " + self._GREP_EXCLUDES
                     + " " + shlex.quote(r'(func|def|class|type)[^=]*\b(' + alt + r')\b')
                     + " . 2>/dev/null | grep -vE '(_test\\.|/tests?/|\\.spec\\.|test_)'"
                     + " | grep -E '\\.(go|py|js|jsx|ts|tsx|java|rb)$' | head -8")
            for f in out.splitlines():
                f = f.strip().lstrip("./")
                if f and f not in focal_files:
                    focal_files.append(f)
        focal_files = focal_files[:8]
        if not focal_files:
            return None

        # symbols DEFINED in the focal files (types / functions / receiver methods / classes)
        symbols = set(text_syms)
        for path in focal_files:
            out = sh("grep -nE '^[[:space:]]*(func|type|class|def|export ) ' "
                     + shlex.quote(path) + " 2>/dev/null | head -100", timeout=30)
            for line in out.splitlines():
                m = re.search(r'func\s*\([^)]*\*?([A-Za-z_]\w+)\s*\)\s*([A-Za-z_]\w+)', line)  # Go method
                if m:
                    symbols.add(m.group(1)); symbols.add(m.group(2)); continue
                m = re.search(r'\b(?:func|type|class|def)\s+([A-Za-z_]\w+)', line)
                if m:
                    symbols.add(m.group(1))
        symbols = [s for s in symbols if len(s) > 2][:max_symbols]
        if not symbols:
            return None
        sym_alt = "|".join(re.escape(s) for s in symbols)

        # test files referencing any focal symbol (skip vendored/dependency dirs so
        # e.g. node_modules test files don't drown out the repo's own tests)
        out = sh("grep -rlE " + self._GREP_EXCLUDES + " " + shlex.quote(sym_alt)
                 + " --include='*_test.*' --include='test_*.py' --include='*_test.py'"
                 + " --include='*.test.*' --include='*.spec.*' . 2>/dev/null | head -25", timeout=50)
        test_files = [x.strip() for x in out.splitlines() if x.strip()]
        if not test_files:
            return None
        quoted_tf = " ".join(shlex.quote(t) for t in test_files[:25])

        # construction / call sites for each symbol, with a little leading context
        snippets = []
        for sym in symbols:
            pat = r'([&(]?\b' + re.escape(sym) + r'\b[[:space:]]*[{(]|new' + re.escape(sym) + r'\b)'
            out = sh("grep -nHE -B2 " + shlex.quote(pat) + " " + quoted_tf
                     + " 2>/dev/null | head -12", timeout=45)
            for line in out.splitlines():
                s = line.rstrip()
                if not s or s.endswith("--"):
                    continue
                if s not in snippets:
                    snippets.append(s)
                if len(snippets) >= max_snippets:
                    break
            if len(snippets) >= max_snippets:
                break
        if not snippets:
            return None

        return (
            "CONSTRUCTION REFERENCE — retrieved from THIS repository's EXISTING tests.\n"
            "Below is how the repo's own tests construct and invoke the code under test. When you "
            "write your reproduction, build and call the objects the SAME way these tests do "
            "(same constructors, same literals, same zero values). Do NOT add initialization, fakes, "
            "mocks, or dependencies these tests omit — such scaffolding can hide a real defect (e.g. a "
            "crash under the real construction) and make a broken patch look valid.\n\n"
            + "\n".join(snippets[:max_snippets])
        )

    def _add_loop_message(self, msg):
        """Append a message to the window manager (if enabled) or the raw list."""
        if self.window_manager:
            self.window_manager.add_message(msg)
        else:
            self.messages.append(msg)

    def _emit_progressive_nudges(self, step, has_script):
        """Phase-aware last-minute nudges (at max_steps-5 and max_steps-2).

        The wording depends on whether a reproduction script already exists:
        before it, nudge toward REPRODUCTION_SCRIPT; after, toward VALIDATION_COMPLETE.
        """
        if step == self.max_steps - 5:
            if has_script:
                txt = ("You are running low on steps. "
                       "Wrap up validation and output VALIDATION_COMPLETE: PASSED or VALIDATION_COMPLETE: FAILED now.")
            else:
                txt = ("You are running low on steps. "
                       "Start wrapping up your reproduction script now. Use REPRODUCTION_SCRIPT: and RESULT: and TEST_OUTPUT: format to submit.")
            self._add_loop_message(HumanMessage(content=txt))
        elif step == self.max_steps - 2:
            if has_script:
                txt = ("URGENT: You must finish NOW. "
                       "Output VALIDATION_COMPLETE: PASSED or VALIDATION_COMPLETE: FAILED immediately.")
            else:
                txt = ("URGENT: You must finish NOW. "
                       "Output REPRODUCTION_SCRIPT: ```python ... ``` and RESULT: and TEST_OUTPUT: immediately.")
            self._add_loop_message(HumanMessage(content=txt))

    def _handle_tool_calls(self, resp):
        """Dispatch the LLM's tool calls and track validation progress.

        Returns _BREAK_LOOP (validation passed -> done), _CONTINUE_LOOP
        (normal turn, or waiting on a patch), or None if there were no
        tool calls (caller falls through to final-output parsing).
        """
        if not getattr(resp, "tool_calls", None):
            return None
        tool_msgs = []
        for call in resp.tool_calls:
            tool_fn = {
                self.run_python.name: self.run_python,
                self.run_test.name: self.run_test,
                self.register_tests.name: self.register_tests,
                self.view_file.name: self.view_file,
                self.run_command.name: self.run_command,
                self.apply_patch.name: self.apply_patch,
                self.share_findings.name: self.share_findings,
                self.check_findings.name: self.check_findings,
            }.get(call["name"])

            if tool_fn:
                try:
                    out = tool_fn.invoke(call["args"])
                    self.detailed_log.log_tool_call(call["name"], call["args"], out)
                    self.logger.info(f"Tool {call['name']} called with {call['args']}")
                    tool_msgs.append(ToolMessage(f"OBSERVATION:\n{out}", tool_call_id=call["id"]))

                    # Track validation progress for auto-exit
                    if call["name"] == "apply_patch" and "successfully" in out.lower():
                        self._patch_applied = True
                        self._tests_run_after_patch = False  # reset — need new tests
                        self._findings_shared_after_patch = False
                    elif call["name"] == "run_python" and self._patch_applied:
                        self._tests_run_after_patch = True
                        self._last_reproduction_script = call["args"].get("code", "")
                    elif call["name"] == "run_regression_tests" and self._patch_applied:
                        self._tests_run_after_patch = True
                    elif call["name"] == "share_findings":
                        finding_type = call["args"].get("finding_type", "")
                        if self._patch_applied and finding_type == "validation_passed":
                            self._findings_shared_after_patch = True
                            self._validation_passed_exit = True
                        elif finding_type == "bug_confirmed" and not self._patch_applied:
                            self._bug_confirmed_via_tool = True
                        elif finding_type == "validation_failed" and self._patch_applied:
                            self._validation_failed_waiting = True

                    # REAL-TIME CONTEXT SHARING: Update shared context after relevant tool calls
                    self._share_tool_findings(call["name"], call["args"], out)
                except Exception as e:
                    error_msg = f"Tool error: {str(e)}"
                    self.logger.error(error_msg)
                    self.detailed_log.log_error(e, f"Tool {call['name']}")
                    tool_msgs.append(ToolMessage(f"OBSERVATION:\n{error_msg}", tool_call_id=call["id"]))

        # Add messages to window manager or raw list
        if self.window_manager:
            self.window_manager.add_message(resp, increment_turn=True)
            for tm in tool_msgs:
                self.window_manager.add_message(tm)
        else:
            self.messages.append(resp)
            self.messages.extend(tool_msgs)

        # Immediate exit when validation_passed was shared
        if getattr(self, '_validation_passed_exit', False):
            self.logger.info("[Reproducer] Auto-exit: validation_passed shared — stopping immediately")
            self._reproduction_result = "validated_passed"
            if not self._reproduction_script and getattr(self, '_last_reproduction_script', None):
                self._reproduction_script = self._last_reproduction_script
            if self._reproduction_script:
                self.shared_context.set_reproduction_script(self._reproduction_script)
            if self.message_bus:
                self.message_bus.post("reproducer", "validation_complete", {
                    "status": "validated_passed",
                    "script": self._reproduction_script[:2000] if self._reproduction_script else None,
                })
            return _BREAK_LOOP

        # If validation_failed was shared, wait for revised patch (no LLM calls)
        if getattr(self, '_validation_failed_waiting', False):
            self.logger.info("[Reproducer] Validation failed — waiting for revised patch (no LLM calls)...")
            patch_arrived = False
            if self.message_bus:
                patch_arrived = self.message_bus.wait_for_patch(timeout=600)
            if patch_arrived:
                self.logger.info("[Reproducer] Revised patch received!")
                # Reset state for next validation round
                self._patch_applied = False
                self._tests_run_after_patch = False
                self._findings_shared_after_patch = False
                phase_msg = HumanMessage(content=(
                    "The patch editor has revised the patch based on your feedback.\n"
                    "1. Call apply_patch() to apply the revised patch\n"
                    "2. Re-run your tests to verify\n"
                    "3. Report validation_passed or validation_failed"
                ))
                if self.window_manager:
                    self.window_manager.add_message(phase_msg)
                else:
                    self.messages.append(phase_msg)
            else:
                self.logger.warning("[Reproducer] No revised patch after 600s — continuing")
            self._validation_failed_waiting = False
            return _CONTINUE_LOOP

        # If bug_confirmed was shared via tool call, wait for patch (no LLM calls)
        if self._bug_confirmed_via_tool and not self._patch_applied:
            self.logger.info("[Reproducer] Bug confirmed via tool. Waiting for patch (no LLM calls)...")
            patch_arrived = False
            if self.message_bus:
                patch_arrived = self.message_bus.wait_for_patch(timeout=600)
            if patch_arrived:
                self.logger.info("[Reproducer] Patch received from patch editor!")
            else:
                self.logger.warning("[Reproducer] Timed out waiting for patch (600s)")
            # Inject Phase 2 message
            phase2_msg = HumanMessage(content=(
                "A patch has been generated by the patch editor. Enter PHASE 2 (patch validation).\n\n"
                "Steps:\n"
                "1. Call apply_patch() to apply the patch to YOUR container\n"
                "2. Re-run your reproduction script with run_python() to verify the fix\n"
                "3. Also re-run regression tests with run_regression_tests()\n"
                "4. Check results carefully:\n"
                "   - If ALL tests pass AND reproduction script passes: share_findings('validation_passed', '<summary>')\n"
                "   - If ANY test fails OR ANY error occurs: share_findings('validation_failed', '<details>')\n"
                "   IMPORTANT: Do NOT declare validation_passed if there are ANY errors, failures, or non-zero exit codes."
            ))
            if self.window_manager:
                self.window_manager.add_message(phase2_msg)
            else:
                self.messages.append(phase2_msg)
            self._bug_confirmed_via_tool = False  # reset so we don't wait again
            return _CONTINUE_LOOP

        # Auto-exit: only when the model explicitly posts share_findings("validation_passed", ...)
        if self._patch_applied and self._tests_run_after_patch and self._findings_shared_after_patch:
            self.logger.info("[Reproducer] Auto-exit: model posted validation_passed")
            self._reproduction_result = "validated_passed"
            # Save the last reproduction script for logging
            if not self._reproduction_script and getattr(self, '_last_reproduction_script', None):
                self._reproduction_script = self._last_reproduction_script
            if self._reproduction_script:
                self.shared_context.set_reproduction_script(self._reproduction_script)
            if self.message_bus:
                self.message_bus.post("reproducer", "validation_complete", {
                    "status": "validated_passed",
                    "script": self._reproduction_script[:2000] if self._reproduction_script else None,
                })
            return _BREAK_LOOP

        return _CONTINUE_LOOP

    def _handle_final_output(self, resp):
        """Parse a non-tool response for Phase-1 REPRODUCTION_SCRIPT/RESULT or
        Phase-2 VALIDATION_COMPLETE. Returns _BREAK_LOOP (validation passed),
        _CONTINUE_LOOP (validation failed, or bug confirmed -> wait for patch),
        or None if the response is neither (caller appends it to history).
        """
        # Check for final output
        text = llm_text(resp)

        # ── Check for REPRODUCTION_SCRIPT (Phase 1 complete → enter Phase 2) ──
        # IMPORTANT: Check this BEFORE VALIDATION_COMPLETE because the LLM
        # may include "VALIDATION_COMPLETE: PASSED or FAILED" as a description
        # of future steps alongside REPRODUCTION_SCRIPT output, which would
        # be falsely matched as an actual validation result.
        has_reproduction = "REPRODUCTION_SCRIPT:" in text or "RESULT:" in text

        # ── Check for VALIDATION_COMPLETE ──
        # Only match when it looks like an actual directive, not a description.
        # Require it to appear at the start of a line (after optional whitespace).
        validation_match = re.search(r'(?m)^\s*VALIDATION_COMPLETE:\s*(PASSED|FAILED)', text)
        # Also reject matches that look like instructions (e.g. "PASSED or FAILED")
        if validation_match and not has_reproduction:
            is_passed = validation_match.group(1).upper() == "PASSED"
            self._reproduction_result = "validated_passed" if is_passed else "validated_failed"
            self.logger.info(f"[Reproducer] Validation result: {self._reproduction_result}")

            if self.message_bus:
                self.message_bus.post("reproducer", "validation_complete", {
                    "status": self._reproduction_result,
                    "script": self._reproduction_script[:2000] if self._reproduction_script else None,
                    "detailed_output": text[-3000:],
                })

            if is_passed:
                # Only terminate on PASSED — the fix is confirmed
                return _BREAK_LOOP
            else:
                # FAILED — keep looping so the patch editor can revise.
                # Inject a message telling the LLM to wait for a revised patch.
                retry_msg = HumanMessage(content=(
                    "Validation FAILED. Your feedback has been shared with the patch editor.\n"
                    "Wait for a revised patch (you will receive a LIVE UPDATE), then call apply_patch() and re-validate.\n"
                    "When the revised patch passes, output VALIDATION_COMPLETE: PASSED. Otherwise, share the test results with others as feedback."
                ))
                if self.window_manager:
                    self.window_manager.add_message(resp, increment_turn=True)
                    self.window_manager.add_message(retry_msg)
                else:
                    self.messages.append(resp)
                    self.messages.append(retry_msg)
                return _CONTINUE_LOOP

        if has_reproduction:
            # Extract reproduction script
            if "```python" in text:
                script_start = text.find("```python") + 9
                script_end = text.find("```", script_start)
                if script_end > script_start:
                    self._reproduction_script = text[script_start:script_end].strip()

            # Extract result
            if "RESULT:" in text:
                result_line = text.split("RESULT:")[1].split("\n")[0].strip()
                if "REPRODUCED" in result_line.upper():
                    self._reproduction_result = "reproduced" if "NOT" not in result_line.upper() else "not_reproduced"
                elif "ERROR" in result_line.upper():
                    self._reproduction_result = "error"
                else:
                    self._reproduction_result = result_line.lower()

            # Extract test output (printed results from the script)
            reproduction_test_output = ""
            if "TEST_OUTPUT:" in text:
                reproduction_test_output = text.split("TEST_OUTPUT:")[1].strip()
                # Trim to first section boundary or end
                for boundary in ["REPRODUCTION_SCRIPT:", "VALIDATION_COMPLETE:"]:
                    if boundary in reproduction_test_output:
                        reproduction_test_output = reproduction_test_output[:reproduction_test_output.find(boundary)].strip()

            # Share bug confirmation and test info with other agents
            if self.message_bus:
                bug_data = {
                    "status": self._reproduction_result or "unknown",
                    "script": self._reproduction_script,
                    "test_output": reproduction_test_output or text,
                }
                self.message_bus.post("reproducer", "bug_confirmed", bug_data)
                if self._reproduction_script:
                    self.message_bus.post("reproducer", "test_info", {
                        "reproduction_script": self._reproduction_script[:2000],
                        "result": self._reproduction_result,
                        "test_output": reproduction_test_output or text[-3000:],
                        "regression_tests": self.available_regression_tests[:10],
                    })

            # Phase 2: Wait for patch WITHOUT calling the LLM.
            # Uses threading.Event — blocks with zero cost until patch_generated arrives.
            self.logger.info("[Reproducer] Bug confirmed. Waiting for patch from patch editor (no LLM calls)...")
            if self.window_manager:
                self.window_manager.add_message(resp, increment_turn=True)
            else:
                self.messages.append(resp)

            patch_arrived = False
            if self.message_bus:
                patch_arrived = self.message_bus.wait_for_patch(timeout=600)

            if patch_arrived:
                self.logger.info("[Reproducer] Patch received from patch editor!")
            else:
                self.logger.warning("[Reproducer] Timed out waiting for patch (600s)")

            # Now inject Phase 2 message and resume LLM loop
            phase2_msg = HumanMessage(content=(
                "A patch has been generated by the patch editor. Enter PHASE 2 (patch validation).\n\n"
                "Steps:\n"
                "1. Call apply_patch() to apply the patch to YOUR container\n"
                "2. Re-run your reproduction script with run_python() to verify the fix\n"
                "3. Also re-run regression tests with run_regression_tests()\n"
                "4. Check results carefully:\n"
                "   - If ALL tests pass AND reproduction script passes: share_findings('validation_passed', '<summary>')\n"
                "   - If ANY test fails OR ANY error occurs: share_findings('validation_failed', '<details>')\n"
                "   IMPORTANT: Do NOT declare validation_passed if there are ANY errors, failures, or non-zero exit codes.\n"
                "Do NOT output REPRODUCTION_SCRIPT again. Focus on validating the patch."
            ))
            if self.window_manager:
                self.window_manager.add_message(phase2_msg)
            else:
                self.messages.append(phase2_msg)
            return _CONTINUE_LOOP
        return None

    def _run_loop(self) -> Dict[str, Any]:
        """Internal run loop with step limit enforcement.
        After confirming the bug, stays alive to validate patches from the editor.
        """
        self._reproduction_script = None
        self._reproduction_result = None

        # Auto-exit tracking: detect when validation is complete without magic strings
        self._patch_applied = False
        self._tests_run_after_patch = False
        self._findings_shared_after_patch = False
        self._bug_confirmed_via_tool = False
        self._validation_passed_exit = False
        self._last_reproduction_script = None

        # Step budget milestones (25/50/75/90%)
        milestones = {int(self.max_steps * f): int(f * 100) for f in (0.25, 0.50, 0.75, 0.90)}

        step = 0
        while step < self.max_steps:
            step += 1
            self.logger.info(f"Step {step}/{self.max_steps}")

            # Step budget reminders
            if step in milestones:
                self._add_loop_message(HumanMessage(content=(
                    f"This is step {step} ({milestones[step]}%), you still have "
                    f"{self.max_steps - step} remaining steps before submission."
                )))

            # Auto-inject messages from other agents every step (N=1)
            self._inject_bus_messages()

            # Progressive (last-minute) nudges to encourage submission
            self._emit_progressive_nudges(step, self._reproduction_script is not None)

            # Log sliding window stats if enabled
            if self.window_manager:
                window_stats = self.window_manager.get_token_usage()
                self.logger.debug(
                    f"Context window: {window_stats['total_tokens']}/{window_stats['max_tokens']} tokens "
                    f"({window_stats['utilization_pct']}%)"
                )

            # Get current messages (from window manager if enabled)
            current_messages = self.window_manager.get_messages() if self.window_manager else self.messages

            # Build prompt_text for logging
            if step == 1:
                prompt_text = "\n".join([f"[{m.type}]: {m.content}" for m in current_messages])
            else:
                last_msg = current_messages[-1]
                prompt_text = f"[{last_msg.type}]: {last_msg.content}"

            # Log prompt BEFORE calling LLM (so it's captured even on failure)
            self.detailed_log.logger.info(
                f"\n{'='*60}\n[reproducer] Step {step} SENDING PROMPT ({len(current_messages)} msgs)\n{'='*60}\n{prompt_text}\n{'='*60}"
            )

            try:
                from .base_agent import BaseAgent
                current_messages = BaseAgent._sanitize_messages(current_messages)
                resp = self.model_with_tools.invoke(current_messages)

                # Log interaction
                response_text = llm_text(resp)
                self.detailed_log.log_llm_call(prompt_text, response_text, {"step": step}, raw_response=resp)

                # Log to trajectory (full content, no truncation)
                self._log_trajectory_step(
                    action=f"llm_call_step_{step}",
                    action_type="llm_call",
                    input_data={"messages_count": len(current_messages), "last_message": prompt_text},
                    output_data=response_text,
                    metadata={"step": step, "has_tool_calls": bool(getattr(resp, "tool_calls", None))}
                )

                # Check cost limit
                if self.detailed_log.should_stop():
                    self.logger.warning(f"Cost limit exceeded at step {step}, stopping early")
                    break

            except Exception as e:
                self.logger.error(f"LLM call failed: {e}")
                self.detailed_log.log_error(e, f"Step {step}")
                self._log_trajectory_step(
                    action=f"llm_error_step_{step}",
                    action_type="error",
                    input_data=None,
                    output_data=str(e),
                    metadata={"step": step}
                )
                break

            # Handle tool calls (dispatch + validation handshake).
            tc = self._handle_tool_calls(resp)
            if tc is _BREAK_LOOP:
                break
            if tc is _CONTINUE_LOOP:
                continue

            # Parse the response for a Phase-1/Phase-2 final output.
            fo = self._handle_final_output(resp)
            if fo is _BREAK_LOOP:
                break
            if fo is _CONTINUE_LOOP:
                continue

            # Add response to message history
            if self.window_manager:
                self.window_manager.add_message(resp, increment_turn=True)
            else:
                self.messages.append(resp)

        # Save to shared context
        if self._reproduction_script:
            self.shared_context.set_reproduction_script(self._reproduction_script)
        if self._reproduction_result:
            self.shared_context.set_reproduction_result(self._reproduction_result)

        self.shared_context.update_reproducer_status("completed")

        # Notify patch editor that reproducer is done (so it stops waiting)
        if self.message_bus:
            self.message_bus.post("reproducer", "reproducer_done", self._reproduction_result or "completed")

        result = {
            "reproducer_status": [self._reproduction_result or "unknown"],
            "reproducer_output": [response_text if 'response_text' in dir() else ""],
            "reproducer_script": self._reproduction_script,
            "reproducer_expected": None,
            "reproducer_actual": None,
            "regression_tests_available": len(self.available_regression_tests),
            "done_count": 1,
        }

        # Log final result to trajectory
        self._log_trajectory_step(
            action="reproduction_complete",
            action_type="result",
            input_data=None,
            output_data=self._reproduction_script,
            metadata={
                "status": self._reproduction_result,
                "script_generated": bool(self._reproduction_script),
                "patch_validated": self._reproduction_result in ("validated_passed", "validated_failed"),
                "total_steps": len(self.trajectory)
            }
        )

        # Save trajectory to file
        try:
            traj_file = self._save_trajectory()
            result["reproducer_trajectory_file"] = traj_file
        except Exception as e:
            self.logger.warning(f"Failed to save trajectory: {e}")

        self._log_window_stats_on_exit()
        self.detailed_log.log_result(result)
        self.logger.info(f"Reproduction complete: {self._reproduction_result}")
        return result

    def _log_window_stats_on_exit(self):
        """Log sliding window statistics when agent finishes."""
        if self.window_manager:
            stats = self.window_manager.get_stats()
            self.logger.info(
                f"[SlidingWindow] Final stats: "
                f"turns={stats['current_turn']}, "
                f"tokens={stats['total_tokens']}/{stats['max_tokens']} ({stats['utilization_pct']}%), "
                f"summarizations={stats['summarizations_performed']}, "
                f"tokens_saved={stats['tokens_saved']}"
            )

    # DEPRECATED (no callers as of 2026-06-24) — candidate for removal; see refactor plan.
    def run_with_regression_tests(self) -> Dict[str, Any]:
        """[DEPRECATED — no callers] Run reproducer with full regression test suite.
        This is typically called during patch validation.
        """
        # First run reproduction
        result = self.run()

        # Then run regression tests if available
        if self.available_regression_tests and self.docker_env:
            self.logger.info("Running regression tests before patch...")
            before_results = self.run_regression_tests("before")
            result["regression_tests_before"] = before_results

        return result

    # DEPRECATED (no callers as of 2026-06-24) — candidate for removal; see refactor plan.
    def _validate_patch_with_tests(self, patch_diff: str, reproduction_script: str) -> Dict[str, Any]:
        """[DEPRECATED — no callers] Validate a patch by applying the diff, running BOTH the reproduction
        script AND regression tests, and sharing detailed results.

        Args:
            patch_diff: Unified diff from the patch editor
            reproduction_script: Python script that reproduces the bug

        Returns:
            Dict with status (PASSED/FAILED/ERROR), output, reproduction, regression
        """
        import base64

        result = {"status": "ERROR", "output": "", "reproduction": None, "regression": None}

        if not self.docker_env:
            result["output"] = "Docker environment not available"
            return result

        try:
            # Check if the patch is already applied by looking at git diff.
            rc, stdout, stderr = self.docker_env.run_command(
                f"cd {self.docker_env.repo_path} && git diff --stat 2>&1", timeout=15
            )
            patch_already_applied = bool(stdout and stdout.strip())

            if not patch_already_applied:
                # Apply the diff ourselves
                encoded_diff = base64.b64encode(patch_diff.encode()).decode()
                apply_cmd = f"cd {self.docker_env.repo_path} && echo '{encoded_diff}' | base64 -d | git apply 2>&1"
                rc, stdout, stderr = self.docker_env.run_command(apply_cmd, timeout=30)
                if rc != 0:
                    result["output"] = f"Failed to apply patch: {stdout} {stderr}"
                    self.logger.warning(f"[Reproducer] Patch apply failed: {stdout}")
                    return result
                self.logger.info("[Reproducer] Patch applied via git apply")
            else:
                self.logger.info("[Reproducer] Patch already applied by editor, running tests directly")

            # ── Step 1: Run reproduction script ──
            # Scripts use assertions + print output (no exit codes).
            # If all assertions pass, rc==0. If an assertion fails, rc!=0 and
            # the traceback shows the failing assertion with actual vs expected.
            encoded_script = base64.b64encode(reproduction_script.encode()).decode()
            test_cmd = f"cd {self.docker_env.repo_path} && echo '{encoded_script}' | base64 -d | python3 2>&1 | tail -80"
            rc, stdout, stderr = self.docker_env.run_command(test_cmd, timeout=120)
            repro_output = (stdout or "") + (stderr or "")
            result["reproduction"] = {"output": repro_output[-3000:], "assertions_passed": rc == 0}

            if rc == 0:
                result["status"] = "PASSED"
                result["output"] = f"Reproduction script PASSED (all assertions passed):\n{repro_output[-1500:]}"
                self.logger.info("[Reproducer] Reproduction script PASSED after patch")
            else:
                result["status"] = "FAILED"
                result["output"] = f"Reproduction script FAILED (assertion errors):\n{repro_output[-1500:]}"
                self.logger.info(f"[Reproducer] Reproduction script FAILED after patch")

            # ── Step 2: Always run regression tests ──
            if self.available_regression_tests:
                self.logger.info("[Reproducer] Running regression tests after patch...")
                reg_results = self.run_regression_tests("after")
                result["regression"] = reg_results
                if reg_results.get("failed", 0) > 0 or reg_results.get("errors", 0) > 0:
                    reg_detail = ""
                    for detail in reg_results.get("details", []):
                        if detail.get("status") in ("failed", "error"):
                            output_text = str(detail.get('output', ''))[:1500]
                            reg_detail += f"\n  [{detail.get('status').upper()}] {detail.get('test', '?')}:\n{output_text}\n"
                    result["status"] = "FAILED"
                    result["output"] += f"\n\n=== REGRESSION TEST FAILURES ({reg_results.get('failed', 0)} failures, {reg_results.get('errors', 0)} errors) ==={reg_detail}"
            else:
                self.logger.info("[Reproducer] No regression tests available, skipping")

        except Exception as e:
            result["output"] = f"Validation error: {str(e)}"
            self.logger.error(f"[Reproducer] Patch validation error: {e}")

        return result

    # DEPRECATED (no callers as of 2026-06-24) — candidate for removal; see refactor plan.
    def validate_patch(self) -> Dict[str, Any]:
        """[DEPRECATED — no callers] Validate a patch by running reproduction test and regression tests after patch.
        Should be called after patch has been applied.
        """
        results = {
            "reproduction_after_patch": None,
            "regression_tests_after": None,
            "validation_status": "unknown"
        }

        if not self.docker_env:
            self.logger.error("Docker environment not available for validation")
            return results

        # Run reproduction test (should now pass = exit 0)
        script = self.shared_context.get_reproducer_context().get("reproduction_script")
        if script:
            escaped_code = script.replace("'", "'\"'\"'")
            cmd = f"cd {self.docker_env.repo_path} && python3 -c '{escaped_code}' 2>&1"
            returncode, stdout, stderr = self.docker_env.run_command(cmd, timeout=60)

            if returncode == 0:
                results["reproduction_after_patch"] = "fixed"
                self.logger.info("Reproduction test passed after patch (bug fixed)")
            else:
                results["reproduction_after_patch"] = "still_failing"
                self.logger.warning("Reproduction test still failing after patch")

        # Run regression tests after patch
        if self.available_regression_tests:
            self.logger.info("Running regression tests after patch...")
            after_results = self.run_regression_tests("after")
            results["regression_tests_after"] = after_results

            # Determine validation status
            if after_results["failed"] == 0 and after_results["errors"] == 0:
                if results["reproduction_after_patch"] == "fixed":
                    results["validation_status"] = "PASSED"
                else:
                    results["validation_status"] = "PARTIAL"  # Regression OK but reproduction failing
            else:
                results["validation_status"] = "FAILED"  # Regressions introduced
        else:
            # No regression tests, base only on reproduction
            if results["reproduction_after_patch"] == "fixed":
                results["validation_status"] = "PASSED"

        self.shared_context.add_trajectory_step(
            "reproducer", "validate_patch", json.dumps(results),
            {"validation_status": results["validation_status"]}
        )

        return results
