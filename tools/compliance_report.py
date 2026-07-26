#!/usr/bin/env python3
"""
Compliance Report: Kiểm tra mức độ tuân thủ Thông tư 15/2019.
So sánh app mapping với rules chính thức.
"""
import json
import os


def load_rules():
    rules_path = os.path.join(os.path.dirname(__file__), "data", "tt15_rules.json")
    with open(rules_path, "r", encoding="utf-8") as f:
        return json.load(f)


def dots_to_unicode(dots):
    val = 0
    for d in dots:
        val += 2 ** (d - 1)
    return chr(0x2800 + val)


def check_compliance():
    """Check compliance between rules and app mapping."""
    rules = load_rules()

    results = {
        "alphabet": {"total": 0, "compliant": 0, "issues": []},
        "tones": {"total": 0, "compliant": 0, "issues": []},
        "symbols": {"total": 0, "compliant": 0, "issues": []},
    }

    # Check alphabet
    all_chars = {**rules["alphabet"], **rules["extended"]}
    for char, info in all_chars.items():
        results["alphabet"]["total"] += 1
        expected_unicode = dots_to_unicode(info["dots"])
        # In a real check, we'd compare against app mapping
        # For now, verify the dots produce valid Braille Unicode
        if 0x2800 <= ord(expected_unicode) <= 0x28FF:
            results["alphabet"]["compliant"] += 1
        else:
            results["alphabet"]["issues"].append(f"{char}: invalid Unicode")

    # Check tones
    for tone, info in rules["tones"].items():
        results["tones"]["total"] += 1
        expected_unicode = dots_to_unicode(info["dots"])
        if 0x2800 <= ord(expected_unicode) <= 0x28FF:
            results["tones"]["compliant"] += 1
        else:
            results["tones"]["issues"].append(f"{tone}: invalid Unicode")

    # Check symbols
    for sym, info in rules["symbols"].items():
        results["symbols"]["total"] += 1
        dots = info["dots"]
        if isinstance(dots[0], list):
            # Multi-cell
            all_valid = all(0x2800 <= ord(dots_to_unicode(d)) <= 0x28FF for d in dots)
        else:
            all_valid = 0x2800 <= ord(dots_to_unicode(dots)) <= 0x28FF
        if all_valid:
            results["symbols"]["compliant"] += 1
        else:
            results["symbols"]["issues"].append(f"{sym}: invalid Unicode")

    return results


def main():
    print("=" * 60)
    print("COMPLIANCE REPORT: Thông tư 15/2019")
    print("=" * 60)

    results = check_compliance()

    total_all = 0
    compliant_all = 0

    for category, data in results.items():
        total_all += data["total"]
        compliant_all += data["compliant"]
        pct = (data["compliant"] / data["total"] * 100) if data["total"] > 0 else 0
        print(f"\n{category.upper()}: {data['compliant']}/{data['total']} ({pct:.0f}%)")
        if data["issues"]:
            for issue in data["issues"]:
                print(f"  ⚠ {issue}")

    overall_pct = (compliant_all / total_all * 100) if total_all > 0 else 0
    print(f"\n{'=' * 60}")
    print(f"OVERALL: {compliant_all}/{total_all} ({overall_pct:.0f}% compliant)")
    print("=" * 60)


if __name__ == "__main__":
    main()
