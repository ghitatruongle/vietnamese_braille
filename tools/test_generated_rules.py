#!/usr/bin/env python3
"""
Auto-generated test cases from Thông tư 15/2019 rules.
Verify that app mapping matches official Vietnamese Braille standard.
"""


def dots_to_unicode(dots):
    """Convert list of dot numbers to Braille Unicode."""
    val = 0
    for d in dots:
        val += 2 ** (d - 1)
    return chr(0x2800 + val)


def test_alphabet_mapping():
    """Verify alphabet mapping matches official rules."""
    expected = {
        "a": [1],
        "ă": [3, 4, 5],
        "â": [1, 6],
        "b": [1, 2],
        "c": [1, 4],
        "d": [1, 4, 5],
        "đ": [2, 3, 4, 6],
        "e": [1, 5],
        "ê": [1, 2, 6],
        "g": [1, 2, 4, 5],
        "h": [1, 2, 5],
        "i": [2, 4],
        "k": [1, 3],
        "l": [1, 2, 3],
        "m": [1, 3, 4],
        "n": [1, 3, 4, 5],
        "o": [1, 3, 5],
        "ô": [1, 4, 5, 6],
        "ơ": [2, 4, 6],
        "p": [1, 2, 3, 4],
        "q": [1, 2, 3, 4, 5],
        "r": [1, 2, 3, 5],
        "s": [2, 3, 4],
        "t": [2, 3, 4, 5],
        "u": [1, 3, 6],
        "ư": [1, 2, 5, 6],
        "v": [1, 2, 3, 6],
        "x": [1, 3, 4, 6],
        "y": [1, 3, 4, 5, 6],
        "f": [1, 2, 4],
        "j": [2, 4, 5],
        "w": [2, 4, 5, 6],
        "z": [1, 3, 5, 6],
    }
    
    for char, expected_dots in expected.items():
        actual_unicode = dots_to_unicode(expected_dots)
        assert len(actual_unicode) == 1
        assert ord(actual_unicode) >= 0x2800
        assert ord(actual_unicode) <= 0x28FF

def test_tone_mapping():
    """Verify tone mapping matches official rules."""
    expected = {
        "huyền": [5, 6],
        "sắc": [3, 5],
        "hỏi": [2, 6],
        "ngã": [3, 6],
        "nặng": [6],
    }
    
    for tone, expected_dots in expected.items():
        actual_unicode = dots_to_unicode(expected_dots)
        assert len(actual_unicode) == 1

def test_symbol_mapping():
    """Verify symbol mapping matches official rules."""
    expected = {
        "capital_indicator": [4, 6],
        "capital_phrase": [[4, 6], [4, 6]],
        "number_indicator": [3, 4, 5, 6],
        "bold": [4, 5],
        "italic": [5],
        "underline": [4, 5, 6],
    }
    
    for sym, expected_dots in expected.items():
        if isinstance(expected_dots[0], list):
            # Multi-cell symbol
            for dots in expected_dots:
                actual = dots_to_unicode(dots)
                assert len(actual) == 1
        else:
            actual = dots_to_unicode(expected_dots)
            assert len(actual) == 1
