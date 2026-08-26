import 'package:test/test.dart';
import 'package:viet_braille_core/viet_braille_core.dart';

void main() {
  late BrailleConverter converter;

  setUp(() {
    converter = BrailleConverterImpl(BrailleMappingImpl());
  });

  group('Bug Fixes Verification', () {
    test('Bug #2 - All caps phrase grouping (HÀ NỘI)', () {
      // ⠨⠨ (allCapsPhrase) + HÀ NỘI + ⠱ (endFormat)
      expect(converter.convert('HÀ NỘI'), '⠨⠨⠓⠰⠁ ⠝⠠⠹⠊⠱');
    });

    test('Bug #2 - Toned final vowel keeps phrase end marker', () {
      expect(converter.convert('HÀ QUÝ'), '⠨⠨⠓⠰⠁ ⠟⠥⠔⠽⠱');
    });

    test('Bug #2 - All caps phrase with spaces (THÔNG TƯ SỐ 15)', () {
      // ⠨⠨ + thôngthư số ⠱ + ⠼ number 15
      expect(converter.convert('THÔNG TƯ SỐ 15'), '⠨⠨⠞⠓⠹⠝⠛ ⠞⠳ ⠎⠔⠹⠱ ⠼⠁⠑');
    });

    test('Bug #2 - Single word all caps (UNESCO)', () {
      // ⠸ (allCapsWord) + u n e s c o
      expect(converter.convert('UNESCO'), '⠸⠥⠝⠑⠎⠉⠕');
    });

    test('Bug #7 - Operator space removal doesn\'t cause infinite loop', () {
      final result = converter.convert('2  +  3  *  4');
      expect(result, '⠼⠃⠐⠖⠼⠉⠦⠼⠙');
    });

    test('Bug #7 - Multiple nested operators', () {
      final result = converter.convert('1 + 2 + 3 + 4 + 5 + 6 + 7 + 8');
      expect(
        result,
        '⠼⠁⠐⠖⠼⠃⠐⠖⠼⠉⠐⠖⠼⠙⠐⠖'
        '⠼⠑⠐⠖⠼⠋⠐⠖⠼⠛⠐⠖⠼⠓',
      );
    });

    test('Bug #7 - Textual operators keep intentional spaces', () {
      expect(converter.convert('a + b'), '⠁ ⠐⠖ ⠃');
    });

    test('Bug #7 - Numeric comparison chain removes every space', () {
      expect(converter.convert('1 < 2 > 0'), '⠼⠁⠐⠪⠼⠃⠐⠕⠼⠚');
    });
  });

  group('NUMBERS', () {
    test('Integer 123 → number indicator + 1 2 3', () {
      expect(converter.convert('123'), '⠼⠁⠃⠉');
    });

    test('Decimal 3.14 → number 3, dot-3 separator, 1 4', () {
      expect(converter.convert('3.14'), '⠼⠉⠄⠁⠙');
    });

    test('Thousands 1,234.56 → number 1,2,3,4 dot 5 6', () {
      expect(converter.convert('1,234.56'), '⠼⠁⠂⠃⠉⠙⠄⠑⠋');
    });
  });

  group('QU_RULE', () {
    test('quá - dấu sau u', () {
      // q + u + sac + a
      expect(converter.convert('quá'), '⠟⠥⠔⠁');
    });

    test('quyết - dấu sắc sau u, trước y', () {
      // q + u + sac + y + ê + t
      expect(converter.convert('quyết'), '⠟⠥⠔⠽⠣⠞');
    });

    test('Quý viết hoa - capital trước q', () {
      // capital + q + u + sac + y
      expect(converter.convert('Quý'), '⠨⠟⠥⠔⠽');
    });
  });

  group('GI_RULE', () {
    test('giá - dấu giữa g và i', () {
      // g + sac + i + a
      expect(converter.convert('giá'), '⠛⠊⠔⠁');
    });

    test('gió - dấu sắc giữa g và i', () {
      // g + sac + i + o
      expect(converter.convert('gió'), '⠛⠊⠔⠕');
    });

    test('Giảng viết hoa', () {
      // capital + g + hoi + i + ă + n + g
      expect(converter.convert('Giảng'), '⠨⠛⠊⠢⠁⠝⠛');
    });
  });

  group('CAPITALIZATION_SINGLE', () {
    test('Việt - viết hoa chữ cái đầu có phụ âm', () {
      // capital + v + i + ê + t  (lossless? no, standard)
      // Standard: capital + v + nặng + i + ê + t
      expect(converter.convert('Việt'), '⠨⠧⠠⠊⠣⠞');
    });

    test('Ấn - viết hoa nguyên âm không phụ âm đầu', () {
      // sac + capital + â + n
      expect(converter.convert('Ấn'), '⠔⠨⠡⠝');
    });
  });

  group('CAPITALIZATION_WORD', () {
    test('UNESCO - từ viết hoa toàn bộ', () {
      expect(converter.convert('UNESCO'), '⠸⠥⠝⠑⠎⠉⠕');
    });

    test('II - số La Mã', () {
      // capital + i + i
      expect(converter.convert('II'), '⠨⠊⠊');
    });

    test('XVI - số La Mã', () {
      // capital + x + v + i
      expect(converter.convert('XVI'), '⠨⠭⠧⠊');
    });
  });

  group('CAPITALIZATION_PHRASE', () {
    test('THÔNG TƯ SỐ 15 - cụm từ viết hoa toàn bộ', () {
      expect(converter.convert('THÔNG TƯ SỐ 15'), '⠨⠨⠞⠓⠹⠝⠛ ⠞⠳ ⠎⠔⠹⠱ ⠼⠁⠑');
    });

    test('Hà Nội - cụm từ viết hoa chữ cái đầu', () {
      // initCapsPhrase ⠒⠨ + Hà Nội + ⠱
      expect(converter.convert('Hà Nội'), '⠒⠨⠓⠰⠁ ⠝⠠⠹⠊⠱');
    });
  });

  group('STANDALONE_VOWEL', () {
    test('ấn - nguyên âm có dấu đứng đầu', () {
      // sac + â + n
      expect(converter.convert('ấn'), '⠔⠡⠝');
    });

    test('ảnh - dấu hỏi trước a', () {
      // hoi + a + n + h
      expect(converter.convert('ảnh'), '⠢⠁⠝⠓');
    });
  });

  group('PUNCTUATION', () {
    test('"Xin chào" - ngoặc kép', () {
      // open quote + ... + close quote
      expect(converter.convert('"Xin chào"'), '⠦⠨⠭⠊⠝ ⠉⠓⠰⠁⠕⠴');
    });

    test('a...b - dấu chấm lửng', () {
      // a + dot3 + dot3 + dot3 + b
      expect(converter.convert('a...b'), '⠁⠄⠄⠄⠃');
    });

    test('(a) - ngoặc đơn', () {
      // ( + a + )
      expect(converter.convert('(a)'), '⠈⠣⠁⠈⠜');
    });
  });

  group('UNITS', () {
    test('5km - đơn vị km', () {
      // number 5 + space + k + m
      expect(converter.convert('5km'), '⠼⠑ ⠅⠍');
    });

    test('10kg - đơn vị kg', () {
      // number 10 + space + k + g
      expect(converter.convert('10kg'), '⠼⠁⠚ ⠅⠛');
    });
  });

  group('MATH', () {
    test('2+3=5 - phép cộng', () {
      // number 2 + plus + number 3 + equal + number 5
      expect(converter.convert('2+3=5'), '⠼⠃⠐⠖⠼⠉⠐⠶⠼⠑');
    });

    test('a + b - phép toán với chữ', () {
      expect(converter.convert('a + b'), '⠁ ⠐⠖ ⠃');
    });
  });

  group('NFD_INPUT', () {
    test('NFD á (a + combining acute)', () {
      final nfd = 'a\u0301'; // a + combining acute
      final result = converter.convert(nfd);
      expect(result, '⠔⠁');
    });

    test('NFD quá', () {
      final nfd = 'qua\u0301'; // qu + a + combining acute
      final result = converter.convert(nfd);
      expect(result, '⠟⠥⠔⠁');
    });

    test('NFD and NFC should produce same output', () {
      final nfc = 'quá';
      final nfd = 'qua\u0301';
      final resultNfc = converter.convert(nfc);
      final resultNfd = converter.convert(nfd);
      expect(resultNfc, equals(resultNfd));
    });
  });

  group('EDGE_CASES', () {
    test('Empty string', () {
      final result = converter.convert('');
      expect(result, equals(''));
    });

    test('Whitespace only', () {
      final result = converter.convert('   ');
      expect(result, equals('   '));
    });

    test('Mixed letters and numbers', () {
      // a b c + number 1 2 3 + x y z
      expect(converter.convert('abc123xyz'), '⠁⠃⠉⠼⠁⠃⠉⠭⠽⠵');
    });

    test('Number at end of sentence', () {
      // Năm + number 2024 + period
      expect(converter.convert('Năm 2024.'), '⠨⠝⠜⠍ ⠼⠃⠚⠃⠙⠲');
    });

    test('Unit with punctuation', () {
      // number 5 + space + k + m + period
      expect(converter.convert('5km.'), '⠼⠑ ⠅⠍⠲');
    });

    test('Unit in parentheses', () {
      // ( + number 10 + space + k + g + )
      expect(converter.convert('(10kg)'), '⠈⠣⠼⠁⠚ ⠅⠛⠈⠜');
    });
  });

  group('ACCURACY_CONCERNS', () {
    test('Concern #1: quyền - complex qu rule', () {
      // q + u + huyen + y + ê + n
      expect(converter.convert('quyền'), '⠟⠥⠰⠽⠣⠝');
    });

    test('Concern #2: Ảnh - capitalization with tone', () {
      // hoi + capital + a + n + h
      expect(converter.convert('Ảnh'), '⠢⠨⠁⠝⠓');
    });

    test('Concern #2: Ứng - capitalization with tone', () {
      // sac + capital + ư + n + g
      expect(converter.convert('Ứng'), '⠔⠨⠳⠝⠛');
    });

    test('Concern #3: Number mode with mixed content', () {
      // number 123 + a + b + c + number 456
      expect(converter.convert('123abc456'), '⠼⠁⠃⠉⠁⠃⠉⠼⠙⠑⠋');
    });

    test('Concern #4: giải - gi rule with complex vowels', () {
      // g + i + hoi + a + i
      expect(converter.convert('giải'), '⠛⠊⠢⠁⠊');
    });

    test('Concern #5: HÀ NỘI - phrase end format', () {
      expect(converter.convert('HÀ NỘI'), '⠨⠨⠓⠰⠁ ⠝⠠⠹⠊⠱');
    });
  });

  group('REAL_WORLD_TEXT', () {
    test('Complete sentence 1', () {
      expect(
        converter.convert('Việt Nam là một quốc gia xinh đẹp.'),
        '⠒⠨⠧⠠⠊⠣⠞ ⠝⠁⠍⠱ ⠇⠰⠁ ⠍⠠⠹⠞ ⠟⠥⠔⠹⠉ ⠛⠊⠁ ⠭⠊⠝⠓ ⠮⠠⠑⠏⠲',
      );
    });

    test('Complete sentence 2 with numbers', () {
      expect(
        converter.convert('Năm 2024, Việt Nam có 98 triệu dân.'),
        '⠨⠝⠜⠍ ⠼⠃⠚⠃⠙⠂ ⠒⠨⠧⠠⠊⠣⠞ ⠝⠁⠍⠱ '
        '⠉⠔⠕ ⠼⠊⠓ ⠞⠗⠠⠊⠣⠥ ⠙⠡⠝⠲',
      );
    });

    test('Sentence with quotes', () {
      expect(
        converter.convert('Ông ấy nói: "Xin chào các bạn!"'),
        '⠨⠹⠝⠛ ⠔⠡⠽ ⠝⠔⠕⠊⠒ ⠦⠨⠭⠊⠝ ⠉⠓⠰⠁⠕ ⠉⠔⠁⠉ ⠃⠠⠁⠝⠖⠴',
      );
    });

    test('Math expression', () {
      expect(
        converter.convert('Tính: 2+3=5, 10-4=6'),
        '⠨⠞⠔⠊⠝⠓⠒ ⠼⠃⠐⠖⠼⠉⠐⠶⠼⠑⠂ ⠼⠁⠚⠤⠼⠙⠐⠶⠼⠋',
      );
    });

    test('Text with units', () {
      expect(
        converter.convert('Quãng đường dài 5km, nặng 10kg.'),
        '⠨⠟⠥⠤⠁⠝⠛ ⠮⠰⠳⠪⠝⠛ ⠙⠰⠁⠊ ⠼⠑ ⠅⠍⠂ ⠝⠠⠜⠝⠛ ⠼⠁⠚ ⠅⠛⠲',
      );
    });
  });

  group('EXTENDED_CONSONANTS_WFJZ', () {
    test('Wifi', () {
      expect(converter.convert('Wifi'), '⠨⠺⠊⠋⠊');
    });

    test('WiFi', () {
      expect(converter.convert('WiFi'), '⠨⠺⠊⠨⠋⠊');
    });

    test('Zoom', () {
      expect(converter.convert('Zoom'), '⠨⠵⠕⠕⠍');
    });

    test('Facebook', () {
      expect(converter.convert('Facebook'), '⠨⠋⠁⠉⠑⠃⠕⠕⠅');
    });

    test('Jazz', () {
      expect(converter.convert('Jazz'), '⠨⠚⠁⠵⠵');
    });

    test('FIFA', () {
      expect(converter.convert('FIFA'), '⠸⠋⠊⠋⠁');
    });

    test('Jaguar', () {
      expect(converter.convert('Jaguar'), '⠨⠚⠁⠛⠥⠁⠗');
    });

    test('Web', () {
      expect(converter.convert('Web'), '⠨⠺⠑⠃');
    });
  });
}
