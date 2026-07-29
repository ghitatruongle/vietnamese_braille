#!/usr/bin/env python3
"""Validate external evidence required for a production release."""

from __future__ import annotations

import argparse
from datetime import datetime
import hashlib
import json
from pathlib import Path
import re
import sys
from typing import Any


REPOSITORY_ROOT = Path(__file__).resolve().parent.parent
TT15_SOURCE = (
    REPOSITORY_ROOT
    / "quytac"
    / "501196e24bee7141a3d2d37f879d04a615_2019_TT_BGDDT.pdf"
)
TT15_FIXTURE = REPOSITORY_ROOT / "tools" / "data" / "tt15_rules.json"

_SHA256 = re.compile(r"^[0-9a-f]{64}$")
_COMMIT = re.compile(r"^[0-9a-f]{40}$")
_VERSION = re.compile(r"^\d+\.\d+\.\d+(?:[-+][0-9A-Za-z.-]+)?$")

REQUIRED_ACCESSIBILITY_SCENARIOS = {
    ("windows", "nvda"): {
        "convert",
        "copy",
        "learn",
        "quiz",
        "export",
    },
    ("web", "nvda"): {
        "keyboard_navigation",
        "headings",
        "error_announcements",
    },
    ("android", "talkback"): {
        "convert",
        "ocr",
        "learn",
        "quiz",
        "share",
    },
    ("ios", "voiceover"): {
        "convert",
        "ocr",
        "learn",
        "quiz",
        "share",
    },
}
REQUIRED_USER_SCENARIOS = {
    "convert_and_read",
    "file_and_brf",
    "learn_with_screen_reader",
    "five_question_quiz",
    "font_scale_200",
}


def file_sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as source:
        for chunk in iter(lambda: source.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def _mapping(
    value: Any,
    path: str,
    failures: list[str],
) -> dict[str, Any]:
    if not isinstance(value, dict):
        failures.append(f"{path} must be an object")
        return {}
    return value


def _string(
    value: dict[str, Any],
    key: str,
    path: str,
    failures: list[str],
) -> str:
    result = value.get(key)
    if not isinstance(result, str) or not result.strip():
        failures.append(f"{path}.{key} must be a non-empty string")
        return ""
    return result.strip()


def _passed(
    value: dict[str, Any],
    path: str,
    failures: list[str],
) -> None:
    if value.get("result") != "passed":
        failures.append(f"{path}.result must be 'passed'")
    if value.get("blocking_issues") != 0:
        failures.append(f"{path}.blocking_issues must be 0")


def _timestamp(
    value: dict[str, Any],
    key: str,
    path: str,
    failures: list[str],
) -> None:
    raw = _string(value, key, path, failures)
    if not raw:
        return
    try:
        parsed = datetime.fromisoformat(raw.replace("Z", "+00:00"))
    except ValueError:
        failures.append(f"{path}.{key} must be an ISO-8601 timestamp")
        return
    if parsed.tzinfo is None:
        failures.append(f"{path}.{key} must include a timezone")


def _scenario_set(
    value: Any,
    path: str,
    failures: list[str],
) -> set[str]:
    if not isinstance(value, list) or any(
        not isinstance(item, str) for item in value
    ):
        failures.append(f"{path} must be an array of strings")
        return set()
    return {item.strip() for item in value if item.strip()}


def validate_evidence(
    payload: Any,
    *,
    expected_tag: str | None = None,
    expected_commit: str | None = None,
) -> list[str]:
    failures: list[str] = []
    root = _mapping(payload, "root", failures)

    if root.get("schema_version") != 1:
        failures.append("schema_version must be 1")

    release = _mapping(root.get("release"), "release", failures)
    tag = _string(release, "tag", "release", failures)
    version = _string(release, "version", "release", failures)
    commit = _string(release, "commit", "release", failures).lower()
    if version and not _VERSION.fullmatch(version):
        failures.append("release.version must use semantic versioning")
    if tag and version and tag != f"v{version}":
        failures.append("release.tag must equal 'v' plus release.version")
    if expected_tag is not None and tag != expected_tag:
        failures.append(
            f"release.tag is {tag!r}, expected {expected_tag!r}"
        )
    if commit and not _COMMIT.fullmatch(commit):
        failures.append("release.commit must be a full 40-character Git SHA")
    if expected_commit is not None and commit != expected_commit.lower():
        failures.append(
            f"release.commit is {commit!r}, expected "
            f"{expected_commit.lower()!r}"
        )

    tt15 = _mapping(
        root.get("tt15_external_review"),
        "tt15_external_review",
        failures,
    )
    _passed(tt15, "tt15_external_review", failures)
    if tt15.get("independent") is not True:
        failures.append("tt15_external_review.independent must be true")
    _string(tt15, "reviewer_id", "tt15_external_review", failures)
    _string(tt15, "attestation_reference", "tt15_external_review", failures)
    _timestamp(tt15, "reviewed_at", "tt15_external_review", failures)
    source_hash = _string(
        tt15,
        "source_sha256",
        "tt15_external_review",
        failures,
    ).lower()
    fixture_hash = _string(
        tt15,
        "fixture_sha256",
        "tt15_external_review",
        failures,
    ).lower()
    if source_hash and not _SHA256.fullmatch(source_hash):
        failures.append(
            "tt15_external_review.source_sha256 must be a SHA-256 digest"
        )
    if fixture_hash and not _SHA256.fullmatch(fixture_hash):
        failures.append(
            "tt15_external_review.fixture_sha256 must be a SHA-256 digest"
        )
    if TT15_SOURCE.is_file() and source_hash != file_sha256(TT15_SOURCE):
        failures.append(
            "tt15_external_review.source_sha256 does not match the TT15 PDF"
        )
    if TT15_FIXTURE.is_file() and fixture_hash != file_sha256(TT15_FIXTURE):
        failures.append(
            "tt15_external_review.fixture_sha256 does not match "
            "tools/data/tt15_rules.json"
        )

    accessibility = _mapping(
        root.get("accessibility"),
        "accessibility",
        failures,
    )
    _passed(accessibility, "accessibility", failures)
    sessions = accessibility.get("sessions")
    if not isinstance(sessions, list):
        failures.append("accessibility.sessions must be an array")
        sessions = []

    observed: dict[tuple[str, str], set[str]] = {}
    for index, raw_session in enumerate(sessions):
        path = f"accessibility.sessions[{index}]"
        session = _mapping(raw_session, path, failures)
        platform = _string(session, "platform", path, failures).casefold()
        technology = _string(
            session,
            "assistive_technology",
            path,
            failures,
        ).casefold()
        _string(session, "os_version", path, failures)
        _string(session, "technology_version", path, failures)
        _string(session, "tester_id", path, failures)
        _string(session, "attestation_reference", path, failures)
        _timestamp(session, "tested_at", path, failures)
        _passed(session, path, failures)
        scenarios = _scenario_set(
            session.get("scenarios"),
            f"{path}.scenarios",
            failures,
        )
        observed.setdefault((platform, technology), set()).update(scenarios)

    for key, required_scenarios in REQUIRED_ACCESSIBILITY_SCENARIOS.items():
        actual_scenarios = observed.get(key)
        label = f"{key[0]}/{key[1]}"
        if actual_scenarios is None:
            failures.append(f"missing accessibility session for {label}")
            continue
        missing = sorted(required_scenarios - actual_scenarios)
        if missing:
            failures.append(
                f"accessibility session {label} is missing scenarios: {missing}"
            )

    user_validation = _mapping(
        root.get("user_validation"),
        "user_validation",
        failures,
    )
    _passed(user_validation, "user_validation", failures)
    participant_count = user_validation.get("participant_count")
    if (
        not isinstance(participant_count, int)
        or isinstance(participant_count, bool)
        or participant_count < 1
    ):
        failures.append("user_validation.participant_count must be at least 1")
    if (
        user_validation.get("includes_blind_or_low_vision_participant")
        is not True
    ):
        failures.append(
            "user_validation.includes_blind_or_low_vision_participant "
            "must be true"
        )
    _string(
        user_validation,
        "coordinator_id",
        "user_validation",
        failures,
    )
    _string(
        user_validation,
        "attestation_reference",
        "user_validation",
        failures,
    )
    _timestamp(user_validation, "tested_at", "user_validation", failures)
    user_scenarios = _scenario_set(
        user_validation.get("scenarios"),
        "user_validation.scenarios",
        failures,
    )
    missing_user_scenarios = sorted(
        REQUIRED_USER_SCENARIOS - user_scenarios
    )
    if missing_user_scenarios:
        failures.append(
            "user_validation.scenarios is missing: "
            f"{missing_user_scenarios}"
        )

    approval = _mapping(
        root.get("release_approval"),
        "release_approval",
        failures,
    )
    _passed(approval, "release_approval", failures)
    _string(approval, "approver_id", "release_approval", failures)
    _string(
        approval,
        "attestation_reference",
        "release_approval",
        failures,
    )
    _timestamp(approval, "approved_at", "release_approval", failures)

    return failures


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Validate external evidence for a production release."
    )
    parser.add_argument("--file", type=Path, required=True)
    parser.add_argument("--tag")
    parser.add_argument("--commit")
    args = parser.parse_args()

    if not args.file.is_file():
        print(f"FAIL: release evidence file not found: {args.file}")
        return 1

    try:
        payload = json.loads(args.file.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        print(f"FAIL: cannot read release evidence: {error}")
        return 1

    failures = validate_evidence(
        payload,
        expected_tag=args.tag,
        expected_commit=args.commit,
    )
    if failures:
        print(f"Release evidence failed ({len(failures)} issue(s)):")
        for failure in failures:
            print(f"  - {failure}")
        return 1

    print(
        "Release evidence passed: TT15 independent review, "
        "four accessibility sessions, user validation, and release approval."
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
