from __future__ import annotations

import copy
import json
import unittest

from tools.check_openapi import SPEC_PATH, validate_openapi


class OpenApiContractTest(unittest.TestCase):
    def setUp(self) -> None:
        self.payload = json.loads(SPEC_PATH.read_text(encoding="utf-8"))

    def test_committed_contract_passes(self) -> None:
        self.assertEqual(validate_openapi(self.payload), [])

    def test_missing_endpoint_and_auth_fail(self) -> None:
        payload = copy.deepcopy(self.payload)
        del payload["paths"]["/reverse"]
        payload["paths"]["/convert"]["post"]["security"] = []

        failures = validate_openapi(payload)

        self.assertIn("missing operation POST /reverse", failures)
        self.assertIn(
            "POST /convert must declare API authentication",
            failures,
        )

    def test_limit_drift_fails(self) -> None:
        payload = copy.deepcopy(self.payload)
        payload["components"]["schemas"]["BatchRequest"]["properties"]["texts"][
            "maxItems"
        ] = 101

        failures = validate_openapi(payload)

        self.assertIn("BatchRequest.texts.maxItems must be 100", failures)

    def test_version_drift_fails(self) -> None:
        failures = validate_openapi(
            self.payload,
            expected_version="9.9.9",
        )

        # Không hardcode version hiện hành để test sống qua các lần bump.
        actual_version = self.payload["info"]["version"]
        self.assertIn(
            f"info.version is '{actual_version}', expected '9.9.9'",
            failures,
        )


if __name__ == "__main__":
    unittest.main()
