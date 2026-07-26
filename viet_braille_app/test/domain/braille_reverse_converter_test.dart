import 'package:flutter_test/flutter_test.dart';
import 'package:viet_braille_core/viet_braille_core.dart';
import '../helpers/braille_test_helper.dart';

void main() {
  late BrailleReverseConverterImpl converter;

  setUp(() {
    converter = BrailleReverseConverterImpl(BrailleMappingImpl());
  });

  group('basic single-cell characters', () {
    test('Latin letter "a"', () {
      expect(converter.convert(cellA), equals('a'));
    });

    test('Latin letter "b"', () {
      expect(converter.convert(cellB), equals('b'));
    });

    test('Latin letter "c"', () {
      expect(converter.convert(cellC), equals('c'));
    });

    test('single word "abc"', () {
      expect(converter.convert('$cellA$cellB$cellC'), equals('abc'));
    });

    test('single word "hello"', () {
      final braille = '$cellH$cellE$cellL$cellL$cellO';
      expect(converter.convert(braille), equals('hello'));
    });
  });

  group('whitespace', () {
    test('space preserved', () {
      expect(converter.convert('$cellA $cellB'), equals('a b'));
    });

    test('newline preserved', () {
      expect(converter.convert('$cellA\n$cellB'), equals('a\nb'));
    });
  });

  group('Vietnamese special characters (no tone)', () {
    test('đ', () {
      expect(converter.convert(cellDJ), equals('đ'));
    });

    test('ă', () {
      expect(converter.convert(cellAW), equals('ă'));
    });

    test('â', () {
      expect(converter.convert(cellAA), equals('â'));
    });

    test('ê', () {
      expect(converter.convert(cellEE), equals('ê'));
    });

    test('ô', () {
      expect(converter.convert(cellOO), equals('ô'));
    });

    test('ơ', () {
      expect(converter.convert(cellOW), equals('ơ'));
    });

    test('ư', () {
      expect(converter.convert(cellUW), equals('ư'));
    });
  });

  group('capital indicator (dots 4,6)', () {
    final capitalCell = String.fromCharCode(0x2800 + 40); // dots 4,6

    test('capital + a → A', () {
      expect(converter.convert('$capitalCell$cellA'), equals('A'));
    });

    test('capital + b → B', () {
      expect(converter.convert('$capitalCell$cellB'), equals('B'));
    });

    test('capital + đ → Đ', () {
      expect(converter.convert('$capitalCell$cellDJ'), equals('Đ'));
    });
  });

  group('digits (number mode)', () {
    test('numIndicator + a → "1"', () {
      expect(converter.convert('$numIndicator$cellA'), equals('1'));
    });

    test('numIndicator + a + b + c → "123"', () {
      expect(
        converter.convert('$numIndicator$cellA$cellB$cellC'),
        equals('123'),
      );
    });

    test('numIndicator + j → "0"', () {
      expect(converter.convert('$numIndicator$cellJ'), equals('0'));
    });

    test('numIndicator + full sequence → "1234567890"', () {
      final braille =
          '$numIndicator$cellA$cellB$cellC$cellD$cellE'
          '$cellF$cellG$cellH$cellI$cellJ';
      expect(converter.convert(braille), equals('1234567890'));
    });

    test('number + space + number → two separate numbers', () {
      final braille = '$numIndicator$cellA$cellB $numIndicator$cellC$cellD';
      expect(converter.convert(braille), equals('12 34'));
    });
  });

  group('tone marks (tone cell + vowel cell)', () {
    test('sắc + a → á', () {
      expect(converter.convert('$toneSac$cellA'), equals('á'));
    });

    test('huyền + a → à', () {
      expect(converter.convert('$toneHuyen$cellA'), equals('à'));
    });

    test('hỏi + a → ả', () {
      expect(converter.convert('$toneHoi$cellA'), equals('ả'));
    });

    test('ngã + a → ã', () {
      expect(converter.convert('$toneNga$cellA'), equals('ã'));
    });

    test('nặng + a → ạ', () {
      expect(converter.convert('$toneNang$cellA'), equals('ạ'));
    });

    test('sắc + ê → ế', () {
      expect(converter.convert('$toneSac$cellEE'), equals('ế'));
    });

    test('nặng + ê → ệ', () {
      expect(converter.convert('$toneNang$cellEE'), equals('ệ'));
    });

    test('huyền + ơ → ờ', () {
      expect(converter.convert('$toneHuyen$cellOW'), equals('ờ'));
    });
  });

  group('multi-cell punctuation', () {
    test('open paren → (', () {
      expect(converter.convert(lparen), equals('('));
    });

    test('close paren → )', () {
      expect(converter.convert(rparen), equals(')'));
    });

    test('slash → /', () {
      expect(converter.convert(slash), equals('/'));
    });

    test('underscore → _', () {
      expect(converter.convert(underscore), equals('_'));
    });

    test('backslash → \\', () {
      expect(converter.convert(backslash), equals('\\'));
    });

    test('open double quote → "', () {
      // Standalone ⠦ now decodes to * to disambiguate from double quote.
      // We test double quote with a following letter context.
      expect(converter.convert('$dquoteOpen$cellA'), equals('"a'));
    });

    test('close double quote → "', () {
      expect(converter.convert(dquoteClose), equals('"'));
    });
  });

  group('multi-cell math symbols', () {
    test('plus → +', () {
      expect(converter.convert(plus), equals('+'));
    });

    test('equal → =', () {
      expect(converter.convert(equal), equals('='));
    });

    test('star → *', () {
      expect(converter.convert(star), equals('*'));
    });

    test('less than → <', () {
      expect(converter.convert(lt), equals('<'));
    });

    test('greater than → >', () {
      expect(converter.convert(gt), equals('>'));
    });
  });

  group('multi-cell special symbols', () {
    test('# → 2 cells (specialPrefix + numIndicator)', () {
      final braille = '$specialPrefix$numIndicator';
      expect(converter.convert(braille), equals('#'));
    });

    test('% → 3 cells', () {
      final mapping = BrailleMappingImpl();
      final braille = mapping.mapChar('%')!;
      expect(converter.convert(braille), equals('%'));
    });

    test('@ → 2 cells', () {
      final mapping = BrailleMappingImpl();
      final braille = mapping.mapChar('@')!;
      expect(converter.convert(braille), equals('@'));
    });

    test('\$ → 2 cells', () {
      final mapping = BrailleMappingImpl();
      final braille = mapping.mapChar('\$')!;
      expect(converter.convert(braille), equals('\$'));
    });

    test('& → 2 cells', () {
      final mapping = BrailleMappingImpl();
      final braille = mapping.mapChar('&')!;
      expect(converter.convert(braille), equals('&'));
    });

    test('[ → 2 cells', () {
      final mapping = BrailleMappingImpl();
      final braille = mapping.mapChar('[')!;
      expect(converter.convert(braille), equals('['));
    });

    test('] → 2 cells', () {
      final mapping = BrailleMappingImpl();
      final braille = mapping.mapChar(']')!;
      expect(converter.convert(braille), equals(']'));
    });
  });

  group('unknown cells', () {
    test('unknown Braille cell preserved as-is', () {
      final unknown = String.fromCharCode(0x28FF);
      expect(converter.convert(unknown), equals(unknown));
    });

    test('empty string returns empty', () {
      expect(converter.convert(''), equals(''));
    });
  });

  group('mixed content', () {
    test('"hello" reverse converts correctly', () {
      final braille = '$cellH$cellE$cellL$cellL$cellO';
      expect(converter.convert(braille), equals('hello'));
    });

    test('whitespace between words preserved', () {
      final braille = '$cellH$cellI $cellY$cellO$cellU';
      expect(converter.convert(braille), equals('hi you'));
    });

    test('roundtrip: "xin chào"', () {
      final mapping = BrailleMappingImpl();
      final forward = BrailleConverterImpl(mapping);
      final braille = forward.convert('xin chào');
      expect(converter.convert(braille), equals('xin chào'));
    });

    test('roundtrip: "việt nam"', () {
      final mapping = BrailleMappingImpl();
      final forward = BrailleConverterImpl(mapping);
      final braille = forward.convert('việt nam');
      expect(converter.convert(braille), equals('việt nam'));
    });
  });

  group('qu/gi rule (reverse)', () {
    test('roundtrip: "quán"', () {
      final mapping = BrailleMappingImpl();
      final forward = BrailleConverterImpl(mapping);
      final braille = forward.convert('quán');
      expect(converter.convert(braille), equals('quán'));
    });

    test('roundtrip: "quản"', () {
      final mapping = BrailleMappingImpl();
      final forward = BrailleConverterImpl(mapping);
      final braille = forward.convert('quản');
      expect(converter.convert(braille), equals('quản'));
    });

    test('roundtrip: "giá"', () {
      final mapping = BrailleMappingImpl();
      final forward = BrailleConverterImpl(mapping);
      final braille = forward.convert('giá');
      expect(converter.convert(braille), equals('giá'));
    });

    test('roundtrip: "gì"', () {
      final mapping = BrailleMappingImpl();
      final forward = BrailleConverterImpl(mapping);
      final braille = forward.convert('gì');
      expect(converter.convert(braille), equals('gì'));
    });

    test('roundtrip: "quán quản giá già"', () {
      final mapping = BrailleMappingImpl();
      final forward = BrailleConverterImpl(mapping);
      final braille = forward.convert('quán quản giá già');
      expect(converter.convert(braille), equals('quán quản giá già'));
    });

    test('roundtrip: "Quán" (capital)', () {
      final mapping = BrailleMappingImpl();
      final forward = BrailleConverterImpl(mapping);
      final braille = forward.convert('Quán');
      expect(converter.convert(braille), equals('Quán'));
    });

    test('"múa" not affected by qu/gi rule', () {
      final mapping = BrailleMappingImpl();
      final forward = BrailleConverterImpl(mapping);
      final braille = forward.convert('múa');
      expect(converter.convert(braille), equals('múa'));
    });
  });

  group('decimal numbers (reverse)', () {
    test('roundtrip: "3.14"', () {
      final mapping = BrailleMappingImpl();
      final forward = BrailleConverterImpl(mapping);
      final braille = forward.convert('3.14');
      // Reverse: in number mode, digits and period should stay
      final result = converter.convert(braille);
      expect(result, contains('3'));
      expect(result, contains('14'));
    });
  });

  group('collision disambiguation (? ↔ hỏi, - ↔ ngã)', () {
    test('? standalone → "?" (not hỏi tone)', () {
      // ? = dots 2,6 = same cell as hỏi. Without vowel context → punctuation.
      expect(converter.convert(question), equals('?'));
    });

    test('- standalone → "-" (not ngã tone)', () {
      // - = dots 3,6 = same cell as ngã. Without vowel context → punctuation.
      expect(converter.convert(dash), equals('-'));
    });

    test('hỏi + vowel → toned vowel (not punctuation)', () {
      // hỏi cell + a cell → ả
      expect(converter.convert('$toneHoi$cellA'), equals('ả'));
    });

    test('ngã + vowel → toned vowel (not punctuation)', () {
      // ngã cell + a cell → ã
      expect(converter.convert('$toneNga$cellA'), equals('ã'));
    });

    test('roundtrip: "bao nhiêu?" preserves question mark', () {
      final mapping = BrailleMappingImpl();
      final forward = BrailleConverterImpl(mapping);
      final braille = forward.convert('bao nhiêu?');
      final result = converter.convert(braille);
      expect(result, equals('bao nhiêu?'));
    });

    test('roundtrip: "cà-phè" preserves hyphen', () {
      final mapping = BrailleMappingImpl();
      final forward = BrailleConverterImpl(mapping);
      final braille = forward.convert('cà-phè');
      final result = converter.convert(braille);
      expect(result, equals('cà-phè'));
    });

    test('roundtrip: "tại sao?" with hỏi tone + question mark', () {
      final mapping = BrailleMappingImpl();
      final forward = BrailleConverterImpl(mapping);
      // "tại sao?" — "sao" has hỏi tone, "?" is punctuation
      final braille = forward.convert('tại sao?');
      final result = converter.convert(braille);
      expect(result, equals('tại sao?'));
    });

    test('roundtrip: "không?" with hỏi on o + question mark', () {
      final mapping = BrailleMappingImpl();
      final forward = BrailleConverterImpl(mapping);
      // "không?" — "không" has grave tone (huyền), "?" is question mark
      final braille = forward.convert('không?');
      final result = converter.convert(braille);
      expect(result, equals('không?'));
    });

    test('roundtrip: "thủy - thủy" with huyền on u + hyphen + huyền on u', () {
      final mapping = BrailleMappingImpl();
      final forward = BrailleConverterImpl(mapping);
      // "thủy - thủy" — tone huyền on y, hyphen, tone huyền on y
      final braille = forward.convert('thủy - thủy');
      final result = converter.convert(braille);
      expect(result, equals('thủy - thủy'));
    });
  });

  // ══════════════════════════════════════════════════════════════════════
  // State isolation between convert() calls
  // ══════════════════════════════════════════════════════════════════════
  group('state isolation between convert() calls', () {
    test('consecutive calls do not leak capitalization state', () {
      // First call: all-caps phrase
      final allCapsBraille =
          '${brf('46')}${brf('46')}$cellH$cellE$cellL$cellL$cellO${brf('156')}';
      final result1 = converter.convert(allCapsBraille);
      expect(result1, equals('HELLO'));

      // Second call: should NOT inherit allCaps state from first call
      final result2 = converter.convert('$cellA$cellB$cellC');
      expect(result2, equals('abc'));
    });

    test('consecutive calls do not leak number mode state', () {
      // First call: number mode
      final numBraille = '$numIndicator$cellA$cellB$cellC';
      final result1 = converter.convert(numBraille);
      expect(result1, equals('123'));

      // Second call: should NOT inherit number mode
      final result2 = converter.convert('$cellA$cellB$cellC');
      expect(result2, equals('abc'));
    });

    test('consecutive calls do not leak word start state', () {
      // First call with capital
      final result1 = converter.convert('$bracketPrefix$cellA');
      expect(result1, equals('A'));

      // Second call: isWordStart should be true by default
      final result2 = converter.convert('$cellA$cellB');
      expect(result2, equals('ab'));
    });
  });
}
