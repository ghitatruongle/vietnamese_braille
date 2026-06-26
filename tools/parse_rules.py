#!/usr/bin/env python3
"""
Parse Thông tư 15/2019 PDF vào structured JSON.
Extract bảng chữ cái, dấu thanh, ký hiệu từ PDF.
"""
import json
import os


def parse_rules_manual():
    """
    Parse rules manually from known data (Thông tư 15/2019).
    Returns structured dict of all Braille rules.
    """
    rules = {
        "alphabet": {
            "a": {"dots": [1], "unicode": "\u2801"},
            "ă": {"dots": [3, 4, 5], "unicode": "\u281c"},
            "â": {"dots": [1, 6], "unicode": "\u2821"},
            "b": {"dots": [1, 2], "unicode": "\u2803"},
            "c": {"dots": [1, 4], "unicode": "\u2809"},
            "d": {"dots": [1, 4, 5], "unicode": "\u2819"},
            "đ": {"dots": [2, 3, 4, 6], "unicode": "\u282e"},
            "e": {"dots": [1, 5], "unicode": "\u2811"},
            "ê": {"dots": [1, 2, 6], "unicode": "\u2823"},
            "g": {"dots": [1, 2, 4, 5], "unicode": "\u281b"},
            "h": {"dots": [1, 2, 5], "unicode": "\u2813"},
            "i": {"dots": [2, 4], "unicode": "\u280a"},
            "k": {"dots": [1, 3], "unicode": "\u2805"},
            "l": {"dots": [1, 2, 3], "unicode": "\u2807"},
            "m": {"dots": [1, 3, 4], "unicode": "\u280d"},
            "n": {"dots": [1, 3, 4, 5], "unicode": "\u281d"},
            "o": {"dots": [1, 3, 5], "unicode": "\u2815"},
            "ô": {"dots": [1, 4, 5, 6], "unicode": "\u2839"},
            "ơ": {"dots": [2, 4, 6], "unicode": "\u282a"},
            "p": {"dots": [1, 2, 3, 4], "unicode": "\u280f"},
            "q": {"dots": [1, 2, 3, 4, 5], "unicode": "\u281f"},
            "r": {"dots": [1, 2, 3, 5], "unicode": "\u2817"},
            "s": {"dots": [2, 3, 4], "unicode": "\u280e"},
            "t": {"dots": [2, 3, 4, 5], "unicode": "\u281e"},
            "u": {"dots": [1, 3, 6], "unicode": "\u2825"},
            "ư": {"dots": [1, 2, 5, 6], "unicode": "\u2833"},
            "v": {"dots": [1, 2, 3, 6], "unicode": "\u2827"},
            "x": {"dots": [1, 3, 4, 6], "unicode": "\u282d"},
            "y": {"dots": [1, 3, 4, 5, 6], "unicode": "\u283d"},
        },
        "extended": {
            "f": {"dots": [1, 2, 4], "unicode": "\u280b"},
            "j": {"dots": [2, 4, 5], "unicode": "\u281a"},
            "w": {"dots": [2, 4, 5, 6], "unicode": "\u283a"},
            "z": {"dots": [1, 3, 5, 6], "unicode": "\u2835"},
        },
        "tones": {
            "huyền": {"dots": [5, 6], "unicode": "\u2830"},
            "sắc": {"dots": [3, 5], "unicode": "\u2814"},
            "hỏi": {"dots": [2, 6], "unicode": "\u2822"},
            "ngã": {"dots": [3, 6], "unicode": "\u2824"},
            "nặng": {"dots": [6], "unicode": "\u2820"},
        },
        "symbols": {
            "capital_indicator": {"dots": [4, 6], "unicode": "\u2828"},
            "capital_phrase": {"dots": [[4, 6], [4, 6]], "unicode": "\u2828\u2828"},
            "number_indicator": {"dots": [3, 4, 5, 6], "unicode": "\u2838"},
            "bold": {"dots": [4, 5], "unicode": "\u2818"},
            "italic": {"dots": [5], "unicode": "\u2810"},
            "underline": {"dots": [4, 5, 6], "unicode": "\u2838"},
        },
        "qu_rule": {
            "description": "Khi 'u' theo sau 'q', dấu thanh đặt trên 'u'",
            "examples": ["quyết", "quả", "qui", "quốc"],
        },
        "gi_rule": {
            "description": "Khi 'i' theo sau 'g', dấu thanh đặt trên 'i'",
            "examples": ["giải", "gạo", "giếng", "gin"],
        },
    }
    return rules


def main():
    output_dir = os.path.join(os.path.dirname(__file__), "data")
    os.makedirs(output_dir, exist_ok=True)

    rules = parse_rules_manual()

    output_path = os.path.join(output_dir, "tt15_rules.json")
    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(rules, f, ensure_ascii=False, indent=2)

    print(f"Rules parsed successfully: {output_path}")
    print(f"  - Alphabet: {len(rules['alphabet'])} characters")
    print(f"  - Extended: {len(rules['extended'])} characters")
    print(f"  - Tones: {len(rules['tones'])} types")
    print(f"  - Symbols: {len(rules['symbols'])} types")


if __name__ == "__main__":
    main()
