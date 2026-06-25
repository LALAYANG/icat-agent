"""Shared pytest fixtures for the icat-agent test suite.

Design: avoid real Docker and real LLM calls.
- `LocalShellEnv` mimics DockerEnvironment's interface but runs the tools' real
  shell commands on the HOST against a temp repo dir. The tools issue ordinary
  unix commands (find/grep/cat/sed/test/python), so host execution gives real
  behavior with no container.
- `SimpleFakeChat` returns canned AIMessages (optionally with tool_calls) so
  agent run-loops can be exercised without API calls.
"""
from __future__ import annotations

import os
import subprocess
import sys
import textwrap
from pathlib import Path

import pytest
from langchain_core.messages import AIMessage

# Ensure tool commands that shell out to `python3` use the SAME interpreter
# pytest runs under (3.12), not whatever older python is first on the bare PATH.
_TEST_ENV = dict(os.environ)
_TEST_ENV["PATH"] = os.path.dirname(sys.executable) + os.pathsep + _TEST_ENV.get("PATH", "")


# --------------------------------------------------------------------------
# Fake Docker environment that runs commands on the host
# --------------------------------------------------------------------------
class LocalShellEnv:
    """Drop-in stand-in for DockerEnvironment.

    Implements the subset of the interface the tools use: ``repo_path``,
    ``container_id``, ``run_command`` and ``run_command_with_stdin``. Commands
    run via ``bash -c`` on the host with cwd defaulting to ``repo_path``.
    """

    def __init__(self, repo_path: str):
        self.repo_path = str(repo_path)
        self.container_id = "local-shell-fake"
        self.use_conda = False
        self.timeout = 60

    def run_command(self, command, timeout=None, workdir=None, activate_conda=True):
        try:
            r = subprocess.run(
                ["bash", "-c", command],
                cwd=workdir or self.repo_path,
                env=_TEST_ENV,
                capture_output=True, text=True,
                timeout=timeout or self.timeout,
            )
            return (r.returncode, r.stdout, r.stderr)
        except subprocess.TimeoutExpired:
            return (-1, "", f"timeout after {timeout or self.timeout}s")
        except Exception as e:  # pragma: no cover - defensive
            return (-1, "", str(e))

    def run_command_with_stdin(self, command, input_data, timeout=None, workdir=None, activate_conda=True):
        try:
            r = subprocess.run(
                ["bash", "-c", command],
                cwd=workdir or self.repo_path,
                env=_TEST_ENV,
                input=input_data, capture_output=True, text=True,
                timeout=timeout or self.timeout,
            )
            return (r.returncode, r.stdout, r.stderr)
        except Exception as e:  # pragma: no cover - defensive
            return (-1, "", str(e))


# --------------------------------------------------------------------------
# Fake chat model: canned responses, supports .bind_tools()
# --------------------------------------------------------------------------
class SimpleFakeChat:
    """Returns pre-baked AIMessages in order; empty AIMessage once exhausted.

    Pass a list of AIMessage (some may carry ``tool_calls``) to script an
    agent run-loop. ``bind_tools`` is a no-op that returns self.
    """

    def __init__(self, responses=None):
        self._responses = list(responses or [])
        self._i = 0
        self.kwargs = {}

    def bind_tools(self, tools, **kw):
        self.kwargs = {"tools": list(tools)}
        return self

    def invoke(self, messages, **kw):
        if self._i < len(self._responses):
            r = self._responses[self._i]
            self._i += 1
            return r
        return AIMessage(content="")


def ai(content="", tool_calls=None):
    """Helper to build an AIMessage with optional tool_calls."""
    return AIMessage(content=content, tool_calls=tool_calls or [])


def tool_call(name, args, call_id="call_1"):
    return {"name": name, "args": args, "id": call_id, "type": "tool_call"}


# --------------------------------------------------------------------------
# Fixtures
# --------------------------------------------------------------------------
@pytest.fixture
def sample_repo(tmp_path) -> Path:
    """A small repo tree with a Python module and a JS file."""
    (tmp_path / "pkg").mkdir()
    (tmp_path / "pkg" / "__init__.py").write_text("")
    (tmp_path / "pkg" / "core.py").write_text(textwrap.dedent('''\
        """Core module."""


        class Greeter:
            """A greeter."""

            def __init__(self, name):
                self.name = name

            def greet(self):
                return helper(self.name)


        def helper(name):
            return f"hello {name}"


        def unused():
            pass
    '''))
    (tmp_path / "app.js").write_text(textwrap.dedent('''\
        function add(a, b) {
          return a + b;
        }

        class Calc {
          mul(a, b) { return a * b; }
        }

        module.exports = { add, Calc };
    '''))
    return tmp_path


@pytest.fixture
def local_env(sample_repo) -> LocalShellEnv:
    return LocalShellEnv(str(sample_repo))


@pytest.fixture
def git_repo(sample_repo) -> Path:
    """sample_repo initialized as a git repo with one commit (so `git diff` works)."""
    for cmd in [
        "git init -q",
        "git -c user.email=t@t.io -c user.name=test add -A",
        "git -c user.email=t@t.io -c user.name=test commit -q -m init",
    ]:
        subprocess.run(["bash", "-c", cmd], cwd=sample_repo, env=_TEST_ENV, capture_output=True)
    return sample_repo


@pytest.fixture
def git_env(git_repo) -> LocalShellEnv:
    return LocalShellEnv(str(git_repo))
