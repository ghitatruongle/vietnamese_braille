#!/usr/bin/env python3
"""Validate the committed OpenAPI contract against required API behavior."""

from __future__ import annotations

import json
from pathlib import Path
import re
import sys
from typing import Any


ROOT = Path(__file__).resolve().parent.parent
SPEC_PATH = ROOT / "api_server" / "openapi.json"
PUBSPEC_PATH = ROOT / "api_server" / "pubspec.yaml"
REQUIRED_PATHS = {
    "/health": "get",
    "/convert": "post",
    "/reverse": "post",
    "/batch": "post",
}
REQUIRED_ERROR_RESPONSES = {"400", "401", "413", "415", "429"}


def _object(value: Any) -> dict[str, Any]:
    return value if isinstance(value, dict) else {}


def validate_openapi(
    payload: Any,
    *,
    expected_version: str | None = None,
) -> list[str]:
    failures: list[str] = []
    root = _object(payload)
    if root.get("openapi") != "3.1.0":
        failures.append("openapi must be 3.1.0")

    info = _object(root.get("info"))
    if not isinstance(info.get("version"), str):
        failures.append("info.version is missing")
    elif (
        expected_version is not None
        and info.get("version") != expected_version
    ):
        failures.append(
            f"info.version is {info.get('version')!r}, "
            f"expected {expected_version!r}"
        )

    paths = _object(root.get("paths"))
    for path, method in REQUIRED_PATHS.items():
        operation = _object(_object(paths.get(path)).get(method))
        if not operation:
            failures.append(f"missing operation {method.upper()} {path}")
            continue
        responses = _object(operation.get("responses"))
        if "200" not in responses:
            failures.append(f"{method.upper()} {path} is missing response 200")
        if path != "/health":
            missing_responses = sorted(
                REQUIRED_ERROR_RESPONSES - set(responses)
            )
            if missing_responses:
                failures.append(
                    f"{method.upper()} {path} is missing responses "
                    f"{missing_responses}"
                )
            security = operation.get("security")
            if not isinstance(security, list) or not security:
                failures.append(
                    f"{method.upper()} {path} must declare API authentication"
                )

    schemas = _object(_object(root.get("components")).get("schemas"))
    convert_text = _object(
        _object(schemas.get("ConvertRequest")).get("properties")
    )
    convert_limit = _object(convert_text.get("text")).get("maxLength")
    reverse_text = _object(
        _object(schemas.get("ReverseRequest")).get("properties")
    )
    reverse_limit = _object(reverse_text.get("braille")).get("maxLength")
    batch_texts = _object(
        _object(schemas.get("BatchRequest")).get("properties")
    )
    batch_schema = _object(batch_texts.get("texts"))
    if convert_limit != 100000:
        failures.append("ConvertRequest.text.maxLength must be 100000")
    if reverse_limit != 100000:
        failures.append("ReverseRequest.braille.maxLength must be 100000")
    if batch_schema.get("maxItems") != 100:
        failures.append("BatchRequest.texts.maxItems must be 100")
    if _object(batch_schema.get("items")).get("maxLength") != 100000:
        failures.append(
            "BatchRequest.texts.items.maxLength must be 100000"
        )

    security_schemes = _object(
        _object(root.get("components")).get("securitySchemes")
    )
    if "ApiKey" not in security_schemes or "BearerAuth" not in security_schemes:
        failures.append("ApiKey and BearerAuth security schemes are required")
    return failures


def main() -> int:
    try:
        payload = json.loads(SPEC_PATH.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        print(f"FAIL: cannot read {SPEC_PATH.relative_to(ROOT)}: {error}")
        return 1

    version_match = re.search(
        r"^version:\s*['\"]?([^'\"\s]+)",
        PUBSPEC_PATH.read_text(encoding="utf-8"),
        flags=re.MULTILINE,
    )
    expected_version = version_match.group(1) if version_match else None
    failures = validate_openapi(payload, expected_version=expected_version)
    if failures:
        print(f"OpenAPI validation failed ({len(failures)} issue(s)):")
        for failure in failures:
            print(f"  - {failure}")
        return 1
    print("OpenAPI validation passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
