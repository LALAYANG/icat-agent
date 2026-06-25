"""Tests for agent/utils.py pure helpers and CostTracker."""
import pytest
from langchain_core.messages import AIMessage

from agent.utils import (
    strip_json_fences, extract_json_object, llm_text,
    CostTracker, _global_stats, _global_stats_lock,
    InstanceCostLimitExceededError,
)
from agent.tools import _require_docker, _DOCKER_NOT_READY


@pytest.fixture(autouse=True)
def _reset_global_cost():
    """CostTracker mutates a process-global; reset it around each test."""
    with _global_stats_lock:
        _global_stats.total_cost = 0.0
        _global_stats.total_tokens_sent = 0
        _global_stats.total_tokens_received = 0
        _global_stats.total_api_calls = 0
    yield


# ---------------- strip_json_fences / extract_json_object ----------------
@pytest.mark.parametrize("text,expected", [
    ("```json\n{\"a\": 1}\n```", "{\"a\": 1}"),
    ("```\n{\"a\": 2}\n```", "{\"a\": 2}"),
    ("no fence here", "no fence here"),
    ("{\"a\": 3}", "{\"a\": 3}"),
])
def test_strip_json_fences(text, expected):
    assert strip_json_fences(text) == expected


@pytest.mark.parametrize("text,expected", [
    ('{"a": 1}', '{"a": 1}'),
    ('```json\n{"a": 1}\n```', '{"a": 1}'),
    ('prose {"a": 3, "b": [1,2]} more', '{"a": 3, "b": [1,2]}'),
    ('{"a": {"b": 1}, "c": 2}', '{"a": {"b": 1}, "c": 2}'),
    ('no json', None),
])
def test_extract_json_object(text, expected):
    assert extract_json_object(text) == expected


def test_extract_json_object_matches_legacy_inline_logic():
    """Equivalence with the old inline strip+search pattern it replaced."""
    import re
    def legacy(text):
        if "```" in text:
            m = re.search(r'```(?:json)?\s*([\s\S]*?)\s*```', text)
            if m:
                text = m.group(1).strip()
        jm = re.search(r'\{.*\}', text, re.DOTALL)
        if jm:
            text = jm.group(0)
        return text
    for inp in ['{"x":1}', '```json\n{"x":1}\n```', 'pre {"x":1} post', 'none', '```\n{"y":2}\n```']:
        new = extract_json_object(inp)
        new = new if new is not None else strip_json_fences(inp)
        assert new == legacy(inp), inp


# ---------------- llm_text ----------------
def test_llm_text_str_content():
    assert llm_text(AIMessage(content="hello")) == "hello"


def test_llm_text_list_content():
    out = llm_text(AIMessage(content=[{"type": "text", "text": "x"}]))
    assert isinstance(out, str) and "x" in out


# ---------------- _require_docker ----------------
def test_require_docker_none_returns_error():
    assert _require_docker(None) == _DOCKER_NOT_READY


def test_require_docker_present_returns_none():
    assert _require_docker(object()) is None


# ---------------- CostTracker ----------------
def _resp(input_tokens, output_tokens, cache_read=0, cache_creation=0):
    """Build a LangChain-style response with anthropic usage metadata."""
    msg = AIMessage(content="ok")
    msg.usage_metadata = {
        "input_tokens": input_tokens,
        "output_tokens": output_tokens,
        "input_token_details": {"cache_read": cache_read, "cache_creation": cache_creation},
    }
    msg.response_metadata = {"usage": {
        "input_tokens": max(0, input_tokens - cache_read - cache_creation),
        "output_tokens": output_tokens,
        "cache_read_input_tokens": cache_read,
        "cache_creation_input_tokens": cache_creation,
    }}
    return msg


def test_cost_tracker_records_cache_tokens():
    ct = CostTracker(max_cost=100.0)
    rec = ct.add_call_from_response(_resp(10000, 100, cache_read=9000), "anthropic:claude-sonnet-4-5")
    assert rec["cache_read_tokens"] == 9000


def test_cost_tracker_cache_discount():
    """A mostly-cached call should cost much less than a fully-billed one."""
    ct = CostTracker(max_cost=100.0)
    cached = ct.add_call_from_response(_resp(10000, 100, cache_read=9000), "anthropic:claude-sonnet-4-5")["cost"]
    # reset between calls via fixture isn't applied mid-test; use a fresh tracker
    ct2 = CostTracker(max_cost=100.0)
    full = ct2.add_call_from_response(_resp(10000, 100, cache_read=0), "anthropic:claude-sonnet-4-5")["cost"]
    assert cached < full


def test_cost_tracker_raises_on_limit():
    ct = CostTracker(max_cost=0.0001)  # tiny budget
    with pytest.raises(InstanceCostLimitExceededError):
        # a big call blows the budget
        ct.add_call_from_response(_resp(100000, 5000, cache_read=0), "anthropic:claude-sonnet-4-5")
