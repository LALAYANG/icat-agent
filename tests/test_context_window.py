"""Tests for SlidingWindowManager: provider cache strategy, cache_control, elision."""
import pytest
from langchain_core.messages import AIMessage, ToolMessage, HumanMessage

from agent.context_window import create_window_manager
from agent.utils import CACHE_CONTROL_MARKER


@pytest.mark.parametrize("model,expected", [
    ("anthropic:claude-sonnet-4-5", "field"),
    ("openai:gpt-5-mini", "none"),
    ("openrouter/anthropic/claude-sonnet-4.5", "marker"),
    ("openrouter/openai/gpt-5.4", "none"),
])
def test_cache_strategy_routing(model, expected):
    wm = create_window_manager(model_name=model)
    assert wm._cache_strategy() == expected


def test_cache_strategy_disabled():
    wm = create_window_manager(model_name="anthropic:claude-sonnet-4-5", enable_prompt_caching=False)
    assert wm._cache_strategy() == "none"


def _has_cache_control(msg):
    return isinstance(msg.content, list) and any(
        isinstance(b, dict) and b.get("cache_control") for b in msg.content
    )


def _has_marker(msg):
    txt = msg.content if isinstance(msg.content, str) else str(msg.content)
    return CACHE_CONTROL_MARKER in txt


def test_anthropic_messages_have_field_no_marker():
    wm = create_window_manager(model_name="anthropic:claude-sonnet-4-5")
    wm.set_system_message("SYS " * 50)
    wm.set_plan_message("PLAN " * 40)
    msgs = wm.get_messages()
    assert _has_cache_control(msgs[0]) and not _has_marker(msgs[0])
    assert _has_cache_control(msgs[1]) and not _has_marker(msgs[1])


def test_openrouter_messages_have_field_and_marker():
    wm = create_window_manager(model_name="openrouter/anthropic/claude-sonnet-4.5")
    wm.set_system_message("SYS " * 50)
    wm.set_plan_message("PLAN " * 40)
    msgs = wm.get_messages()
    assert _has_cache_control(msgs[0]) and _has_marker(msgs[0])


def test_openai_messages_plain_no_cache():
    wm = create_window_manager(model_name="openai:gpt-5-mini")
    wm.set_system_message("SYS " * 50)
    msgs = wm.get_messages()
    # OpenAI: no cache_control injection, content stays a plain string
    assert isinstance(msgs[0].content, str)
    assert not _has_marker(msgs[0])


def test_observation_elision_keeps_last_n():
    wm = create_window_manager(model_name="openai:gpt-5-mini", last_n_observations=2)
    wm.set_system_message("sys")
    wm.set_plan_message("plan")
    # add 5 tool turns
    for i in range(5):
        wm.add_message(AIMessage(content=f"call {i}", tool_calls=[{"name": "view", "args": {}, "id": f"t{i}"}]), increment_turn=True)
        wm.add_message(ToolMessage(content=f"observation {i}\n" * 10, tool_call_id=f"t{i}"))
    msgs = wm.get_messages()
    tool_msgs = [m for m in msgs if isinstance(m, ToolMessage)]
    elided = [m for m in tool_msgs if "lines omitted" in (m.content if isinstance(m.content, str) else "")]
    # 5 tool observations, keep last 2 verbatim -> 3 elided
    assert len(elided) == 3
