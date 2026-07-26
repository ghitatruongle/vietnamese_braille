#!/usr/bin/env python3
"""
Bug check và test độ chính xác của Vietnamese Braille converter.
Kiểm tra các trường hợp đặc biệt và edge cases.
"""

import sys
import json
from pathlib import Path

# Test cases dựa trên quy tắc Braille Việt Nam
TEST_CASES = {
    # 1. Số và dấu chấm thập phân
    "numbers": [
        {
            "input": "123",
            "expected_pattern": "number_indicator + 1 + 2 + 3",
            "description": "Số nguyên cơ bản"
        },
        {
            "input": "3.14",
            "expected_pattern": "number + 3 + dot3 + 1 + 4",
            "description": "Số thập phân với dấu chấm"
        },
        {
            "input": "1,234.56",
            "expected_pattern": "number + 1 + dot3 + 2 + 3 + 4 + dot2 + 5 + 6",
            "description": "Số với dấu phân cách hàng nghìn"
        },
    ],
    
    # 2. Quy tắc qu + nguyên âm có dấu
    "qu_rule": [
        {
            "input": "quá",
            "expected_pattern": "q + u + sac + a",
            "description": "qu + á: dấu sau u"
        },
        {
            "input": "quyết",
            "expected_pattern": "q + u + sac + y + ê + t",
            "description": "quyết: dấu sắc sau u, trước y"
        },
        {
            "input": "Quý",
            "expected_pattern": "capital + q + u + sac + y",
            "description": "Quý viết hoa: capital trước q"
        },
    ],
    
    # 3. Quy tắc gi + nguyên âm có dấu bắt đầu bằng i
    "gi_rule": [
        {
            "input": "giá",
            "expected_pattern": "g + sac + i + a",
            "description": "giá: g + [sac + i] + a"
        },
        {
            "input": "gió",
            "expected_pattern": "g + sac + i + o",
            "description": "gió: dấu sắc giữa g và i"
        },
        {
            "input": "Giảng",
            "expected_pattern": "capital + g + hoi + i + ă + n + g",
            "description": "Giảng viết hoa"
        },
    ],
    
    # 4. Viết hoa - chữ cái đơn
    "capitalization_single": [
        {
            "input": "Việt",
            "expected_pattern": "capital + v + i + ê + t",
            "description": "Viết hoa chữ cái đầu (có phụ âm)"
        },
        {
            "input": "Ấn",
            "expected_pattern": "sac + capital + â + n",
            "description": "Viết hoa nguyên âm (không phụ âm đầu): tone + capital + vowel"
        },
    ],
    
    # 5. Viết hoa - từ toàn bộ
    "capitalization_word": [
        {
            "input": "UNESCO",
            "expected_pattern": "allCapsWord + u + n + e + s + c + o",
            "description": "Từ viết hoa toàn bộ (không phải số La Mã)"
        },
        {
            "input": "II",
            "expected_pattern": "capital + i + i",
            "description": "Số La Mã: 1 dấu báo hoa ở đầu"
        },
        {
            "input": "XVI",
            "expected_pattern": "capital + x + v + i",
            "description": "Số La Mã XVI"
        },
    ],
    
    # 6. Viết hoa - cụm từ
    "capitalization_phrase": [
        {
            "input": "THÔNG TƯ SỐ 15",
            "expected_pattern": "allCapsPhrase + ... + endFormat",
            "description": "Cụm từ viết hoa toàn bộ với dấu kết thúc"
        },
        {
            "input": "Hà Nội",
            "expected_pattern": "initCapsPhrase + h + a + space + n + ô + i + endFormat",
            "description": "Cụm từ viết hoa chữ cái đầu"
        },
    ],
    
    # 7. Nguyên âm không phụ âm đầu (standalone vowel with tone)
    "standalone_vowel": [
        {
            "input": "ấn",
            "expected_pattern": "sac + â + n",
            "description": "Nguyên âm có dấu đứng đầu (không PA): dấu trước nguyên âm"
        },
        {
            "input": "ảnh",
            "expected_pattern": "hoi + a + n + h",
            "description": "ảnh: dấu hỏi trước a"
        },
    ],
    
    # 8. Dấu câu và ký hiệu
    "punctuation": [
        {
            "input": '"Xin chào"',
            "expected_pattern": 'open_quote + ... + close_quote',
            "description": "Ngoặc kép: phân biệt mở/đóng theo context"
        },
        {
            "input": "a...b",
            "expected_pattern": "a + dot3 + dot3 + dot3 + b",
            "description": "Dấu chấm lửng ... → 3 ô chấm 3"
        },
        {
            "input": "(a)",
            "expected_pattern": "lparen + a + rparen",
            "description": "Ngoặc đơn"
        },
    ],
    
    # 9. Đơn vị đo (theo Thông tư 15)
    "units": [
        {
            "input": "5km",
            "expected_pattern": "number + 5 + space + k + m",
            "description": "Đơn vị km: thêm khoảng trắng giữa số và đơn vị"
        },
        {
            "input": "10kg",
            "expected_pattern": "number + 1 + 0 + space + k + g",
            "description": "Đơn vị kg"
        },
    ],
    
    # 10. Phép toán
    "math": [
        {
            "input": "2+3=5",
            "expected_pattern": "number + 2 + plus + 3 + equal + 5",
            "description": "Phép cộng: xóa khoảng trắng xung quanh toán tử"
        },
        {
            "input": "a + b",
            "expected_pattern": "a + space + plus + space + b",
            "description": "Phép toán với chữ: giữ khoảng trắng"
        },
    ],
    
    # 11. NFD normalization (combining diacritics)
    "nfd_input": [
        {
            "input": "a\u0301",  # a + combining acute → á
            "expected_pattern": "sac + a",
            "description": "NFD input: a + combining acute"
        },
        {
            "input": "qu\u00e1",  # qua + combining acute on a
            "expected_pattern": "q + u + sac + a",
            "description": "NFD qu rule"
        },
    ],
    
    # 12. Edge cases
    "edge_cases": [
        {
            "input": "",
            "expected": "",
            "description": "Empty string"
        },
        {
            "input": "   ",
            "expected": "   ",
            "description": "Whitespace only"
        },
        {
            "input": "abc123xyz",
            "expected_pattern": "a + b + c + number + 1 + 2 + 3 + x + y + z",
            "description": "Mixed letters and numbers"
        },
    ],
}

def main():
    """Run bug check and accuracy tests."""
    print("=" * 70)
    print("Vietnamese Braille Converter - Bug Check & Accuracy Test")
    print("=" * 70)
    print()
    
    total_tests = sum(len(cases) for cases in TEST_CASES.values())
    print(f"Total test categories: {len(TEST_CASES)}")
    print(f"Total test cases: {total_tests}")
    print()
    
    # Display test cases for manual verification
    for category, cases in TEST_CASES.items():
        print(f"\n{'─' * 70}")
        print(f"Category: {category.upper()}")
        print(f"{'─' * 70}")
        
        for i, case in enumerate(cases, 1):
            print(f"\n  Test {i}:")
            print(f"    Input: {repr(case['input'])}")
            if 'expected_pattern' in case:
                print(f"    Expected pattern: {case['expected_pattern']}")
            if 'expected' in case:
                print(f"    Expected output: {repr(case['expected'])}")
            print(f"    Description: {case['description']}")
    
    print("\n" + "=" * 70)
    print("POTENTIAL BUGS TO CHECK:")
    print("=" * 70)
    
    bugs = [
        {
            "location": "braille_converter.dart:277-291",
            "issue": "Dấu chấm thập phân trong number mode",
            "details": "Logic kiểm tra ch == '.' và ch == ',' có thể conflict với dấu chấm câu khi không ở number mode",
            "severity": "MEDIUM"
        },
        {
            "location": "braille_converter.dart:138-140",
            "issue": "Nhóm từ viết hoa - kiểm tra khoảng trắng",
            "details": "Logic 'if (sep.trim().isNotEmpty || sep.isEmpty)' luôn đúng - có thể là bug logic",
            "severity": "HIGH"
        },
        {
            "location": "braille_converter.dart:169",
            "issue": "Trùng lặp logic trong init caps phrase",
            "details": "Cùng logic với all caps phrase - có thể refactor",
            "severity": "LOW"
        },
        {
            "location": "braille_converter.dart:319-321",
            "issue": "qu context tracking",
            "details": "inQuContext set sau q+u nhưng không clear khi gặp consonant giữa chừng - có thể gây false positive",
            "severity": "MEDIUM"
        },
        {
            "location": "braille_converter.dart:376-398",
            "issue": "Initial vowel with tone - complex condition",
            "details": "Nhiều điều kiện lồng nhau, khó maintain và dễ có edge case",
            "severity": "MEDIUM"
        },
        {
            "location": "braille_converter.dart:47-52",
            "issue": "Unit regex pattern",
            "details": "Negative lookahead có thể không cover hết các trường hợp (ví dụ: cuối chuỗi, sau ký tự đặc biệt)",
            "severity": "LOW"
        },
        {
            "location": "braille_converter.dart:56-64",
            "issue": "Operator space removal - infinite loop risk",
            "details": "While loop với prev == text check - nếu regex không match đúng có thể vòng lặp vô hạn",
            "severity": "MEDIUM"
        },
        {
            "location": "braille_mapping.dart:376-402",
            "issue": "NFC composition - max 3 passes",
            "details": "Hard-coded 3 passes có thể không đủ cho các trường hợp phức tạp (nhưng hiếm gặp)",
            "severity": "LOW"
        },
    ]
    
    for i, bug in enumerate(bugs, 1):
        print(f"\n{i}. [{bug['severity']}] {bug['issue']}")
        print(f"   Location: {bug['location']}")
        print(f"   Details: {bug['details']}")
    
    print("\n" + "=" * 70)
    print("ACCURACY CONCERNS:")
    print("=" * 70)
    
    concerns = [
        {
            "area": "qu/gi rule edge cases",
            "description": "Các từ như 'quyết', 'quyền' có nhiều nguyên âm sau qu - cần verify tone placement chính xác",
            "example": "quyết → q+u+sắc+y+ê+t hay q+u+y+sắc+ê+t?"
        },
        {
            "area": "Capitalization với tone",
            "description": "Thứ tự capital/tone indicator phức tạp, dễ nhầm",
            "example": "Ấn → sắc+capital+â+n (đúng) vs capital+sắc+â+n (sai)"
        },
        {
            "area": "Number mode context",
            "description": "inNumber flag có thể bị reset không đúng lúc",
            "example": "123abc456 - number mode có đúng không?"
        },
        {
            "area": "NFD normalization",
            "description": "NFD input với qu/gi rule - tone mark combining có thể xử lý sai",
            "example": "qu + a + combining_acute"
        },
        {
            "area": "Phrase capitalization",
            "description": "Dấu kết thúc endFormat có được thêm đúng chỗ không?",
            "example": "HÀ NỘI → cần endFormat sau I"
        },
    ]
    
    for i, concern in enumerate(concerns, 1):
        print(f"\n{i}. {concern['area']}")
        print(f"   Description: {concern['description']}")
        print(f"   Example: {concern['example']}")
    
    print("\n" + "=" * 70)
    print("RECOMMENDATIONS:")
    print("=" * 70)
    print("""
1. Fix logic bug tại line 138-140 (phrase grouping condition)
   - Current: if (sep.trim().isNotEmpty || sep.isEmpty) break;
   - This is always true! Should be: if (sep.trim().isNotEmpty) break;

2. Add unit tests cho tất cả test cases trên

3. Verify qu/gi rule với các trường hợp phức tạp (quyết, quyền, giảng)

4. Add safeguard cho infinite loop trong operator space removal

5. Refactor complex conditions (initial vowel logic) thành helper methods

6. Add logging/debug mode để trace conversion steps

7. Validate với quy tắc chính thức từ Thông tư 15

8. Test với real-world Vietnamese text (văn bản dài, nhiều dấu câu)
""")
    
    print("\n" + "=" * 70)
    print("NEXT STEPS:")
    print("=" * 70)
    print("""
1. Chạy tool này để review các test cases
2. Tạo automated test suite trong Dart/Flutter
3. Fix bug logic tại line 138-140
4. Verify accuracy với các test cases thực tế
5. Document edge cases và expected behavior
""")
    
    return 0

if __name__ == "__main__":
    sys.exit(main())
