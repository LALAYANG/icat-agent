"""Output savers for the `run/` shim: predictions, trajectory, instance summary.

Writes into `<log_dir>/<instance_id>/` to match the paths main.py prints.
"""
from __future__ import annotations

import json
import logging
from pathlib import Path
from typing import Any, Dict, List, Optional

log = logging.getLogger("run.common")


def _extract_model_patch(result: Dict[str, Any]) -> str:
    """Pull the unified diff out of the final graph state.

    patch_editor_unified_diff / patch_editor_patch are concurrent-update lists;
    take the last non-empty entry.
    """
    for key in ("patch_editor_unified_diff", "patch_editor_patch"):
        vals = result.get(key) or []
        if isinstance(vals, str):
            vals = [vals]
        for v in reversed(vals):
            if v and str(v).strip():
                return str(v)
    return ""


def _instance_dir(log_dir: Path, instance_id: str) -> Path:
    d = Path(log_dir) / instance_id
    d.mkdir(parents=True, exist_ok=True)
    return d


def save_predictions(log_dir: Path, instance_id: str, result: Dict[str, Any], model_name: str = "") -> Path:
    """Write `<instance_id>.pred` (instance_id, model_name_or_path, model_patch)."""
    inst_dir = _instance_dir(log_dir, instance_id)
    pred = {
        "instance_id": instance_id,
        "model_name_or_path": model_name,
        "model_patch": _extract_model_patch(result),
    }
    out = inst_dir / f"{instance_id}.pred"
    out.write_text(json.dumps(pred, indent=2))
    log.info(f"[save_predictions] {out}")
    return out


def save_trajectory(log_dir: Path, instance_id: str, result: Dict[str, Any], info: Optional[Dict[str, Any]] = None) -> Path:
    """Write `<instance_id>.traj` with a JSON-safe snapshot of the final state."""
    inst_dir = _instance_dir(log_dir, instance_id)

    def _safe(v):
        try:
            json.dumps(v)
            return v
        except (TypeError, ValueError):
            return str(v)

    traj = {
        "instance_id": instance_id,
        "info": info or {},
        "state": {k: _safe(v) for k, v in result.items()},
    }
    out = inst_dir / f"{instance_id}.traj"
    out.write_text(json.dumps(traj, indent=2, default=str))
    log.info(f"[save_trajectory] {out}")
    return out


def save_instance_summary(log_dir: Path, instance_id: str, result: Dict[str, Any]) -> Path:
    """Write `<instance_id>_summary.json` with the headline results + final patch."""
    inst_dir = _instance_dir(log_dir, instance_id)
    summary = {
        "instance_id": instance_id,
        "localizer_file": result.get("localizer_file", []),
        "reproducer_status": result.get("reproducer_status", []),
        "patch_editor_modified_file": result.get("patch_editor_modified_file", []),
        "feasibility_status": result.get("feasibility_status"),
        "feasibility_score": result.get("feasibility_score"),
        "model_patch": _extract_model_patch(result),
    }
    out = inst_dir / f"{instance_id}_summary.json"
    out.write_text(json.dumps(summary, indent=2, default=str))
    log.info(f"[save_instance_summary] {out}")
    return out
