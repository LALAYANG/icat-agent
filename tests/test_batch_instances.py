"""Tests for the run/ shim: instance row -> graph dict, incl. requirements/interface injection."""
from run.batch_instances import _row_to_instance_dict


def _row(**overrides):
    base = {
        "instance_id": "instance_NodeBB__NodeBB-abc123-vnan",
        "repo": "NodeBB/NodeBB",
        "base_commit": "deadbeef",
        "problem_statement": "The ACP email status is wrong.",
        "patch": "diff --git ...",
        "test_patch": "diff --git test ...",
        "requirements": "- Each adapter must implement db.mget(keys).",
        "interface": "Name: db.mget\nPath: src/database/redis/main.js",
        "dockerhub_tag": "nodebb.nodebb-NodeBB__NodeBB-abc123",
        "before_repo_set_cmd": "git reset --hard deadbeef",
        "selected_test_files_to_run": ["test/database.js"],
        "fail_to_pass": ["t1"],
        "pass_to_pass": ["t2", "t3"],
        "repo_language": "js",
    }
    base.update(overrides)
    return base


def test_image_key_construction():
    d = _row_to_instance_dict(_row())
    assert d["image_key"] == "jefzda/sweap-images:nodebb.nodebb-NodeBB__NodeBB-abc123"


def test_problem_statement_includes_requirements_and_interface():
    d = _row_to_instance_dict(_row())
    ps = d["problem_statement"]
    assert "The ACP email status is wrong." in ps
    assert "## Requirements" in ps and "db.mget(keys)" in ps
    assert "## Interface" in ps and "src/database/redis/main.js" in ps


def test_problem_statement_without_spec_fields():
    d = _row_to_instance_dict(_row(requirements="", interface=""))
    ps = d["problem_statement"]
    assert "The ACP email status is wrong." in ps
    assert "## Requirements" not in ps and "## Interface" not in ps


def test_list_fields_normalized():
    d = _row_to_instance_dict(_row())
    assert d["fail_to_pass"] == ["t1"]
    assert d["pass_to_pass"] == ["t2", "t3"]
    assert d["selected_test_files_to_run"] == ["test/database.js"]
    assert d["test_cmds"] == []  # Pro leaves test_cmds empty


def test_before_repo_set_cmd_preserved():
    d = _row_to_instance_dict(_row())
    assert d["before_repo_set_cmd"] == "git reset --hard deadbeef"
