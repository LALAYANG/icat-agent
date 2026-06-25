"""No-op trajectory-PDF stub for the `run/` shim.

The original implementation rendered a PDF from the run log (depends on
matplotlib, which won't build on this host). main.py wraps these calls in
try/except, so returning None / skipping is safe.
"""
from __future__ import annotations

import logging
from typing import Optional

log = logging.getLogger("run.generate_trajectory_pdf")


def find_run_log(instance_dir: str, instance_id: str) -> Optional[str]:
    """Return None so main.py skips PDF generation cleanly."""
    log.info("[generate_trajectory_pdf] PDF generation disabled in run/ shim")
    return None


def generate_pdf(instance_id: str, log_path: str, output_path: str) -> Optional[str]:
    """No-op; the shim does not render trajectory PDFs."""
    return None
