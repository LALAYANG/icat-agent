"""Drive ReproducerAgent._run_loop with a fake LLM + bus (no API/Docker/sleeps).

A patch is pre-posted to the bus so wait_for_patch() returns instantly, letting us
exercise the Phase-1 (reproduce) -> Phase-2 (validate) transitions and the
VALIDATION_COMPLETE paths. Coverage for the Phase 7 reproducer split.
"""
from agent.reproducer_agent import ReproducerAgent
from agent.context_sharing import AgentMessageBus
from conftest import SimpleFakeChat, ai


def _make_reproducer(local_env, tmp_path, responses, max_steps=6, message_bus=None):
    agent = ReproducerAgent(
        repo_path=local_env.repo_path, problem="bug", instance_id="t",
        log_path=str(tmp_path / "rp.log"), log_dir=str(tmp_path),
        model_name="anthropic:claude-sonnet-4-5", max_steps=max_steps,
        message_bus=message_bus, max_cost=100.0,
    )
    agent.docker_env = local_env
    agent._setup_tools()
    agent.model_with_tools = SimpleFakeChat(responses)
    return agent


def test_phase1_repro_then_phase2_validation_passed(local_env, tmp_path):
    bus = AgentMessageBus()
    bus.post("patch_editor", "patch_generated", "diff --git a b")  # wait_for_patch returns instantly
    agent = _make_reproducer(local_env, tmp_path, [
        ai(content="REPRODUCTION_SCRIPT: ```python\nprint('repro')\n```\nRESULT: REPRODUCED\nTEST_OUTPUT: ok"),
        ai(content="VALIDATION_COMPLETE: PASSED"),
    ], message_bus=bus)
    result = agent._run_loop()
    assert result["reproducer_status"] == ["validated_passed"]
    assert result["reproducer_script"] and "repro" in result["reproducer_script"]
    # bug_confirmed + validation_complete were posted to the bus
    assert bus.get_latest("bug_confirmed") is not None
    assert bus.get_latest("validation_complete") is not None


def test_validation_complete_failed_keeps_looping(local_env, tmp_path):
    bus = AgentMessageBus()
    bus.post("patch_editor", "patch_generated", "diff --git a b")
    agent = _make_reproducer(local_env, tmp_path, [
        ai(content="REPRODUCTION_SCRIPT: ```python\nprint('x')\n```\nRESULT: REPRODUCED"),
        ai(content="VALIDATION_COMPLETE: FAILED"),   # FAILED -> inject retry + continue
        ai(content="still working"),                 # exhaust remaining steps
    ], max_steps=4, message_bus=bus)
    result = agent._run_loop()
    assert result["reproducer_status"] == ["validated_failed"]


def test_reproduction_script_parsed_without_bus(local_env, tmp_path):
    # No message bus: Phase 1 still parses the script and result, no wait.
    agent = _make_reproducer(local_env, tmp_path, [
        ai(content="REPRODUCTION_SCRIPT: ```python\nassert True\n```\nRESULT: NOT REPRODUCED"),
        ai(content="done thinking"),
    ], max_steps=3, message_bus=None)
    result = agent._run_loop()
    assert result["reproducer_script"] and "assert True" in result["reproducer_script"]
    assert result["done_count"] == 1


def test_cost_limit_breaks(local_env, tmp_path):
    agent = _make_reproducer(local_env, tmp_path, [ai(content="thinking")], max_steps=5)
    agent.detailed_log.cost_tracker.max_cost = 0.0000001
    agent.detailed_log.cost_tracker.stats.instance_cost = 1.0
    result = agent._run_loop()
    assert result["done_count"] == 1
    assert "reproducer_status" in result
