"""Tests for prompt_loader: rendering + build_plan_message."""
import pytest

from agent.prompt_loader import build_plan_message, get_loader, get_patch_editor_prompt


def test_render_template_jinja():
    loader = get_loader()
    out = loader.render_template("Hello {{ name }}!", name="world")
    assert out == "Hello world!"


def test_get_prompt_known_agent():
    # patch_editor.system_prompt exists in prompts.yaml
    assert get_patch_editor_prompt("system_prompt")


def test_get_prompt_unknown_returns_none():
    assert get_patch_editor_prompt("does_not_exist_key_xyz") is None


# ---------------- build_plan_message ----------------
def _getter(mapping):
    """A fake get_prompt_fn backed by a dict of key->template-or-callable."""
    def fn(key, **kw):
        val = mapping.get(key)
        if callable(val):
            return val(**kw)
        return val
    return fn


def test_build_plan_message_valid_json_plan():
    getter = _getter({"plan_injection": lambda **kw: f"PLAN files={kw.get('files_to_modify')}"})
    out = build_plan_message(getter, '{"files_to_modify": ["a.py"]}', "INIT")
    assert out.startswith("INIT\n\n")
    assert "files=['a.py']" in out


def test_build_plan_message_malformed_falls_back_to_raw():
    calls = {}
    def getter(key, **kw):
        calls[key] = kw
        if key == "plan_injection":
            raise TypeError("simulate **bad_kwargs unpack failure")
        if key == "plan_injection_raw":
            return f"RAW {kw.get('plan')}"
        return None
    out = build_plan_message(getter, "not json{", "INIT")
    assert "RAW not json{" in out
    assert "plan_injection_raw" in calls


def test_build_plan_message_no_plan_uses_no_plan_message():
    getter = _getter({"no_plan_message": "NOPLAN"})
    out = build_plan_message(getter, None, "INIT")
    assert out == "INIT\n\nNOPLAN"


def test_build_plan_message_missing_template_raises():
    getter = _getter({"plan_injection": None, "plan_injection_raw": None})
    with pytest.raises(ValueError):
        build_plan_message(getter, '{"x": 1}', "INIT", missing_label="role.plan_injection")
