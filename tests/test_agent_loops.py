"""Drive an agent run-loop with a fake LLM + real tools (LocalShellEnv).

This exercises the loop machinery, tool dispatch, and final-output parsing with
no API calls and no Docker — the safety net for the run-loop refactors.
"""
from agent.localizer_agent import LocalizerAgent
from conftest import SimpleFakeChat, ai, tool_call
from agent.context_sharing import AgentMessageBus


def _make_localizer(local_env, tmp_path, responses):
    agent = LocalizerAgent(
        repo_path=local_env.repo_path, commit="x", problem="find the bug",
        instance_id="t", log_path=str(tmp_path / "loc.log"), log_dir=str(tmp_path),
        model_name="anthropic:claude-sonnet-4-5", max_steps=5,
        message_bus=AgentMessageBus(),
    )
    # Inject the fake docker + build real tools, then swap the bound model for the fake.
    agent.docker_env = local_env
    agent._setup_tools()                       # builds real tools + a real (unused) model
    agent.model_with_tools = SimpleFakeChat(responses)
    return agent


def test_localizer_loop_reaches_final_output(local_env, tmp_path):
    agent = _make_localizer(local_env, tmp_path, [
        # step 1: the LLM looks at a file (real tool runs against LocalShellEnv)
        ai(tool_calls=[tool_call("view_file", {"path": "pkg/core.py"})]),
        # step 2: the LLM emits the FINAL marker
        ai(content="FINAL: pkg/core.py\nRATIONALE: the bug is in helper()"),
    ])
    result = agent._run_loop()
    assert result["localizer_file"] == ["pkg/core.py"]
    assert "helper" in result["localizer_rationale"][0]


def test_localizer_loop_dispatches_tools(local_env, tmp_path):
    # Verify a real tool call actually executes (view_symbol returns the function body)
    captured = {}
    agent = _make_localizer(local_env, tmp_path, [
        ai(tool_calls=[tool_call("view_symbol", {"path": "pkg/core.py", "symbol_name": "helper"})]),
        ai(content="FINAL: pkg/core.py"),
    ])
    # spy on tool results via the agent's hook
    orig = agent._on_tool_result
    def spy(call, output):
        captured[call["name"]] = str(output)
        return orig(call, output)
    agent._on_tool_result = spy
    agent._run_loop()
    assert "view_symbol" in captured
    assert "def helper" in captured["view_symbol"]


def test_localizer_loop_ends_without_result_when_no_final(local_env, tmp_path):
    # No FINAL marker and no findings shared -> loop exhausts max_steps gracefully
    agent = _make_localizer(local_env, tmp_path, [
        ai(content="still thinking..."),
        ai(content="more thinking..."),
    ])
    agent.max_steps = 2
    result = agent._run_loop()
    assert result["localizer_file"] == ["(not found)"]
