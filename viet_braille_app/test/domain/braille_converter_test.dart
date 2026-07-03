import 'package:flutter_test/flutter_test.dart';
import 'package:viet_braille_app/core/braille_mapping.dart';
import 'package:viet_braille_app/domain/braille_converter.dart';
import '../helpers/braille_test_helper.dart';

void main() {
  late BrailleConverter converter;

  setUp(() {
    converter = BrailleConverterImpl(BrailleMappingImpl());
  });

  // ══════════════════════════════════════════════════════════════════════
  // Empty / whitespace-only input
  // ══════════════════════════════════════════════════════════════════════
  group('edge cases', () {
    test('empty string → empty', () {
      expect(converter.convert(''), equals(''));
    });

    test('single space', () {
      expect(converter.convert(' '), equals(' '));
    });

    test('multiple spaces preserved', () {
      expect(converter.convert('a  b'), equals('$cellA  $cellB'));
    });

    test('newline preserved', () {
      expect(converter.convert('a\nb'), equals('$cellA\n$cellB'));
    });

    test('tab preserved', () {
      expect(converter.convert('a\tb'), equals('$cellA\t$cellB'));
    });

    test('unknown characters are silently skipped', () {
      // ~ still unknown; @ is now mapped
      expect(converter.convert('a~b'), equals('$cellA$cellB'));
    });
  });

  // ══════════════════════════════════════════════════════════════════════
  // Latin characters without diacritics
  // ══════════════════════════════════════════════════════════════════════
  group('plain Latin text', () {
    test('"hello" → correct Braille cells', () {
      final result = converter.convert('hello');
      expect(result, equals('$cellH$cellE$cellL$cellL$cellO'));
    });

    test('"abc" → correct Braille cells', () {
      expect(converter.convert('abc'), equals('$cellA$cellB$cellC'));
    });

    test('"xyz" → correct Braille cells', () {
      expect(converter.convert('xyz'), equals('$cellX$cellY$cellZ'));
    });

    test('single character "a"', () {
      expect(converter.convert('a'), equals(cellA));
    });

    test('entire alphabet "abcdefghijklmnopqrstuvwxyz"', () {
      final result = converter.convert('abcdefghijklmnopqrstuvwxyz');
      expect(
        result,
        equals(
          '$cellA$cellB$cellC$cellD$cellE$cellF$cellG$cellH$cellI$cellJ'
          '$cellK$cellL$cellM$cellN$cellO$cellP$cellQ$cellR$cellS$cellT'
          '$cellU$cellV$cellW$cellX$cellY$cellZ',
        ),
      );
    });
  });

  // ══════════════════════════════════════════════════════════════════════
  // Uppercase → capital indicator + lowercase
  // ══════════════════════════════════════════════════════════════════════
  group('uppercase → capital indicator + lowercase', () {
    test('"A" = capitalIndicator + a', () {
      final capitalCell = String.fromCharCode(0x2800 + 40); // dots 4,6
      expect(converter.convert('A'), equals('$capitalCell$cellA'));
    });

    test('"HELLO" translates with word-level capitalization prefix', () {
      final allCapsWord = brf('456'); // ⠸
      final expected = '$allCapsWord$cellH$cellE$cellL$cellL$cellO';
      expect(converter.convert('HELLO'), equals(expected));
    });

    test('"Việt" = capital + v + i + tone + ệ + t', () {
      final capitalCell = String.fromCharCode(0x2800 + 40);
      final expected = '$capitalCell$cellV$cellI$toneNang$cellEE$cellT';
      expect(converter.convert('Việt'), equals(expected));
    });

    test('lowercase "việt" has no capital indicator', () {
      expect(
        converter.convert('việt'),
        equals('$cellV$cellI$toneNang$cellEE$cellT'),
      );
    });

    test('"Ấ" = toneSac + capital + â (no consonant before)', () {
      // Chuẩn Braille Việt (ảnh 7): nguyên âm viết hoa không có PA đầu
      // → tone → capital → vowel (không phải capital → tone → vowel)
      final capitalCell = String.fromCharCode(0x2800 + 40); // dots 4,6
      final expected = '$toneSac$capitalCell$cellAA';
      expect(converter.convert('Ấ'), equals(expected));
    });

    test('"Ẩn" = toneHoi + capital + â + n', () {
      // "Ẩn" = hỏi + capital + â + n (nguyên âm viết hoa, không PA đầu)
      final capitalCell = String.fromCharCode(0x2800 + 40);
      final expected = '$toneHoi$capitalCell$cellAA$cellN';
      expect(converter.convert('Ẩn'), equals(expected));
    });

    test('"Á" = toneSac + capital + a (standalone uppercase vowel)', () {
      final capitalCell = String.fromCharCode(0x2800 + 40);
      final expected = '$toneSac$capitalCell$cellA';
      expect(converter.convert('Á'), equals(expected));
    });
  });

  // ══════════════════════════════════════════════════════════════════════
  // Vietnamese special vowels without tone
  // ══════════════════════════════════════════════════════════════════════
  group('Vietnamese specials (no tone)', () {
    test('ă', () => expect(converter.convert('ă'), equals(cellAW)));
    test('â', () => expect(converter.convert('â'), equals(cellAA)));
    test('ê', () => expect(converter.convert('ê'), equals(cellEE)));
    test('ô', () => expect(converter.convert('ô'), equals(cellOO)));
    test('ơ', () => expect(converter.convert('ơ'), equals(cellOW)));
    test('ư', () => expect(converter.convert('ư'), equals(cellUW)));
    test('đ', () => expect(converter.convert('đ'), equals(cellDJ)));
  });

  // ══════════════════════════════════════════════════════════════════════
  // Tone marks — tone cell appears BEFORE base vowel cell
  // ══════════════════════════════════════════════════════════════════════
  group('tone marks', () {
    test('á = toneSac + a', () {
      expect(converter.convert('á'), equals('$toneSac$cellA'));
    });
    test('à = toneHuyen + a', () {
      expect(converter.convert('à'), equals('$toneHuyen$cellA'));
    });
    test('ả = toneHoi + a', () {
      expect(converter.convert('ả'), equals('$toneHoi$cellA'));
    });
    test('ã = toneNga + a', () {
      expect(converter.convert('ã'), equals('$toneNga$cellA'));
    });
    test('ạ = toneNang + a', () {
      expect(converter.convert('ạ'), equals('$toneNang$cellA'));
    });

    test('ắ = toneSac + ă (2 cells)', () {
      expect(converter.convert('ắ'), equals('$toneSac$cellAW'));
    });
    test('ầ = toneHuyen + â (2 cells)', () {
      expect(converter.convert('ầ'), equals('$toneHuyen$cellAA'));
    });
    test('ế = toneSac + ê (2 cells)', () {
      expect(converter.convert('ế'), equals('$toneSac$cellEE'));
    });
    test('ồ = toneHuyen + ô (2 cells)', () {
      expect(converter.convert('ồ'), equals('$toneHuyen$cellOO'));
    });
    test('ớ = toneSac + ơ (2 cells)', () {
      expect(converter.convert('ớ'), equals('$toneSac$cellOW'));
    });
    test('ứ = toneSac + ư (2 cells)', () {
      expect(converter.convert('ứ'), equals('$toneSac$cellUW'));
    });
    test('ự = toneNang + ư (2 cells)', () {
      expect(converter.convert('ự'), equals('$toneNang$cellUW'));
    });
  });

  // ══════════════════════════════════════════════════════════════════════
  // Digits
  // ══════════════════════════════════════════════════════════════════════
  group('digits (1 number indicator per sequence)', () {
    test('"123" → 1 numIndicator + a + b + c', () {
      expect(
        converter.convert('123'),
        equals('$numIndicator$cellA$cellB$cellC'),
      );
    });

    test('"0" → numIndicator + j', () {
      expect(converter.convert('0'), equals('$numIndicator$cellJ'));
    });

    test('"1234567890" → 1 indicator + 10 letter cells = 11 chars', () {
      final result = converter.convert('1234567890');
      expect(result.length, equals(11));
    });

    test('"a1b2" → letter then number then letter then number', () {
      expect(
        converter.convert('a1b2'),
        equals('$cellA$numIndicator$cellA$cellB$numIndicator$cellB'),
      );
    });

    test('"12 34" → indicator+12 space indicator+34', () {
      expect(
        converter.convert('12 34'),
        equals('$numIndicator$cellA$cellB $numIndicator$cellC$cellD'),
      );
    });
  });

  // ══════════════════════════════════════════════════════════════════════
  // Punctuation
  // ══════════════════════════════════════════════════════════════════════
  group('punctuation', () {
    test('comma', () => expect(converter.convert(','), equals(comma)));
    test('period', () => expect(converter.convert('.'), equals(period)));
    test(
      'question mark',
      () => expect(converter.convert('?'), equals(question)),
    );
    test(
      'exclamation mark',
      () => expect(converter.convert('!'), equals(exclaim)),
    );
    test('colon', () => expect(converter.convert(':'), equals(colon)));
    test('semicolon', () => expect(converter.convert(';'), equals(semicolon)));
    test('single quote', () => expect(converter.convert("'"), equals(squote)));
    test(
      'double quote (at start = open quote)',
      () => expect(converter.convert('"'), equals(dquoteOpen)),
    );
    test('parentheses', () {
      expect(converter.convert('()'), equals('$lparen$rparen'));
    });
    test('dash', () => expect(converter.convert('-'), equals(dash)));
  });

  // ══════════════════════════════════════════════════════════════════════
  // Full Vietnamese sentences
  // ══════════════════════════════════════════════════════════════════════
  group('Vietnamese sentences', () {
    test('"xin chào" → correct conversion', () {
      final result = converter.convert('xin chào');
      final expected = '$cellX$cellI$cellN $cellC$cellH$toneHuyen$cellA$cellO';
      expect(result, equals(expected));
    });

    test('"Việt Nam" → correct conversion', () {
      final result = converter.convert('việt nam');
      // v-i-ệ-t- -n-a-m
      final expected = '$cellV$cellI$toneNang$cellEE$cellT $cellN$cellA$cellM';
      expect(result, equals(expected));
    });

    test('"Xin chào Việt Nam!" → full sentence', () {
      final result = converter.convert('xin chào việt nam!');
      // x-i-n- -c-h-à-o- -v-i-ệ-t- -n-a-m-!
      final expected =
          '$cellX$cellI$cellN $cellC$cellH$toneHuyen$cellA$cellO '
          '$cellV$cellI$toneNang$cellEE$cellT '
          '$cellN$cellA$cellM$exclaim';
      expect(result, equals(expected));
    });

    test('"hôm nay trời đẹp!" → multi-word with tones', () {
      final result = converter.convert('hôm nay trời đẹp!');
      // h-ô-m- -n-a-y- -t-r-ờ-i- -đ-ẹ-p-!
      final expected =
          '$cellH$cellOO$cellM $cellN$cellA$cellY '
          '$cellT$cellR$toneHuyen$cellOW$cellI '
          '$cellDJ$toneNang$cellE$cellP$exclaim';
      expect(result, equals(expected));
    });

    test('"tôi yêu Việt Nam" → sentence with ơ, ê, ư', () {
      final result = converter.convert('tôi yêu việt nam');
      // t-ô-i- -y-ê-u- -v-i-ệ-t- -n-a-m
      final expected =
          '$cellT$cellOO$cellI $cellY$cellEE$cellU '
          '$cellV$cellI$toneNang$cellEE$cellT '
          '$cellN$cellA$cellM';
      expect(result, equals(expected));
    });
  });

  // ══════════════════════════════════════════════════════════════════════
  // NFD input (decomposed Unicode) — converter should handle via normalize
  // ══════════════════════════════════════════════════════════════════════
  group('NFD decomposed input', () {
    test('NFD "chào" (a + combining) converts same as NFC', () {
      final nfc = 'chào';
      // c + h + a + U+0300 + o
      final nfd = 'cha\u0300o';
      expect(converter.convert(nfd), equals(converter.convert(nfc)));
    });

    test('NFD "đội" (multi-level decomposed) converts same as NFC', () {
      final nfc = 'đội';
      // đ + o + U+0302 (circumflex → ô) + U+0323 (dot_below → nặng) + i
      final nfd = 'đo\u0302\u0323i';
      expect(converter.convert(nfd), equals(converter.convert(nfc)));
    });

    test('NFD "xuất" converts same as NFC', () {
      final nfc = 'xuất';
      // x + u + a + U+0302 (circumflex → â) + U+0301 (acute → sắc) + t
      final nfd = 'xua\u0302\u0301t';
      expect(converter.convert(nfd), equals(converter.convert(nfc)));
    });

    test('NFD uppercase "Á" (A + combining acute) has capital indicator', () {
      // NFD: A (U+0041) + combining acute (U+0301) → should be tone + capital + a
      // Chuẩn: nguyên âm viết hoa không có PA đầu → tone → capital → vowel
      final capitalCell = String.fromCharCode(0x2800 + 40); // dots 4,6
      final nfd = 'A\u0301';
      final nfc = 'Á';
      // Cả NFD và NFC đều phải cho cùng kết quả
      expect(converter.convert(nfd), equals(converter.convert(nfc)));
      expect(converter.convert(nfc), equals('$toneSac$capitalCell$cellA'));
    });

    test('NFD uppercase "Ậ" (A + circumflex + dot below) has capital', () {
      // Chuẩn: nguyên âm viết hoa không có PA đầu → tone → capital → vowel
      final capitalCell = String.fromCharCode(0x2800 + 40);
      final nfd = 'A\u0302\u0323'; // A + circumflex + dot_below
      final nfc = 'Ậ';
      expect(converter.convert(nfd), equals(converter.convert(nfc)));
      expect(converter.convert(nfc), equals('$toneNang$capitalCell$cellAA'));
    });

    test('NFD uppercase word "Xin Chào" preserves capitals', () {
      // "Chào" in NFD = C + h + a + U+0300 + o
      final nfd = 'Xin Cha\u0300o';
      final nfc = 'Xin Chào';
      expect(converter.convert(nfd), equals(converter.convert(nfc)));
    });
  });

  // ══════════════════════════════════════════════════════════════════════
  // Multi-line text
  // ══════════════════════════════════════════════════════════════════════
  group('multi-line text', () {
    test('newlines preserved in output', () {
      final result = converter.convert('hello\nworld');
      expect(
        result,
        equals(
          '$cellH$cellE$cellL$cellL$cellO\n$cellW$cellO$cellR$cellL$cellD',
        ),
      );
    });

    test('multiple newlines preserved', () {
      final result = converter.convert('a\n\nb');
      expect(result, equals('$cellA\n\n$cellB'));
    });
  });

  // ══════════════════════════════════════════════════════════════════════
  // Mixed content: letters + digits + punctuation
  // ══════════════════════════════════════════════════════════════════════
  group('mixed content', () {
    test('"a1b" → letter + digit + letter', () {
      expect(
        converter.convert('a1b'),
        equals('$cellA$numIndicator$cellA$cellB'),
      );
    });

    test('"hello, world!" → letters + punctuation + space', () {
      final result = converter.convert('hello, world!');
      final expected =
          '$cellH$cellE$cellL$cellL$cellO$comma '
          '$cellW$cellO$cellR$cellL$cellD$exclaim';
      expect(result, equals(expected));
    });

    test('"giá: 100đ" → Vietnamese + digits + currency (gi rule)', () {
      final result = converter.convert('giá: 100đ');
      // g-i-a+tone-:- -1-0-0-đ (tone goes AFTER i per gi rule)
      final expected =
          '$cellG$cellI$toneSac$cellA$colon '
          '$numIndicator$cellA$cellJ$cellJ$cellDJ';
      expect(result, equals(expected));
    });
  });

  // ══════════════════════════════════════════════════════════════════════
  // qu/gi rule: tone goes AFTER u/i per Vietnamese Braille standard
  // ══════════════════════════════════════════════════════════════════════
  group('qu/gi rule (tone after u/i)', () {
    test('"quán" = q-u-toneSac-a-n (tone after u, not before a)', () {
      final result = converter.convert('quán');
      final expected = '$cellQ$cellU$toneSac$cellA$cellN';
      expect(result, equals(expected));
    });

    test('"quản" = q-u-toneHoi-a-n', () {
      final result = converter.convert('quản');
      final expected = '$cellQ$cellU$toneHoi$cellA$cellN';
      expect(result, equals(expected));
    });

    test('"quý" = q-u-y+tone (no qu rule, tone on y)', () {
      final result = converter.convert('quý');
      final expected = '$cellQ$cellU$toneSac$cellY';
      expect(result, equals(expected));
    });

    test('"quỷ" = q-u-toneHoi-y (qu rule: tone after u)', () {
      final result = converter.convert('quỷ');
      final expected = '$cellQ$cellU$toneHoi$cellY';
      expect(result, equals(expected));
    });

    test('"giá" = g-i-toneSac-a (tone after i, not before a)', () {
      final result = converter.convert('giá');
      final expected = '$cellG$cellI$toneSac$cellA';
      expect(result, equals(expected));
    });

    test('"già" = g-i-toneHuyen-a', () {
      final result = converter.convert('già');
      final expected = '$cellG$cellI$toneHuyen$cellA';
      expect(result, equals(expected));
    });

    test('"gì" = g-toneHuyen-i (standalone, tone before i per rule)', () {
      final result = converter.convert('gì');
      final expected = '$cellG$toneHuyen$cellI';
      expect(result, equals(expected));
    });

    test('"gìn" = g-toneHuyen-i-n', () {
      final result = converter.convert('gìn');
      final expected = '$cellG$toneHuyen$cellI$cellN';
      expect(result, equals(expected));
    });

    test('"Quán" capital = capitalIndicator + q-u-toneSac-a-n', () {
      final capitalCell = String.fromCharCode(0x2800 + 40);
      final result = converter.convert('Quán');
      final expected = '$capitalCell$cellQ$cellU$toneSac$cellA$cellN';
      expect(result, equals(expected));
    });

    test('"múa" (no qu/gi) = m-u-toneSac-a (tone before u normally)', () {
      final result = converter.convert('múa');
      final expected = '$cellM$toneSac$cellU$cellA';
      expect(result, equals(expected));
    });
  });

  // ══════════════════════════════════════════════════════════════════════
  // Decimal numbers: period between digits stays in number mode
  // ══════════════════════════════════════════════════════════════════════
  group('decimal numbers', () {
    test('"3.14" → single number mode with period', () {
      final result = converter.convert('3.14');
      // numIndicator + c + dots3 + a + d (all in one number mode)
      expect(result, equals('$numIndicator$cellC${brf('3')}$cellA$cellD'));
    });

    test('"12." at end → period as sentence end', () {
      final result = converter.convert('12.');
      // numIndicator + a + b + period (period as punctuation)
      expect(result, equals('$numIndicator$cellA$cellB$period'));
    });

    test('"12. text" → period + space + text', () {
      final result = converter.convert('12. ab');
      expect(result, equals('$numIndicator$cellA$cellB$period $cellA$cellB'));
    });

    test('"1.2.3" → decimal chain', () {
      final result = converter.convert('1.2.3');
      expect(
        result,
        equals('$numIndicator$cellA${brf('3')}$cellB${brf('3')}$cellC'),
      );
    });
  });

  // ══════════════════════════════════════════════════════════════════════
  // Output validation: all output chars are either Braille (U+2800-U+28FF)
  // or whitespace (space/newline/tab/CR)
  // ══════════════════════════════════════════════════════════════════════
  group('output format validation', () {
    test('all output chars are Braille Unicode or whitespace', () {
      final inputs = [
        'hello',
        'xin chào việt nam',
        '123 abc!?',
        'đội ngũ ưng ý',
        'á à ả ã ạ',
        'ắ ằ ẳ ẵ ặ',
        'quán quản giá già',
      ];
      for (final input in inputs) {
        final result = converter.convert(input);
        for (int i = 0; i < result.length; i++) {
          final codeUnit = result.codeUnitAt(i);
          final isBraille = codeUnit >= 0x2800 && codeUnit <= 0x28FF;
          final isWhitespace =
              codeUnit == 0x20 ||
              codeUnit == 0x0A ||
              codeUnit == 0x09 ||
              codeUnit == 0x0D;
          expect(
            isBraille || isWhitespace,
            isTrue,
            reason:
                'Char at index $i in "$result" (from "$input") '
                'is U+${codeUnit.toRadixString(16).padLeft(4, '0')} — '
                'not Braille or whitespace',
          );
        }
      }
    });
  });
}
