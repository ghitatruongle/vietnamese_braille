#!/usr/bin/env python3
"""Cross-platform verification entry point for the monorepo.

The default ``--all`` mode is intentionally suitable for both local use and
CI: it verifies formatting, documentation references, the independent TT15
fixture, static analysis, and all automated tests.
"""

from __future__ import annotations

import argparse
import os
from pathlib import Path
import subprocess
import sys


REPOSITORY_ROOT = Path(__file__).resolve().parent.parent
CORE_ROOT = REPOSITORY_ROOT / "packages" / "viet_braille_core"
APP_ROOT = REPOSITORY_ROOT / "viet_braille_app"
API_ROOT = REPOSITORY_ROOT / "api_server"


def run(command: list[str], *, cwd: Path, description: str) -> bool:
    print(f"\n== {description} ==")
    print(f"$ {' '.join(command)}")
    environment = os.environ.copy()
    environment.setdefault("PYTHONUTF8", "1")
    environment.setdefault("PYTHONIOENCODING", "utf-8")
    effective_command = (
        ["cmd.exe", "/d", "/c", *command] if os.name == "nt" else command
    )
    completed = subprocess.run(
        effective_command,
        cwd=cwd,
        env=environment,
        check=False,
    )
    return completed.returncode == 0


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Verify the Vietnamese Braille core and Flutter app."
    )
    parser.add_argument("--all", action="store_true")
    parser.add_argument("--mapping", action="store_true")
    parser.add_argument("--analysis", action="store_true")
    parser.add_argument("--comparison", action="store_true")
    parser.add_argument("--format", action="store_true")
    parser.add_argument("--docs", action="store_true")
    args = parser.parse_args()

    if not any(
        (
            args.all,
            args.mapping,
            args.analysis,
            args.comparison,
            args.format,
            args.docs,
        )
    ):
        args.all = True

    commands: list[tuple[list[str], Path, str]] = []

    if args.all:
        commands.extend(
            [
                (
                    ["dart", "pub", "get", "--enforce-lockfile"],
                    CORE_ROOT,
                    "Resolve locked core dependencies",
                ),
                (
                    ["dart", "pub", "get", "--enforce-lockfile"],
                    API_ROOT,
                    "Resolve locked API dependencies",
                ),
                (
                    ["flutter", "pub", "get", "--enforce-lockfile"],
                    APP_ROOT,
                    "Resolve locked Flutter dependencies",
                ),
            ]
        )

    if args.all or args.format:
        commands.extend(
            [
                (
                    [
                        "dart",
                        "format",
                        "--output=none",
                        "--set-exit-if-changed",
                        "lib",
                        "test",
                        "tool",
                    ],
                    CORE_ROOT,
                    "Check core formatting",
                ),
                (
                    [
                        "dart",
                        "format",
                        "--output=none",
                        "--set-exit-if-changed",
                        "bin",
                        "lib",
                        "test",
                    ],
                    API_ROOT,
                    "Check API formatting",
                ),
                (
                    [
                        "dart",
                        "format",
                        "--output=none",
                        "--set-exit-if-changed",
                        "lib",
                        "test",
                    ],
                    APP_ROOT,
                    "Check Flutter app formatting",
                ),
            ]
        )

    if args.all or args.docs:
        commands.extend(
            [
                (
                    [
                        sys.executable,
                        "-m",
                        "unittest",
                        "discover",
                        "-s",
                        "tools/tests",
                        "-v",
                    ],
                    REPOSITORY_ROOT,
                    "Test repository evidence tools",
                ),
                (
                    [sys.executable, "tools/check_docs.py"],
                    REPOSITORY_ROOT,
                    "Check documentation references",
                ),
                (
                    [sys.executable, "tools/check_versions.py"],
                    REPOSITORY_ROOT,
                    "Check package version consistency",
                ),
                (
                    [sys.executable, "tools/check_openapi.py"],
                    REPOSITORY_ROOT,
                    "Check OpenAPI contract",
                ),
                (
                    [sys.executable, "tools/check_release_workflow.py"],
                    REPOSITORY_ROOT,
                    "Check release workflow invariants",
                ),
            ]
        )

    if args.all or args.mapping or args.comparison:
        commands.append(
            (
                [sys.executable, "tools/compliance_report.py"],
                REPOSITORY_ROOT,
                "TT15 source integrity and exact fixture vs current core",
            )
        )

    if args.all or args.analysis:
        commands.extend(
            [
                (["dart", "analyze"], CORE_ROOT, "Analyze pure Dart core"),
                (["dart", "analyze"], API_ROOT, "Analyze REST API"),
                (["flutter", "analyze"], APP_ROOT, "Analyze Flutter app"),
            ]
        )

    if args.all:
        commands.extend(
            [
                (["dart", "test"], CORE_ROOT, "Test pure Dart core"),
                (["dart", "test"], API_ROOT, "Test REST API"),
                (
                    ["flutter", "test", "--no-pub"],
                    APP_ROOT,
                    "Test Flutter app",
                ),
            ]
        )

    failures = [
        description
        for command, cwd, description in commands
        if not run(command, cwd=cwd, description=description)
    ]

    if failures:
        print("\nVerification failed:")
        for failure in failures:
            print(f"  - {failure}")
        return 1

    print("\nAll requested verification checks passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
