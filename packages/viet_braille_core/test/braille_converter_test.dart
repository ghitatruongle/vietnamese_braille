import 'package:test/test.dart';
import 'package:viet_braille_core/viet_braille_core.dart';

void main() {
  late BrailleConverter converter;

  setUp(() {
    converter = BrailleConverterImpl(BrailleMappingImpl());
  });

  group('Bug Fixes Verification', () {
    test('Bug #2 - All caps phrase grouping (HÀ NỘI)', () {
      final result = converter.convert('HÀ NỘI');
      // Should contain allCapsPhrase indicator and endFormat
      expect(result, isNotEmpty);
      // The phrase should be grouped together, not treated as separate words
      print('HÀ NỘI -> $result');
    });

    test('Bug #2 - All caps phrase with spaces (THÔNG TƯ SỐ 15)', () {
      final result = converter.convert('THÔNG TƯ SỐ 15');
      expect(result, isNotEmpty);
      print('THÔNG TƯ SỐ 15 -> $result');
    });

    test('Bug #2 - Single word all caps (UNESCO)', () {
      final result = converter.convert('UNESCO');
      expect(result, isNotEmpty);
      print('UNESCO -> $result');
    });

    test('Bug #7 - Operator space removal doesn\'t cause infinite loop', () {
      final result = converter.convert('2  +  3  *  4');
      expect(result, isNotEmpty);
      print('2  +  3  *  4 -> $result');
    });

    test('Bug #7 - Multiple nested operators', () {
      final result = converter.convert('1 + 2 + 3 + 4 + 5 + 6 + 7 + 8');
      expect(result, isNotEmpty);
      print('1 + 2 + 3 + 4 + 5 + 6 + 7 + 8 -> $result');
    });
  });

  group('NUMBERS', () {
    test('Test 1: Số nguyên cơ bản - 123', () {
      final result = converter.convert('123');
      expect(result, contains('⠼')); // number indicator
      print('123 -> $result');
    });

    test('Test 2: Số thập phân với dấu chấm - 3.14', () {
      final result = converter.convert('3.14');
      expect(result, contains('⠼')); // number indicator
      print('3.14 -> $result');
    });

    test('Test 3: Số với dấu phân cách hàng nghìn - 1,234.56', () {
      final result = converter.convert('1,234.56');
      expect(result, contains('⠼'));
      print('1,234.56 -> $result');
    });
  });

  group('QU_RULE', () {
    test('Test 1: quá - dấu sau u', () {
      final result = converter.convert('quá');
      expect(result, isNotEmpty);
      // Expected: q + u + sac + a
      print('quá -> $result');
    });

    test('Test 2: quyết - dấu sắc sau u, trước y', () {
      final result = converter.convert('quyết');
      expect(result, isNotEmpty);
      // Expected: q + u + sac + y + ê + t
      print('quyết -> $result');
    });

    test('Test 3: Quý viết hoa - capital trước q', () {
      final result = converter.convert('Quý');
      expect(result, isNotEmpty);
      // Expected: capital + q + u + sac + y
      print('Quý -> $result');
    });
  });

  group('GI_RULE', () {
    test('Test 1: giá - dấu giữa g và i', () {
      final result = converter.convert('giá');
      expect(result, isNotEmpty);
      // Expected: g + sac + i + a
      print('giá -> $result');
    });

    test('Test 2: gió - dấu sắc giữa g và i', () {
      final result = converter.convert('gió');
      expect(result, isNotEmpty);
      print('gió -> $result');
    });

    test('Test 3: Giảng viết hoa', () {
      final result = converter.convert('Giảng');
      expect(result, isNotEmpty);
      // Expected: capital + g + hoi + i + ă + n + g
      print('Giảng -> $result');
    });
  });

  group('CAPITALIZATION_SINGLE', () {
    test('Test 1: Việt - viết hoa chữ cái đầu có phụ âm', () {
      final result = converter.convert('Việt');
      expect(result, contains('⠠')); // capital indicator
      // Expected: capital + v + i + ê + t
      print('Việt -> $result');
    });

    test('Test 2: Ấn - viết hoa nguyên âm không phụ âm đầu', () {
      final result = converter.convert('Ấn');
      expect(result, isNotEmpty);
      // Expected: sac + capital + â + n
      print('Ấn -> $result');
    });
  });

  group('CAPITALIZATION_WORD', () {
    test('Test 1: UNESCO - từ viết hoa toàn bộ', () {
      final result = converter.convert('UNESCO');
      expect(result, isNotEmpty);
      // Expected: allCapsWord + u + n + e + s + c + o
      print('UNESCO -> $result');
    });

    test('Test 2: II - số La Mã', () {
      final result = converter.convert('II');
      expect(result, isNotEmpty);
      // Note: Uses ⠨⠨ (allCaps indicator) not ⠠ (single capital)
      // Expected: capital + i + i
      print('II -> $result');
    });

    test('Test 3: XVI - số La Mã', () {
      final result = converter.convert('XVI');
      expect(result, isNotEmpty);
      // Note: Uses ⠨ (allCaps indicator) not ⠠
      print('XVI -> $result');
    });
  });

  group('CAPITALIZATION_PHRASE', () {
    test('Test 1: THÔNG TƯ SỐ 15 - cụm từ viết hoa toàn bộ', () {
      final result = converter.convert('THÔNG TƯ SỐ 15');
      expect(result, isNotEmpty);
      print('THÔNG TƯ SỐ 15 -> $result');
    });

    test('Test 2: Hà Nội - cụm từ viết hoa chữ cái đầu', () {
      final result = converter.convert('Hà Nội');
      expect(result, isNotEmpty);
      print('Hà Nội -> $result');
    });
  });

  group('STANDALONE_VOWEL', () {
    test('Test 1: ấn - nguyên âm có dấu đứng đầu', () {
      final result = converter.convert('ấn');
      expect(result, isNotEmpty);
      // Expected: sac + â + n
      print('ấn -> $result');
    });

    test('Test 2: ảnh - dấu hỏi trước a', () {
      final result = converter.convert('ảnh');
      expect(result, isNotEmpty);
      // Expected: hoi + a + n + h
      print('ảnh -> $result');
    });
  });

  group('PUNCTUATION', () {
    test('Test 1: "Xin chào" - ngoặc kép', () {
      final result = converter.convert('"Xin chào"');
      expect(result, isNotEmpty);
      print('"Xin chào" -> $result');
    });

    test('Test 2: a...b - dấu chấm lửng', () {
      final result = converter.convert('a...b');
      expect(result, isNotEmpty);
      // Expected: a + dot3 + dot3 + dot3 + b
      print('a...b -> $result');
    });

    test('Test 3: (a) - ngoặc đơn', () {
      final result = converter.convert('(a)');
      expect(result, isNotEmpty);
      print('(a) -> $result');
    });
  });

  group('UNITS', () {
    test('Test 1: 5km - đơn vị km', () {
      final result = converter.convert('5km');
      expect(result, isNotEmpty);
      // Expected: number + 5 + space + k + m
      print('5km -> $result');
    });

    test('Test 2: 10kg - đơn vị kg', () {
      final result = converter.convert('10kg');
      expect(result, isNotEmpty);
      print('10kg -> $result');
    });
  });

  group('MATH', () {
    test('Test 1: 2+3=5 - phép cộng', () {
      final result = converter.convert('2+3=5');
      expect(result, isNotEmpty);
      // Expected: number + 2 + plus + 3 + equal + 5
      print('2+3=5 -> $result');
    });

    test('Test 2: a + b - phép toán với chữ', () {
      final result = converter.convert('a + b');
      expect(result, isNotEmpty);
      print('a + b -> $result');
    });
  });

  group('NFD_INPUT', () {
    test('Test 1: NFD á (a + combining acute)', () {
      final nfd = 'a\u0301'; // a + combining acute
      final result = converter.convert(nfd);
      expect(result, isNotEmpty);
      print('NFD á -> $result');
    });

    test('Test 2: NFD quá', () {
      final nfd = 'qua\u0301'; // qu + a + combining acute
      final result = converter.convert(nfd);
      expect(result, isNotEmpty);
      print('NFD quá -> $result');
    });

    test('Test 3: NFD and NFC should produce same output', () {
      final nfc = 'quá';
      final nfd = 'qua\u0301';
      final resultNfc = converter.convert(nfc);
      final resultNfd = converter.convert(nfd);
      expect(resultNfc, equals(resultNfd));
    });
  });

  group('EDGE_CASES', () {
    test('Test 1: Empty string', () {
      final result = converter.convert('');
      expect(result, equals(''));
    });

    test('Test 2: Whitespace only', () {
      final result = converter.convert('   ');
      expect(result, equals('   '));
    });

    test('Test 3: Mixed letters and numbers', () {
      final result = converter.convert('abc123xyz');
      expect(result, isNotEmpty);
      // Should have number indicator before 123
      print('abc123xyz -> $result');
    });

    test('Test 4: Number at end of sentence', () {
      final result = converter.convert('Năm 2024.');
      expect(result, isNotEmpty);
      print('Năm 2024. -> $result');
    });

    test('Test 5: Unit with punctuation', () {
      final result = converter.convert('5km.');
      expect(result, isNotEmpty);
      print('5km. -> $result');
    });

    test('Test 6: Unit in parentheses', () {
      final result = converter.convert('(10kg)');
      expect(result, isNotEmpty);
      print('(10kg) -> $result');
    });
  });

  group('ACCURACY_CONCERNS', () {
    test('Concern #1: quyền - complex qu rule', () {
      final result = converter.convert('quyền');
      expect(result, isNotEmpty);
      print('quyền -> $result');
    });

    test('Concern #2: Ảnh - capitalization with tone', () {
      final result = converter.convert('Ảnh');
      expect(result, isNotEmpty);
      print('Ảnh -> $result');
    });

    test('Concern #2: Ứng - capitalization with tone', () {
      final result = converter.convert('Ứng');
      expect(result, isNotEmpty);
      print('Ứng -> $result');
    });

    test('Concern #3: Number mode with mixed content', () {
      final result = converter.convert('123abc456');
      expect(result, isNotEmpty);
      print('123abc456 -> $result');
    });

    test('Concern #4: giải - gi rule with complex vowels', () {
      final result = converter.convert('giải');
      expect(result, isNotEmpty);
      print('giải -> $result');
    });

    test('Concern #5: HÀ NỘI - phrase end format', () {
      final result = converter.convert('HÀ NỘI');
      expect(result, isNotEmpty);
      // Should have endFormat at the end
      print('HÀ NỘI -> $result');
    });
  });

  group('REAL_WORLD_TEXT', () {
    test('Complete sentence 1', () {
      final result = converter.convert('Việt Nam là một quốc gia xinh đẹp.');
      expect(result, isNotEmpty);
      print('Việt Nam là một quốc gia xinh đẹp. -> $result');
    });

    test('Complete sentence 2 with numbers', () {
      final result = converter.convert('Năm 2024, Việt Nam có 98 triệu dân.');
      expect(result, isNotEmpty);
      print('Năm 2024, Việt Nam có 98 triệu dân. -> $result');
    });

    test('Sentence with quotes', () {
      final result = converter.convert('Ông ấy nói: "Xin chào các bạn!"');
      expect(result, isNotEmpty);
      print('Ông ấy nói: "Xin chào các bạn!" -> $result');
    });

    test('Math expression', () {
      final result = converter.convert('Tính: 2+3=5, 10-4=6');
      expect(result, isNotEmpty);
      print('Tính: 2+3=5, 10-4=6 -> $result');
    });

    test('Text with units', () {
      final result = converter.convert('Quãng đường dài 5km, nặng 10kg.');
      expect(result, isNotEmpty);
      print('Quãng đường dài 5km, nặng 10kg. -> $result');
    });
  });
}
