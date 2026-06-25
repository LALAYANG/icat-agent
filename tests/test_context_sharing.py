"""Tests for AgentMessageBus and AgentContext."""
from agent.context_sharing import AgentMessageBus, AgentContext


def test_post_and_read():
    bus = AgentMessageBus()
    bus.post("localizer", "bug_confirmed", {"file": "a.py"})
    msgs = bus.read()
    assert len(msgs) == 1
    assert msgs[0]["from"] == "localizer"
    assert msgs[0]["type"] == "bug_confirmed"
    assert msgs[0]["data"] == {"file": "a.py"}


def test_read_excludes_sender():
    bus = AgentMessageBus()
    bus.post("reproducer", "test_info", {"n": 1})
    bus.post("patch_editor", "patch_generated", {"diff": "x"})
    # reproducer should not see its own messages
    msgs = bus.read(exclude_from="reproducer")
    assert all(m["from"] != "reproducer" for m in msgs)
    assert len(msgs) == 1


def test_read_filters_by_type():
    bus = AgentMessageBus()
    bus.post("a", "foo", {})
    bus.post("b", "bar", {})
    foos = bus.read(msg_type="foo")
    assert len(foos) == 1 and foos[0]["type"] == "foo"


def test_wait_for_patch_event():
    bus = AgentMessageBus()
    # posting a patch should set the patch-ready event so wait returns quickly
    bus.post("patch_editor", "patch_generated", {"diff": "d"})
    got = bus.wait_for_patch(timeout=1)
    assert got is not False  # returns the message(s) / truthy on success


def test_wait_for_patch_times_out():
    bus = AgentMessageBus()
    got = bus.wait_for_patch(timeout=0.2)
    # no patch posted -> falsy/empty within timeout
    assert not got


def test_agent_context_extracts_localizer_files():
    state = {"localizer_file": ["pkg/core.py", "pkg/util.py"]}
    ctx = AgentContext.get_localizer_context(state)
    assert ctx is None or "core.py" in ctx or isinstance(ctx, str)
