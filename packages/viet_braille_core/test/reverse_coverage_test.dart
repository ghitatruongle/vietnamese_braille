import 'package:test/test.dart';
import 'package:viet_braille_core/viet_braille_core.dart';

void main() {
  late BrailleMappingImpl mapping;
  late BrailleConverterImpl forward;
  late BrailleReverseConverterImpl reverse;

  setUp(() {
    mapping = BrailleMappingImpl();
    forward = BrailleConverterImpl(mapping);
    reverse = BrailleReverseConverterImpl(mapping);
  });

  group('reverse converter coverage', () {
    test('round-trips representative text, tone and capitalization rules', () {
      const samples = [
        'abc',
        'xin chào',
        'Việt Nam',
        'VIỆT NAM',
        'UNESCO',
        'II',
        'Ấn',
        'quán',
        'quản',
        'quyết',
        'quyền',
        'giá',
        'gì',
        'giảng giải',
        'múa',
        'hòa',
        'khỏe',
        'thủy',
        'việt đường',
        '123',
        '3.14',
        '1,25',
      ];

      for (final input in samples) {
        final braille = forward.convert(input);
        expect(
          reverse.convert(braille).toLowerCase(),
          input.toLowerCase(),
          reason: input,
        );
      }
    });

    test('decodes supported punctuation and symbol prefixes', () {
      const samples = [
        '()',
        '[]',
        '{}',
        r'\',
        '/',
        '_',
        r'$',
        '&',
        '+',
        '=',
        '<',
        '>',
        '#',
        '%',
        '@',
        '|',
        '^',
        '"abc"',
        '...',
      ];

      for (final input in samples) {
        final braille = forward.convert(input);
        final decoded = reverse.convert(braille);
        expect(decoded, isNotEmpty, reason: input);
      }
    });

    test('lossless punctuation validates escape marker payload', () {
      for (final input in ['a-a', 'a?a', 'Có? Ai']) {
        final braille = forward.convert(
          input,
          mode: BrailleConversionMode.lossless,
        );
        expect(
          reverse.convert(braille, mode: BrailleConversionMode.lossless),
          input,
        );
      }

      expect(
        () => reverse.convert(
          losslessBrailleEscape,
          mode: BrailleConversionMode.lossless,
        ),
        throwsFormatException,
      );
      expect(
        () => reverse.convert(
          '$losslessBrailleEscape${mapping.mapChar("a")}',
          mode: BrailleConversionMode.lossless,
        ),
        throwsFormatException,
      );
    });

    test('preserves whitespace, raw cells and isolated markers', () {
      expect(reverse.convert(' \n\t\r'), ' \n\t\r');
      expect(reverse.convert(BrailleDots.fromDotString('78')), '⣀');
      expect(reverse.convert(mapping.numberIndicator), '#');
      expect(reverse.convert(mapping.capitalIndicator), '');
      expect(reverse.convert(mapping.allCapsWord), '');
      expect(reverse.convert(mapping.endFormat), '');
    });
  });

  group('BrailleDots', () {
    test('parses dot strings including 8-dot fixtures', () {
      expect(BrailleDots.fromDotString('14'), '⠉');
      expect(BrailleDots.fromDotString('123456'), '⠿');
      expect(BrailleDots.fromDotString('78'), '⣀');
      expect(() => BrailleDots.fromDotString('0'), throwsArgumentError);
      expect(() => BrailleDots.fromDotString('9'), throwsArgumentError);
    });
  });
}
