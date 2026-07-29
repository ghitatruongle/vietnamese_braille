from __future__ import annotations

import copy
import unittest

from tools.release_evidence import (
    REQUIRED_ACCESSIBILITY_SCENARIOS,
    REQUIRED_USER_SCENARIOS,
    TT15_FIXTURE,
    TT15_SOURCE,
    file_sha256,
    validate_evidence,
)


def valid_payload() -> dict[str, object]:
    sessions = []
    display_names = {
        ("windows", "nvda"): ("Windows", "NVDA"),
        ("web", "nvda"): ("Web", "NVDA"),
        ("android", "talkback"): ("Android", "TalkBack"),
        ("ios", "voiceover"): ("iOS", "VoiceOver"),
    }
    for key, scenarios in REQUIRED_ACCESSIBILITY_SCENARIOS.items():
        platform, technology = display_names[key]
        sessions.append(
            {
                "platform": platform,
                "assistive_technology": technology,
                "os_version": "test-os-1",
                "technology_version": "test-at-1",
                "tester_id": f"tester-{platform.lower()}",
                "tested_at": "2026-07-27T12:00:00+07:00",
                "attestation_reference": f"https://example.test/{platform}",
                "result": "passed",
                "blocking_issues": 0,
                "scenarios": sorted(scenarios),
            }
        )

    return {
        "schema_version": 1,
        "release": {
            "tag": "v1.1.0",
            "version": "1.1.0",
            "commit": "a" * 40,
        },
        "tt15_external_review": {
            "result": "passed",
            "blocking_issues": 0,
            "independent": True,
            "reviewer_id": "reviewer-1",
            "reviewed_at": "2026-07-27T12:00:00+07:00",
            "source_sha256": file_sha256(TT15_SOURCE),
            "fixture_sha256": file_sha256(TT15_FIXTURE),
            "attestation_reference": "https://example.test/tt15",
        },
        "accessibility": {
            "result": "passed",
            "blocking_issues": 0,
            "sessions": sessions,
        },
        "user_validation": {
            "result": "passed",
            "blocking_issues": 0,
            "participant_count": 1,
            "includes_blind_or_low_vision_participant": True,
            "coordinator_id": "coordinator-1",
            "tested_at": "2026-07-27T12:00:00+07:00",
            "attestation_reference": "https://example.test/user-test",
            "scenarios": sorted(REQUIRED_USER_SCENARIOS),
        },
        "release_approval": {
            "result": "passed",
            "blocking_issues": 0,
            "approver_id": "maintainer-1",
            "approved_at": "2026-07-27T12:00:00+07:00",
            "attestation_reference": "https://example.test/approval",
        },
    }


class ReleaseEvidenceTest(unittest.TestCase):
    def test_complete_evidence_passes(self) -> None:
        payload = valid_payload()

        failures = validate_evidence(
            payload,
            expected_tag="v1.1.0",
            expected_commit="a" * 40,
        )

        self.assertEqual(failures, [])

    def test_pending_or_wrong_tt15_evidence_fails(self) -> None:
        payload = valid_payload()
        review = payload["tt15_external_review"]
        assert isinstance(review, dict)
        review["result"] = "pending"
        review["fixture_sha256"] = "0" * 64

        failures = validate_evidence(payload)

        self.assertTrue(any("result must be 'passed'" in item for item in failures))
        self.assertTrue(
            any("does not match tools/data/tt15_rules.json" in item for item in failures)
        )

    def test_missing_screen_reader_session_fails(self) -> None:
        payload = valid_payload()
        accessibility = payload["accessibility"]
        assert isinstance(accessibility, dict)
        sessions = accessibility["sessions"]
        assert isinstance(sessions, list)
        sessions[:] = [
            session
            for session in sessions
            if not (
                isinstance(session, dict)
                and session.get("platform") == "iOS"
            )
        ]

        failures = validate_evidence(payload)

        self.assertIn(
            "missing accessibility session for ios/voiceover",
            failures,
        )

    def test_commit_and_user_scenario_must_match(self) -> None:
        payload = copy.deepcopy(valid_payload())
        user_validation = payload["user_validation"]
        assert isinstance(user_validation, dict)
        user_validation["scenarios"] = ["convert_and_read"]

        failures = validate_evidence(
            payload,
            expected_commit="b" * 40,
        )

        self.assertTrue(any("release.commit is" in item for item in failures))
        self.assertTrue(
            any("user_validation.scenarios is missing" in item for item in failures)
        )


if __name__ == "__main__":
    unittest.main()
