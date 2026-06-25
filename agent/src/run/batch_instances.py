"""Minimal instance loader for the `run/` shim.

Loads SWE-bench **Pro** instances directly from the HuggingFace parquet
(`ScaleAI/SWE-bench_Pro`) using huggingface_hub + pyarrow, avoiding the
`datasets`/`pyarrow>=21` dependency that has no wheel on this (old-glibc) host.

The real harness supported lite/verified/full/pro; this shim implements only
`pro` (the subset needed for smoke-testing). Other subsets raise NotImplementedError.
"""
from __future__ import annotations

import logging
from functools import lru_cache
from typing import Any, Dict, List, Optional

log = logging.getLogger("run.batch_instances")

# Public SWE-bench Pro dataset + the DockerHub registry that hosts its images.
_PRO_DATASET = "ScaleAI/SWE-bench_Pro"
_PRO_PARQUET = "data/test-00000-of-00001.parquet"
_PRO_IMAGE_REGISTRY = "jefzda/sweap-images"  # tag == row['dockerhub_tag']


class Instance:
    """Thin wrapper exposing `.to_dict()` (the interface main.py expects)."""

    def __init__(self, data: Dict[str, Any]):
        self._data = data

    def to_dict(self) -> Dict[str, Any]:
        return dict(self._data)

    @property
    def instance_id(self) -> str:
        return self._data["instance_id"]


@lru_cache(maxsize=1)
def _load_pro_dataframe():
    """Download + read the Pro parquet once per process."""
    from huggingface_hub import hf_hub_download
    import pyarrow.parquet as pq

    path = hf_hub_download(_PRO_DATASET, _PRO_PARQUET, repo_type="dataset")
    log.info(f"[load_instances] Loaded Pro parquet: {path}")
    return pq.read_table(path).to_pandas()


def _row_to_instance_dict(row) -> Dict[str, Any]:
    """Map a Pro dataset row to the instance dict the graph consumes.

    The graph (graph_builder._get_instance_setup_commands) treats Pro specially:
    `before_repo_set_cmd` is eval-only and skipped during agent setup, and
    repo_path is /app. We pass the image directly via `image_key`.
    """
    def _as_list(v):
        if v is None:
            return []
        try:
            return list(v)
        except TypeError:
            return [v]

    # SWE-bench Pro ships a `requirements` (behavioral spec) and `interface`
    # (exact method/function signatures + file paths) alongside the issue text.
    # These are part of the intended task input — without them the agent only
    # sees the vague issue and can't know about required new APIs (e.g. db.mget).
    # Fold them into the problem statement, as the reference harness does.
    problem_statement = str(row.get("problem_statement", "") or "")
    requirements = str(row.get("requirements", "") or "").strip()
    interface = str(row.get("interface", "") or "").strip()
    sections = [problem_statement.strip()]
    if requirements:
        sections.append(
            "## Requirements\n"
            "The fix must satisfy the following behavioral requirements:\n\n"
            + requirements
        )
    if interface:
        sections.append(
            "## Interface\n"
            "Implement exactly these methods/functions (names, file paths, and signatures):\n\n"
            + interface
        )
    full_problem_statement = "\n\n".join(s for s in sections if s)

    dockerhub_tag = str(row["dockerhub_tag"])
    return {
        "instance_id": str(row["instance_id"]),
        "repo": str(row["repo"]),
        "base_commit": str(row["base_commit"]),
        "problem_statement": full_problem_statement,
        # Keep the raw spec fields too, for reference/debugging.
        "requirements": requirements,
        "interface": interface,
        "patch": (str(row["patch"]) if row.get("patch") is not None else None),
        "test_patch": (str(row["test_patch"]) if row.get("test_patch") is not None else None),
        # Pro images live on DockerHub under jefzda/sweap-images:<dockerhub_tag>.
        "image_key": f"{_PRO_IMAGE_REGISTRY}:{dockerhub_tag}",
        "dockerhub_tag": dockerhub_tag,
        "before_repo_set_cmd": str(row.get("before_repo_set_cmd", "") or ""),
        "selected_test_files_to_run": _as_list(row.get("selected_test_files_to_run")),
        "fail_to_pass": _as_list(row.get("fail_to_pass")),
        "pass_to_pass": _as_list(row.get("pass_to_pass")),
        "repo_language": str(row.get("repo_language", "") or ""),
        # The graph reads test_cmds; Pro uses selected_test_files_to_run instead,
        # so leave empty (agents discover/run tests themselves).
        "test_cmds": [],
    }


def load_instances(
    subset: str = "pro",
    split: str = "test",
    instance_ids: Optional[List[str]] = None,
) -> List[Instance]:
    """Load instances for the given subset/split, optionally filtered by id.

    Only `subset="pro"` is implemented in this shim.
    """
    if subset != "pro":
        raise NotImplementedError(
            f"run/ shim only supports subset='pro' (got {subset!r}). "
            "The original harness handled lite/verified/full; that code is not vendored here."
        )

    df = _load_pro_dataframe()

    if instance_ids:
        wanted = set(instance_ids)
        df = df[df["instance_id"].astype(str).isin(wanted)]
        found = set(df["instance_id"].astype(str))
        missing = wanted - found
        if missing:
            raise ValueError(f"Instance id(s) not found in {_PRO_DATASET}: {sorted(missing)}")

    instances = [Instance(_row_to_instance_dict(row)) for _, row in df.iterrows()]
    log.info(f"[load_instances] Returning {len(instances)} instance(s) for subset={subset}")
    return instances
