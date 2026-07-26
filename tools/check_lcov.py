#!/usr/bin/env python3
"""Fail CI when LCOV line coverage is below a configured threshold."""

from __future__ import annotations

import argparse
from pathlib import Path


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--file", type=Path, required=True)
    parser.add_argument("--minimum", type=float, required=True)
    args = parser.parse_args()

    found = 0
    hit = 0
    for line in args.file.read_text(encoding="utf-8").splitlines():
        if line.startswith("LF:"):
            found += int(line[3:])
        elif line.startswith("LH:"):
            hit += int(line[3:])

    coverage = 100.0 if found == 0 else hit / found * 100
    print(f"Line coverage: {hit}/{found} = {coverage:.2f}%")
    if coverage + 1e-9 < args.minimum:
        print(f"Required minimum: {args.minimum:.2f}%")
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
