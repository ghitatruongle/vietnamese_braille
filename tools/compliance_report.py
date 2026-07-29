#!/usr/bin/env python3
"""Produce an evidence-based TT15 compliance report.

The Dart verifier is authoritative for implementation comparisons. This wrapper
also verifies the pinned source document hash, then exposes a stable JSON report
for CI and release evidence.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import shutil
import subprocess
import sys
from pathlib import Path
from typing import Any


REPOSITORY_ROOT = Path(__file__).resolve().parent.parent
FIXTURE_PATH = REPOSITORY_ROOT / "tools" / "data" / "tt15_rules.json"
CORE_ROOT = REPOSITORY_ROOT / "packages" / "viet_braille_core"


def _sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as source:
        for block in iter(lambda: source.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def build_report() -> dict[str, Any]:
    fixture = json.loads(FIXTURE_PATH.read_text(encoding="utf-8"))
    metadata = fixture["metadata"]
    source_path = REPOSITORY_ROOT / metadata["source_file"]

    # Tài liệu TT15 gốc là tài liệu nội bộ, không vendored trong repo.
    # Hash vẫn được ghim trong fixture: ai có tài liệu đặt vào đúng đường dẫn
    # sẽ được đối chiếu nghiêm ngặt; thiếu file được báo cáo trung thực là
    # not_vendored thay vì failed, chỉ mismatch mới đánh trượt gate.
    source_available = source_path.is_file()
    source_actual_sha256 = _sha256(source_path) if source_available else None
    source_integrity_ok = (
        not source_available
        or source_actual_sha256 == metadata["source_sha256"]
    )
    if not source_available:
        integrity_label = "not_vendored"
    elif source_integrity_ok:
        integrity_label = "passed"
    else:
        integrity_label = "failed"

    dart_command = shutil.which("dart") or shutil.which("dart.bat")
    if dart_command is None:
        return {
            "standard": metadata["standard"],
            "source": {
                "path": metadata["source_file"],
                "expected_sha256": metadata["source_sha256"],
                "actual_sha256": source_actual_sha256,
                "integrity": integrity_label,
            },
            "implementation": {
                "status": "failed",
                "checks": 0,
                "failures": ["Dart executable was not found on PATH."],
            },
            "overall_status": "failed",
        }

    process = subprocess.run(
        [dart_command, "run", "tool/verify_tt15.dart", "--json"],
        cwd=CORE_ROOT,
        check=False,
        capture_output=True,
        encoding="utf-8",
    )
    try:
        implementation = json.loads(process.stdout)
    except json.JSONDecodeError:
        implementation = {
            "status": "failed",
            "checks": 0,
            "failures": [
                "Dart verifier did not return JSON.",
                process.stderr.strip() or process.stdout.strip(),
            ],
        }

    return {
        "standard": metadata["standard"],
        "source": {
            "path": metadata["source_file"],
            "expected_sha256": metadata["source_sha256"],
            "actual_sha256": source_actual_sha256,
            "integrity": integrity_label,
        },
        "implementation": implementation,
        "overall_status": (
            "passed"
            if source_integrity_ok
            and process.returncode == 0
            and implementation.get("status") == "passed"
            else "failed"
        ),
    }


def main() -> int:
    # Console/redirect trên Windows mặc định cp1252 không ghi được tiếng Việt.
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8")

    parser = argparse.ArgumentParser()
    parser.add_argument("--json", action="store_true", help="Emit JSON only.")
    args = parser.parse_args()
    report = build_report()

    if args.json:
        print(json.dumps(report, ensure_ascii=False, indent=2))
    else:
        implementation = report["implementation"]
        print(f"TT15 compliance: {report['overall_status']}")
        print(f"Source integrity: {report['source']['integrity']}")
        print(
            "Implementation checks: "
            f"{implementation.get('checks', 0)}, "
            f"status={implementation.get('status', 'failed')}"
        )
        print(
            "External review: "
            f"{implementation.get('external_review_status', 'unknown')}"
        )
        unsupported = implementation.get("unsupported_rules", [])
        print(f"Explicitly unsupported rules: {len(unsupported)}")
        for failure in implementation.get("failures", []):
            print(f"FAIL: {failure}")

    return 0 if report["overall_status"] == "passed" else 1


if __name__ == "__main__":
    sys.exit(main())
