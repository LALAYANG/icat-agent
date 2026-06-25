"""Tests for compile_graph: the 5 modes produce the expected node sets."""
import pytest

from graph.graph_builder import compile_graph


def _nodes(app):
    return set(app.get_graph().nodes)


def test_default_mode_has_three_planners():
    app = compile_graph()
    nodes = _nodes(app)
    for n in ["repo", "localizer_planner", "patch_editor_planner", "reproducer_planner",
              "plan_evaluation", "localizer", "reproducer", "patch_editor", "collector"]:
        assert n in nodes, n


def test_no_plan_mode_skips_planners():
    nodes = _nodes(compile_graph(no_plan=True))
    assert "localizer_planner" not in nodes
    assert "execution_entry" in nodes
    assert {"localizer", "reproducer", "patch_editor", "collector"} <= nodes


def test_triage_mode_has_triage_node():
    nodes = _nodes(compile_graph(triage=True))
    assert "triage" in nodes
    assert "localizer_planner" not in nodes


def test_triage_sequential_has_localizer_first():
    nodes = _nodes(compile_graph(triage_sequential=True))
    assert "triage" in nodes
    assert "localizer_first" in nodes
    assert "execution_entry_no_localizer" in nodes


def test_triage_sequential_always_forces_localizer():
    nodes = _nodes(compile_graph(triage_sequential_always=True))
    assert "force_localizer_flag" in nodes
    assert "localizer_first" in nodes


def test_shared_plan_has_explorer():
    nodes = _nodes(compile_graph(shared_plan=True))
    assert "shared_planner" in nodes
    assert "plan_evaluation" in nodes


def test_all_modes_compile_without_error():
    for kw in [{}, {"no_plan": True}, {"triage": True}, {"triage_sequential": True},
               {"triage_sequential_always": True}, {"shared_plan": True}]:
        assert compile_graph(**kw) is not None
