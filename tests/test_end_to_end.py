"""Mocked end-to-end graph run: exercises orchestration (repo setup, fan-out,
operator.add reducers, collector) with stubbed agents and a fake Docker env —
no real containers, no LLM calls.
"""
import subprocess

import agent.docker_env as docker_env_mod
from graph import graph_builder as gb


class FakeDockerEnv:
    def __init__(self, instance_id, timeout=600, image_name=None, repo_path=None):
        self.instance_id = instance_id
        self.repo_path = repo_path or "/app"
        self.container_id = None

    def start(self):
        self.container_id = f"fake-{self.instance_id}"
        return True

    def run_command(self, cmd, timeout=None, **kw):
        return (0, "", "")

    def __enter__(self):
        self.start()
        return self

    def __exit__(self, *a):
        return False


def _stub(result):
    class _Agent:
        def __init__(self, *a, **k):
            pass

        def run(self):
            return dict(result)
    return _Agent


def _init_state():
    return {
        "instance_id": "inst-1",
        "repo": "NodeBB/NodeBB",
        "base_commit": "abc",
        "problem_statement": "bug",
        "test_cmds": [],
        "patch": None,
        "image_key": "jefzda/sweap-images:fake",
        "instance_data": {"before_repo_set_cmd": "git reset --hard abc"},
        "swe_bench_subset": "pro",
        "model_name": "anthropic:claude-sonnet-4-5",
        "log_dir": "/tmp/e2e-logs",
        "max_cost": 3.0,
        "localizer_plan": "", "reproducer_plan": "", "patch_editor_plan": "",
        "feasibility_status": None, "feasibility_score": None, "feasibility_details": None,
        "plan_refinement_count": 0,
        "triage_buggy_files": None, "triage_buggy_functions": None,
        "localizer_file": [], "localizer_rationale": [],
        "reproducer_status": [], "reproducer_output": [],
        "reproducer_script": None, "reproducer_expected": None, "reproducer_actual": None,
        "patch_editor_modified_file": [], "patch_editor_patch": [], "patch_editor_unified_diff": [],
        "done_count": 0,
        "reproducer_baseline_regression": None,
        "patch_attempt_count": 0, "patch_validation_status": None, "patch_validation_details": None,
        "localizer_docker_id": None, "reproducer_docker_id": None, "patch_editor_docker_id": None,
        "last_n_observations": 0, "truncate_view": False,
    }


def test_no_plan_graph_end_to_end(monkeypatch):
    # Fake Docker everywhere repo_node / agents would touch it
    monkeypatch.setattr(docker_env_mod, "DockerEnvironment", FakeDockerEnv)

    # Stub the three execution agents with canned state updates
    monkeypatch.setattr(gb, "LocalizerAgent", _stub({
        "localizer_file": ["pkg/core.py"], "localizer_rationale": ["root cause"], "done_count": 1,
    }))
    monkeypatch.setattr(gb, "ReproducerAgent", _stub({
        "reproducer_status": ["validated_passed"], "reproducer_output": ["ok"], "done_count": 1,
    }))
    monkeypatch.setattr(gb, "PatchEditorAgent", _stub({
        "patch_editor_modified_file": ["pkg/core.py"],
        "patch_editor_patch": ["patch"],
        "patch_editor_unified_diff": ["diff --git a/pkg/core.py b/pkg/core.py"],
        "done_count": 1,
    }))

    # Don't spawn real `docker rm` in the collector cleanup
    real_run = subprocess.run
    def fake_run(args, *a, **k):
        if isinstance(args, (list, tuple)) and args and args[0] == "docker":
            class R:
                returncode = 0
                stdout = ""
                stderr = ""
            return R()
        return real_run(args, *a, **k)
    monkeypatch.setattr(subprocess, "run", fake_run)

    app = gb.compile_graph(no_plan=True)
    result = app.invoke(_init_state())

    # Orchestration aggregated all three agents' outputs via operator.add reducers
    assert result["localizer_file"] == ["pkg/core.py"]
    assert result["reproducer_status"] == ["validated_passed"]
    assert result["patch_editor_modified_file"] == ["pkg/core.py"]
    assert result["patch_editor_unified_diff"] == ["diff --git a/pkg/core.py b/pkg/core.py"]
    assert result["done_count"] == 3  # 1 per agent, summed by the reducer
    # repo_node populated docker ids from the fake env
    assert result["shared_docker_id"] == "fake-inst-1"
