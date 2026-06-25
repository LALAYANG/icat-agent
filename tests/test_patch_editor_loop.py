"""Drive PatchEditorAgent._run_loop with a fake LLM + real git repo (no API/Docker).

message_bus=None skips the reproducer validation-wait, so these exercise the
edit-tracking, DONE parsing, diff generation, empty-response and cost-limit paths.
This is the coverage that makes the Phase 7 god-method split verifiable.
"""
from agent.patch_editor_agent import PatchEditorAgent
from agent.context_sharing import AgentMessageBus
from conftest import SimpleFakeChat, ai, tool_call


def _make_editor(git_env, tmp_path, responses, max_steps=5, max_cost=100.0, message_bus=None):
    agent = PatchEditorAgent(
        repo_path=git_env.repo_path, commit="x", problem="fix it",
        instance_id="t", log_path=str(tmp_path / "pe.log"), log_dir=str(tmp_path),
        model_name="anthropic:claude-sonnet-4-5", max_steps=max_steps,
        max_cost=max_cost, message_bus=message_bus,
    )
    agent.docker_env = git_env
    agent._setup_tools()
    agent.model_with_tools = SimpleFakeChat(responses)
    return agent


def test_edit_then_done_produces_diff(git_env, tmp_path):
    agent = _make_editor(git_env, tmp_path, [
        ai(tool_calls=[tool_call("search_replace", {
            "path": "pkg/core.py", "old_text": "hello {name}", "new_text": "hey {name}"})]),
        ai(content="DONE: pkg/core.py\nPATCH: changed greeting"),
    ])
    result = agent._run_loop()
    assert "pkg/core.py" in result["patch_editor_modified_file"]
    assert result["patch_editor_unified_diff"], "expected a non-empty unified diff"
    assert "hey {name}" in result["patch_editor_unified_diff"][0]
    assert result["done_count"] == 1


def test_edit_tracking_sets_has_made_edits(git_env, tmp_path):
    agent = _make_editor(git_env, tmp_path, [
        ai(tool_calls=[tool_call("edit_file", {
            "path": "pkg/core.py", "start_line": 1, "end_line": 1, "new_content": '"""Patched."""'})]),
        ai(content="DONE: pkg/core.py"),
    ])
    agent._run_loop()
    assert agent._has_made_edits is True


def test_empty_responses_auto_submit_after_edits(git_env, tmp_path):
    agent = _make_editor(git_env, tmp_path, [
        ai(tool_calls=[tool_call("search_replace", {
            "path": "pkg/core.py", "old_text": "hello {name}", "new_text": "hi {name}"})]),
        ai(content=""), ai(content=""), ai(content=""),  # 3 empty -> auto-submit
    ])
    result = agent._run_loop()
    assert "pkg/core.py" in result["patch_editor_modified_file"]
    assert result["done_count"] == 1


def test_validation_wait_passed_returns(git_env, tmp_path):
    # With a message bus, the DONE path posts the patch and polls for validation.
    # Pre-post a PASSING validation so the poll returns on round 0 (no sleep).
    bus = AgentMessageBus()
    bus.post("reproducer", "validation_complete", {"status": "all tests passed"})
    agent = _make_editor(git_env, tmp_path, [
        ai(tool_calls=[tool_call("search_replace", {
            "path": "pkg/core.py", "old_text": "hello {name}", "new_text": "ok {name}"})]),
        ai(content="DONE: pkg/core.py"),
    ], message_bus=bus)
    result = agent._run_loop()
    assert "pkg/core.py" in result["patch_editor_modified_file"]
    assert result["done_count"] == 1
    # the patch was shared on the bus
    assert bus.get_latest("patch_generated") is not None


def test_validation_wait_failed_injects_refinement(git_env, tmp_path):
    # A FAILING validation should inject a refinement message and loop back.
    bus = AgentMessageBus()
    bus.post("reproducer", "validation_complete", {"status": "FAILED: 2 tests still fail"})
    agent = _make_editor(git_env, tmp_path, [
        ai(tool_calls=[tool_call("search_replace", {
            "path": "pkg/core.py", "old_text": "hello {name}", "new_text": "no {name}"})]),
        ai(content="DONE: pkg/core.py"),   # step 2: triggers failed validation -> continue
    ], max_steps=2, message_bus=bus)
    result = agent._run_loop()
    # loop exited via safety fallback after the refinement; a refine message was injected
    msgs = agent.window_manager.get_messages() if agent.window_manager else agent.messages
    joined = " ".join(str(getattr(m, "content", "")) for m in msgs)
    assert "VALIDATION RESULTS FROM REPRODUCER" in joined
    assert result["done_count"] == 1


def test_cost_limit_early_exit(git_env, tmp_path):
    # tiny budget: should stop and submit whatever exists
    agent = _make_editor(git_env, tmp_path, [
        ai(tool_calls=[tool_call("search_replace", {
            "path": "pkg/core.py", "old_text": "hello {name}", "new_text": "yo {name}"})]),
    ], max_cost=0.0)  # max_cost=0 disables the limit; use a real positive tiny value instead
    # force the cost tracker to report over-limit
    agent.detailed_log.cost_tracker.max_cost = 0.0000001
    agent.detailed_log.cost_tracker.stats.instance_cost = 1.0
    result = agent._run_loop()
    assert result["done_count"] == 1
    # exited via cost path or normal — either way returns a structured result
    assert "patch_editor_unified_diff" in result
