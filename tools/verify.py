#!/usr/bin/env python3
"""Cross-platform verification entry point for the monorepo."""

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
    args = parser.parse_args()

    if not any((args.all, args.mapping, args.analysis, args.comparison)):
        args.all = True

    commands: list[tuple[list[str], Path, str]] = []

    if args.all or args.mapping or args.comparison:
        commands.append(
            (
                ["dart", "run", "tool/verify_tt15.dart"],
                CORE_ROOT,
                "Independent TT15 fixture vs current core",
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
