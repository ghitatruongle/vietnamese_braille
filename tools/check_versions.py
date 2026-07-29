#!/usr/bin/env python3
"""Ensure all package versions agree and optionally match a release tag."""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent
VERSION_FILES = {
    "core": ROOT / "packages" / "viet_braille_core" / "pubspec.yaml",
    "app": ROOT / "viet_braille_app" / "pubspec.yaml",
    "api": ROOT / "api_server" / "pubspec.yaml",
}
LOCK_FILES = {
    "core": ROOT / "packages" / "viet_braille_core" / "pubspec.lock",
    "app": ROOT / "viet_braille_app" / "pubspec.lock",
    "api": ROOT / "api_server" / "pubspec.lock",
}


def read_version(path: Path) -> str:
    match = re.search(
        r"^version:\s*['\"]?([^'\"\s]+)",
        path.read_text(encoding="utf-8"),
        flags=re.MULTILINE,
    )
    if match is None:
        raise ValueError(f"Missing version in {path.relative_to(ROOT)}")
    return match.group(1)


def read_locked_package_version(path: Path, package: str) -> str:
    match = re.search(
        rf"^  {re.escape(package)}:\s*$"
        r"(?P<body>.*?)(?=^  [^\s].*:\s*$|\Z)",
        path.read_text(encoding="utf-8"),
        flags=re.MULTILINE | re.DOTALL,
    )
    if match is None:
        raise ValueError(
            f"Missing package {package!r} in {path.relative_to(ROOT)}"
        )
    version_match = re.search(
        r'^\s{4}version:\s*["\']?([^"\'\s]+)',
        match.group("body"),
        flags=re.MULTILINE,
    )
    if version_match is None:
        raise ValueError(
            f"Missing locked version for {package!r} in "
            f"{path.relative_to(ROOT)}"
        )
    return version_match.group(1)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--tag", help="Expected tag, for example v1.2.3.")
    args = parser.parse_args()

    failures: list[str] = []
    missing_locks = [
        str(path.relative_to(ROOT))
        for path in LOCK_FILES.values()
        if not path.is_file()
    ]
    if missing_locks:
        failures.append(f"Missing lockfiles: {missing_locks}")

    versions = {name: read_version(path) for name, path in VERSION_FILES.items()}
    semantic_versions = {
        name: version.split("+", maxsplit=1)[0]
        for name, version in versions.items()
    }
    unique = set(semantic_versions.values())
    if len(unique) != 1:
        failures.append(f"Package versions differ: {versions}")

    expected = args.tag.removeprefix("v") if args.tag else None
    actual = next(iter(unique)) if len(unique) == 1 else None
    if expected is not None and actual != expected:
        failures.append(f"Tag {args.tag!r} does not match package version {actual!r}")

    if not missing_locks:
        core_version = semantic_versions["core"]
        for consumer in ("app", "api"):
            locked_core = read_locked_package_version(
                LOCK_FILES[consumer],
                "viet_braille_core",
            )
            if locked_core != core_version:
                failures.append(
                    f"{consumer} lockfile pins viet_braille_core "
                    f"{locked_core}, expected {core_version}"
                )

    if failures:
        for failure in failures:
            print(f"FAIL: {failure}", file=sys.stderr)
        return 1

    print(f"Version validation passed: {actual} ({versions})")
    return 0


if __name__ == "__main__":
    sys.exit(main())
