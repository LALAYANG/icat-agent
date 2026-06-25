# Deprecated symbols (tagged, not yet removed)

These were verified to have **no callers** anywhere in `agent/src` as of 2026-06-24.
They are tagged with a `# DEPRECATED` marker in-place and kept for now; removal is a
separate, deliberate pass. If you intend to use one, drop its marker.

| Symbol | File | Notes |
|--------|------|-------|
| `ReproducerAgent.run_with_regression_tests` | `agent/reproducer_agent.py` | no callers |
| `ReproducerAgent._validate_patch_with_tests` | `agent/reproducer_agent.py` | no callers |
| `ReproducerAgent.validate_patch` | `agent/reproducer_agent.py` | no callers |
| `PatchEditorAgent._auto_share_diff` | `agent/patch_editor_agent.py` | no callers (only a comment references it) |
| `make_edit_symbol` | `agent/tools.py` | not bound by any agent / RolePlanner |
| `make_query_agents` | `agent/tools.py` | not bound by any agent |
| `SlidingWindowManager.get_messages_for_anthropic` | `agent/context_window.py` | no callers; `get_messages` is used instead |
| `PromptCacheManager` (class) | `agent/context_window.py` | no callers; superseded by `SlidingWindowManager.get_messages` cache logic. Still listed in `agent/__init__.py` `__all__` (export left intact). |
