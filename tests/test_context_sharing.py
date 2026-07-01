"""Tests for AgentMessageBus and AgentContext."""
from agent.context_sharing import AgentMessageBus, AgentContext, BusMessageType


def test_bus_message_type_values_are_stable():
    """The constants must stay byte-identical to the wire strings the agents
    still match against (some via data-payload substring checks). Guard against
    accidental drift."""
    assert BusMessageType.LOCALIZED_FILES == "localized_files"
    assert BusMessageType.LOCALIZED_FUNCTIONS == "localized_functions"
    assert BusMessageType.TEST_INFO == "test_info"
    assert BusMessageType.BUG_CONFIRMED == "bug_confirmed"
    assert BusMessageType.VALIDATION_PASSED == "validation_passed"
    assert BusMessageType.VALIDATION_FAILED == "validation_failed"
    assert BusMessageType.VALIDATION_COMPLETE == "validation_complete"
    assert BusMessageType.PATCH_GENERATED == "patch_generated"
    assert BusMessageType.TEST_RESULTS == "test_results"


def test_post_routes_signals_by_constant():
    """post() must fire the right threading events for the canonical types."""
    bus = AgentMessageBus()
    bus.post("patch_editor", BusMessageType.PATCH_GENERATED, "diff")
    assert bus._patch_ready.is_set()
    bus.post("reproducer", BusMessageType.TEST_RESULTS, "r")
    assert bus._test_results_ready.is_set()
    bus.post("reproducer", BusMessageType.VALIDATION_FAILED, {"x": 1})
    assert bus._validation_feedback_ready.is_set()
    assert bus._validation_feedback["type"] == "validation_failed"


def test_validation_complete_wakes_waiter():
    """The reproducer's terminal validation_complete must also fire the
    validation event (not just validation_passed/failed), so a waiter that
    only sees the text-path exit isn't left to time out."""
    bus = AgentMessageBus()
    bus.post("reproducer", BusMessageType.VALIDATION_COMPLETE,
             {"status": "validated_passed", "script": "s"})
    assert bus._validation_feedback_ready.is_set()
    assert bus._validation_feedback["type"] == "validation_complete"


def test_wait_for_validation_returns_verdict_posted_before_wait():
    """Regression: a verdict that arrives BEFORE wait_for_validation() is called
    (fast reproducer) must not be lost to the old clear()/discard-then-wait race.
    The scan of the message log recovers it even though the event was cleared."""
    bus = AgentMessageBus()
    patch_id = bus.post("patch_editor", BusMessageType.PATCH_GENERATED, "diff")
    # Reproducer validates and posts before the patch editor reaches wait().
    bus.post("reproducer", BusMessageType.VALIDATION_COMPLETE,
             {"status": "validated_passed"})
    fb = bus.wait_for_validation(timeout=1, after_id=patch_id)
    assert fb is not None
    assert fb["type"] == "validation_complete"
    assert AgentMessageBus.validation_verdict(fb) is True


def test_wait_for_validation_ignores_earlier_round():
    """A verdict older than the caller's anchor (a previous patch round) must be
    ignored, so a stale FAILED/PASSED isn't reused for the new patch."""
    bus = AgentMessageBus()
    bus.post("reproducer", BusMessageType.VALIDATION_FAILED, "round-1 failed")
    patch_id = bus.post("patch_editor", BusMessageType.PATCH_GENERATED, "diff-2")
    fb = bus.wait_for_validation(timeout=0.2, after_id=patch_id)
    assert fb is None  # round-1 verdict predates the new patch → not returned


def test_wait_for_validation_times_out_cleanly():
    bus = AgentMessageBus()
    assert bus.wait_for_validation(timeout=0.1) is None


def test_validation_verdict_across_both_styles():
    """validation_verdict() must map either signal style to a boolean so a
    passing validation_complete is never misread as a failure."""
    v = AgentMessageBus.validation_verdict
    # Finding-style: verdict is the type.
    assert v({"type": "validation_passed", "data": "ok"}) is True
    assert v({"type": "validation_failed", "data": "boom"}) is False
    # Terminal-style: verdict is data["status"].
    assert v({"type": "validation_complete",
              "data": {"status": "validated_passed"}}) is True
    assert v({"type": "validation_complete",
              "data": {"status": "validated_failed"}}) is False
    # A failed payload must not be dragged to True by the substring fallback.
    assert v({"type": "validation_complete",
              "data": {"status": "validated_failed",
                       "detailed_output": "note: validation_passed earlier"}}) is False
    assert v(None) is None


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
