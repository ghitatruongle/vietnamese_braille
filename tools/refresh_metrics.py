#!/usr/bin/env python3
"""Sinh bảng số liệu test/coverage thống nhất cho tài liệu dự án.

Đọc trực tiếp lcov.info của 3 module và đếm test case trong mã nguồn test,
tránh việc tài liệu ghi tay số liệu rồi lỗi thời (bài học từ TEST_SUMMARY.txt
cũ ghi "50/50 tests" trong khi thực tế đã có hơn 800 test).

Cách dùng:
    python tools/refresh_metrics.py            # in bảng Markdown ra stdout
    python tools/refresh_metrics.py --write    # ghi docs/metrics.md + badge JSON
"""

from __future__ import annotations

import argparse
import datetime as _dt
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

MODULES = {
    "core": ROOT / "packages" / "viet_braille_core",
    "app": ROOT / "viet_braille_app",
    "api": ROOT / "api_server",
}

_TEST_CASE_RE = re.compile(r"^\s*(?:test|testWidgets)\(", re.MULTILINE)
_VERSION_RE = re.compile(r"^version:\s*(\S+)", re.MULTILINE)


def lcov_coverage(module_dir: Path) -> tuple[int, int]:
    """Trả về (lines_hit, lines_found) từ coverage/lcov.info; (0, 0) nếu thiếu."""
    lcov = module_dir / "coverage" / "lcov.info"
    if not lcov.is_file():
        return 0, 0
    found = 0
    hit = 0
    for line in lcov.read_text(encoding="utf-8").splitlines():
        if line.startswith("LF:"):
            found += int(line[3:])
        elif line.startswith("LH:"):
            hit += int(line[3:])
    return hit, found


def count_tests(module_dir: Path) -> tuple[int, int]:
    """Trả về (số file test, số khai báo test/testWidgets tĩnh).

    Lưu ý: đây là số khai báo tĩnh; số test lúc chạy có thể cao hơn khi
    test được sinh trong vòng lặp tham số hóa.
    """
    files = sorted((module_dir / "test").rglob("*_test.dart"))
    cases = 0
    for file in files:
        cases += len(_TEST_CASE_RE.findall(file.read_text(encoding="utf-8")))
    return len(files), cases


def module_version(module_dir: Path) -> str:
    match = _VERSION_RE.search((module_dir / "pubspec.yaml").read_text(encoding="utf-8"))
    return match.group(1) if match else "?"


def build_markdown() -> str:
    today = _dt.date.today().isoformat()
    lines = [
        "# Số liệu chất lượng (sinh tự động)",
        "",
        f"Cập nhật: {today} bằng `python tools/refresh_metrics.py --write`.",
        "Không sửa tay file này; số liệu coverage lấy từ `coverage/lcov.info`",
        "của từng module (chạy test với coverage trước để làm mới).",
        "",
        "| Module | Version | File test | Test khai báo | Coverage dòng |",
        "|---|---|---:|---:|---|",
    ]
    for name, module_dir in MODULES.items():
        hit, found = lcov_coverage(module_dir)
        coverage = "chưa có lcov" if found == 0 else f"{hit}/{found} = {hit / found * 100:.2f}%"
        test_files, test_cases = count_tests(module_dir)
        lines.append(
            f"| {name} | {module_version(module_dir)} | {test_files} | {test_cases} | {coverage} |"
        )
    lines.append("")
    lines.append(
        "Số test lúc chạy có thể cao hơn số khai báo tĩnh do test tham số hóa."
    )
    lines.append("")
    return "\n".join(lines)


def build_badge() -> dict[str, str]:
    """Sinh JSON theo schema shields.io endpoint cho coverage gộp 3 module."""
    total_hit = 0
    total_found = 0
    for module_dir in MODULES.values():
        hit, found = lcov_coverage(module_dir)
        total_hit += hit
        total_found += found
    if total_found == 0:
        return {"schemaVersion": 1, "label": "coverage", "message": "unknown", "color": "lightgrey"}
    percent = total_hit / total_found * 100
    color = "brightgreen" if percent >= 90 else "green" if percent >= 80 else "orange"
    return {
        "schemaVersion": 1,
        "label": "coverage",
        "message": f"{percent:.1f}%",
        "color": color,
    }


def main() -> int:
    # Console Windows mặc định cp1252 không in được tiếng Việt có dấu.
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8")

    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--write",
        action="store_true",
        help="ghi kết quả vào docs/metrics.md thay vì in ra stdout",
    )
    args = parser.parse_args()

    markdown = build_markdown()
    if args.write:
        target = ROOT / "docs" / "metrics.md"
        target.write_text(markdown, encoding="utf-8")
        print(f"Đã ghi {target}")
        badge_target = ROOT / "docs" / "coverage-badge.json"
        badge_target.write_text(
            json.dumps(build_badge(), ensure_ascii=False) + "\n",
            encoding="utf-8",
        )
        print(f"Đã ghi {badge_target}")
    else:
        print(markdown)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
