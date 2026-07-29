#!/usr/bin/env python3
"""Check security-critical invariants in the release workflow."""

from __future__ import annotations

from pathlib import Path
import re
import sys


ROOT = Path(__file__).resolve().parent.parent
WORKFLOW_PATH = ROOT / ".github" / "workflows" / "release.yml"

REQUIRED_SNIPPETS = {
    "external evidence gate": "python tools/release_evidence.py",
    "tag evidence filename": 'release_evidence/${GITHUB_REF_NAME}.json',
    "commit-bound evidence": '--commit "${GITHUB_SHA}"',
    "locked dependencies": "pub get --enforce-lockfile",
    "Windows signing secret": "WINDOWS_PFX_BASE64",
    "Windows signature verification": "Get-AuthenticodeSignature",
    "Android signing secret": "ANDROID_KEYSTORE_BASE64",
    "Android keystore output": (
        "> viet_braille_app/android/release.jks"
    ),
    "Android app-relative keystore path": (
        "printf 'storeFile=../release.jks\\n'"
    ),
    "Android strict signature verification": (
        "jarsigner -verify -strict -certs"
    ),
    "SPDX SBOM": "format: spdx-json",
    "artifact attestation": (
        "uses: actions/attest@36051bcae73b7c2a8a6945a48cbf80953c6baa35"
    ),
    "protected release environment": "environment: production-release",
    "immutable tag verification": "--verify-tag",
}
FORBIDDEN_SNIPPETS = {
    "debug signing fallback": "signingConfigs.getByName(\"debug\")",
    "unenforced Flutter dependency resolution": "flutter pub get\n",
}

# Mọi action phải pin bằng commit SHA 40 ký tự, không dùng tag nổi (v4, v2...).
_UNPINNED_ACTION = re.compile(r"uses:\s*[\w./-]+@(?![0-9a-f]{40}\b)\S+")


def validate_release_workflow(source: str) -> list[str]:
    failures = [
        f"missing {label}"
        for label, snippet in REQUIRED_SNIPPETS.items()
        if snippet not in source
    ]
    failures.extend(
        f"forbidden {label}"
        for label, snippet in FORBIDDEN_SNIPPETS.items()
        if snippet in source
    )
    if source.count("flutter pub get --enforce-lockfile") < 3:
        failures.append(
            "all quality, Windows, and Android/Web jobs must enforce "
            "the Flutter lockfile"
        )
    failures.extend(
        f"unpinned action reference: {match.group(0).strip()}"
        for match in _UNPINNED_ACTION.finditer(source)
    )
    return failures


def main() -> int:
    source = WORKFLOW_PATH.read_text(encoding="utf-8")
    failures = validate_release_workflow(source)
    if failures:
        print(f"Release workflow validation failed ({len(failures)} issue(s)):")
        for failure in failures:
            print(f"  - {failure}")
        return 1
    print("Release workflow validation passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
