"""Minimal local `run/` harness shim for icat-agent.

The original `run/` package (the outer batch driver: dataset loading, prediction/
trajectory saving, PDF generation) is not committed to this repo — it lives
externally/in the cloud. This shim provides just enough of that interface to run
a single SWE-bench **Pro** instance end-to-end via `main.py` for smoke-testing.

Provides:
- run.batch_instances.load_instances(subset, split, instance_ids)
- run.common.save_predictions / save_trajectory / save_instance_summary
- run.generate_trajectory_pdf.generate_pdf / find_run_log  (no-op)
"""
