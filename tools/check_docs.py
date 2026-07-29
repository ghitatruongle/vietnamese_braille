#!/usr/bin/env python3
"""Validate MkDocs navigation and local Markdown links without dependencies."""

from __future__ import annotations

from pathlib import Path
import re
import sys
from urllib.parse import unquote


REPOSITORY_ROOT = Path(__file__).resolve().parent.parent
DOCS_ROOT = REPOSITORY_ROOT / "docs"
MKDOCS_CONFIG = REPOSITORY_ROOT / "mkdocs.yml"

_NAV_ENTRY = re.compile(r"^\s{2}-\s+[^:]+:\s+([^#\s][^#]*)\s*$")
_MARKDOWN_LINK = re.compile(r"!?\[[^\]]*]\(([^)]+)\)")


def _is_external(target: str) -> bool:
    lowered = target.lower()
    return lowered.startswith(
        ("http://", "https://", "mailto:", "tel:", "data:", "#")
    )


def _clean_target(raw_target: str) -> str:
    target = raw_target.strip().split(maxsplit=1)[0].strip("<>")
    target = unquote(target.split("#", maxsplit=1)[0])
    return target


def _check_mkdocs_navigation() -> list[str]:
    failures: list[str] = []
    in_navigation = False
    for line_number, line in enumerate(
        MKDOCS_CONFIG.read_text(encoding="utf-8").splitlines(),
        start=1,
    ):
        if line.strip() == "nav:":
            in_navigation = True
            continue
        if in_navigation and line and not line[0].isspace():
            in_navigation = False
        if not in_navigation:
            continue
        match = _NAV_ENTRY.match(line)
        if match is None:
            continue
        target = _clean_target(match.group(1))
        if not target or _is_external(target):
            continue
        resolved = (DOCS_ROOT / target).resolve()
        if not resolved.is_relative_to(DOCS_ROOT.resolve()):
            failures.append(
                f"mkdocs.yml:{line_number}: navigation escapes docs/: {target}"
            )
        elif not resolved.is_file():
            failures.append(
                f"mkdocs.yml:{line_number}: missing navigation page: {target}"
            )
    return failures


def _check_markdown_links() -> list[str]:
    failures: list[str] = []
    markdown_files = [
        REPOSITORY_ROOT / "README.md",
        REPOSITORY_ROOT / "CONTRIBUTING.md",
        REPOSITORY_ROOT / "CHANGELOG.md",
        REPOSITORY_ROOT / "PUBLISH_PLAN.md",
        REPOSITORY_ROOT / "PRIVACY.md",
        REPOSITORY_ROOT / "SECURITY.md",
        REPOSITORY_ROOT / "CODE_OF_CONDUCT.md",
        *DOCS_ROOT.rglob("*.md"),
        *(REPOSITORY_ROOT / "release_evidence").glob("*.md"),
        *(REPOSITORY_ROOT / "packages").rglob("README.md"),
        *(REPOSITORY_ROOT / "api_server").rglob("README.md"),
        *(REPOSITORY_ROOT / "viet_braille_app").glob("README.md"),
    ]

    for source in sorted(set(markdown_files)):
        if not source.is_file():
            continue
        for line_number, line in enumerate(
            source.read_text(encoding="utf-8").splitlines(),
            start=1,
        ):
            for match in _MARKDOWN_LINK.finditer(line):
                target = _clean_target(match.group(1))
                if not target or _is_external(target):
                    continue
                resolved = (source.parent / target).resolve()
                if not resolved.exists():
                    relative_source = source.relative_to(REPOSITORY_ROOT)
                    failures.append(
                        f"{relative_source}:{line_number}: missing link target: "
                        f"{target}"
                    )
    return failures


def main() -> int:
    failures = [*_check_mkdocs_navigation(), *_check_markdown_links()]
    if failures:
        print(f"Documentation validation failed ({len(failures)} issue(s)):")
        for failure in failures:
            print(f"  - {failure}")
        return 1

    print("Documentation validation passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
