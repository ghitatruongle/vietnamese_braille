from __future__ import annotations

import unittest

from tools.check_release_workflow import (
    WORKFLOW_PATH,
    validate_release_workflow,
)


class ReleaseWorkflowTest(unittest.TestCase):
    def setUp(self) -> None:
        self.source = WORKFLOW_PATH.read_text(encoding="utf-8")

    def test_committed_workflow_passes(self) -> None:
        self.assertEqual(validate_release_workflow(self.source), [])

    def test_wrong_android_keystore_path_fails(self) -> None:
        altered = self.source.replace(
            "storeFile=../release.jks",
            "storeFile=release.jks",
        )

        failures = validate_release_workflow(altered)

        self.assertIn(
            "missing Android app-relative keystore path",
            failures,
        )

    def test_missing_evidence_and_debug_signing_fail(self) -> None:
        altered = self.source.replace(
            "python tools/release_evidence.py",
            "echo skipped",
        )
        altered += '\nsigningConfigs.getByName("debug")\n'

        failures = validate_release_workflow(altered)

        self.assertIn("missing external evidence gate", failures)
        self.assertIn("forbidden debug signing fallback", failures)


if __name__ == "__main__":
    unittest.main()
