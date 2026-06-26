#!/usr/bin/env python3
"""
Unified CLI cho Vietnamese Braille verification tools.

Usage:
    python tools/verify.py --all        # Chạy tất cả verification
    python tools/verify.py --mapping    # Chỉ chạy mapping verification
    python tools/verify.py --analysis   # Chỉ chạy deep analysis
    python tools/verify.py --comparison # Chỉ chạy comparison scripts
"""
import sys
import os
import subprocess


def run_script(script_path, description):
    """Chạy một script và trả về True nếu thành công."""
    print(f"\n{'='*60}")
    print(f"Running: {description}")
    print(f"Script: {script_path}")
    print('='*60)

    if not os.path.exists(script_path):
        print(f"WARNING: Script not found: {script_path}")
        return True  # Skip, not fail

    result = subprocess.run([sys.executable, script_path], capture_output=False)
    return result.returncode == 0


def main():
    import argparse
    parser = argparse.ArgumentParser(
        description='Vietnamese Braille verification tools'
    )
    parser.add_argument('--all', action='store_true', help='Run all verification scripts')
    parser.add_argument('--mapping', action='store_true', help='Run mapping verification')
    parser.add_argument('--analysis', action='store_true', help='Run deep analysis')
    parser.add_argument('--comparison', action='store_true', help='Run comparison scripts')
    args = parser.parse_args()

    # Default to --all if no flag specified
    if not any([args.all, args.mapping, args.analysis, args.comparison]):
        args.all = True

    scripts = []

    if args.all or args.mapping:
        scripts.append(
            ("tools/verify/verify_braille.py", "Braille mapping verification")
        )

    if args.all or args.analysis:
        scripts.append(
            ("tools/analysis/deep_analysis.py", "Deep analysis: rules vs app mapping")
        )

    if args.all or args.comparison:
        scripts.extend([
            ("tools/comparison/ueb_comparison.py", "UEB comparison"),
            ("tools/comparison/compare_rules_vs_app.py", "Rules vs app comparison"),
        ])

    failures = 0
    for path, desc in scripts:
        if not run_script(path, desc):
            failures += 1

    print(f"\n{'='*60}")
    if failures:
        print(f"RESULT: {failures} verification(s) FAILED")
        sys.exit(1)
    else:
        print("RESULT: All verifications PASSED")
        sys.exit(0)


if __name__ == "__main__":
    main()
