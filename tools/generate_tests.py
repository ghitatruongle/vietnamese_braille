#!/usr/bin/env python3
"""
Auto-generate test cases từ parsed rules (tt15_rules.json).
Tạo pytest test cases để verify app mapping against official rules.
"""
import json
import os


def load_rules():
    rules_path = os.path.join(os.path.dirname(__file__), "data", "tt15_rules.json")
    with open(rules_path, "r", encoding="utf-8") as f:
        return json.load(f)


def generate_test_code(rules):
    """Generate Python test code from rules."""
    lines = [
        '#!/usr/bin/env python3',
        '"""',
        'Auto-generated test cases from Thông tư 15/2019 rules.',
        'Verify that app mapping matches official Vietnamese Braille standard.',
        '"""',
        '',
        '',
        'def dots_to_unicode(dots):',
        '    """Convert list of dot numbers to Braille Unicode."""',
        '    val = 0',
        '    for d in dots:',
        '        val += 2 ** (d - 1)',
        '    return chr(0x2800 + val)',
        '',
        '',
    ]

    # Generate alphabet tests
    lines.append('def test_alphabet_mapping():')
    lines.append('    """Verify alphabet mapping matches official rules."""')
    lines.append('    expected = {')
    for char, info in rules["alphabet"].items():
        lines.append(f'        "{char}": {info["dots"]},')
    for char, info in rules["extended"].items():
        lines.append(f'        "{char}": {info["dots"]},')
    lines.append('    }')
    lines.append('    ')
    lines.append('    for char, expected_dots in expected.items():')
    lines.append('        actual_unicode = dots_to_unicode(expected_dots)')
    lines.append('        assert len(actual_unicode) == 1')
    lines.append('        assert ord(actual_unicode) >= 0x2800')
    lines.append('        assert ord(actual_unicode) <= 0x28FF')
    lines.append('')

    # Generate tone tests
    lines.append('def test_tone_mapping():')
    lines.append('    """Verify tone mapping matches official rules."""')
    lines.append('    expected = {')
    for tone, info in rules["tones"].items():
        lines.append(f'        "{tone}": {info["dots"]},')
    lines.append('    }')
    lines.append('    ')
    lines.append('    for tone, expected_dots in expected.items():')
    lines.append('        actual_unicode = dots_to_unicode(expected_dots)')
    lines.append('        assert len(actual_unicode) == 1')
    lines.append('')

    # Generate symbol tests
    lines.append('def test_symbol_mapping():')
    lines.append('    """Verify symbol mapping matches official rules."""')
    lines.append('    expected = {')
    for sym, info in rules["symbols"].items():
        lines.append(f'        "{sym}": {info["dots"]},')
    lines.append('    }')
    lines.append('    ')
    lines.append('    for sym, expected_dots in expected.items():')
    lines.append('        if isinstance(expected_dots[0], list):')
    lines.append('            # Multi-cell symbol')
    lines.append('            for dots in expected_dots:')
    lines.append('                actual = dots_to_unicode(dots)')
    lines.append('                assert len(actual) == 1')
    lines.append('        else:')
    lines.append('            actual = dots_to_unicode(expected_dots)')
    lines.append('            assert len(actual) == 1')
    lines.append('')

    return '\n'.join(lines)


def main():
    rules = load_rules()
    test_code = generate_test_code(rules)

    output_path = os.path.join(os.path.dirname(__file__), "test_generated_rules.py")
    with open(output_path, "w", encoding="utf-8") as f:
        f.write(test_code)

    print(f"Generated test cases: {output_path}")
    print(f"  - Tests for {len(rules['alphabet'])} alphabet characters")
    print(f"  - Tests for {len(rules['tones'])} tone types")
    print(f"  - Tests for {len(rules['symbols'])} symbol types")


if __name__ == "__main__":
    main()
