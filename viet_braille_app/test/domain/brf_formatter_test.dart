import 'package:flutter_test/flutter_test.dart';
import 'package:viet_braille_core/viet_braille_core.dart';

void main() {
  late BrfFormatter formatter;
  late BrailleConverter converter;
  late BrailleAsciiCodec codec;

  setUp(() {
    formatter = BrfFormatterImpl();
    converter = BrailleConverterImpl(BrailleMappingImpl());
    codec = NabccBrailleAsciiCodec();
  });

  group('Unicode Braille → BRF', () {
    test('empty input produces one empty BRF line', () {
      expect(formatter.format(''), '\n');
    });

    test('converts a Vietnamese sentence to valid Braille ASCII', () {
      final unicode = converter.convert('Xin chào Việt Nam');
      final brf = formatter.format(unicode);

      expect(brf, endsWith('\n'));
      expect(codec.isValid(brf), isTrue);
      expect(brf.codeUnits.every((value) => value < 0x80), isTrue);
      expect(brf, isNot(contains(RegExp(r'[\u2800-\u28ff]'))));
    });

    test('known Braille cells use NABCC bytes', () {
      expect(formatter.format('⠁⠃⠉⠙⠑'), 'ABCDE\n');
      expect(formatter.format('⠼⠤⠈'), '#-@\n');
    });

    test('keeps repeated spaces instead of collapsing layout', () {
      expect(formatter.format('⠁  ⠃   ⠉'), 'A  B   C\n');
    });

    test('preserves logical empty lines', () {
      expect(formatter.format('⠁\n\n⠃'), 'A\n\nB\n');
    });

    test('normalizes CRLF to BRF line endings', () {
      expect(formatter.format('⠁\r\n⠃'), 'A\nB\n');
    });
  });

  group('line wrapping', () {
    test('wraps at spaces when possible', () {
      expect(formatter.format('⠁⠃⠉ ⠙⠑⠋ ⠛⠓⠊', lineLength: 7), 'ABC DEF\nGHI\n');
    });

    test('splits a cell run longer than lineLength', () {
      expect(formatter.format('⠁⠃⠉⠙⠑⠋', lineLength: 2), 'AB\nCD\nEF\n');
    });

    test('every physical line respects configured width', () {
      final unicode = converter.convert(
        'Đây là một đoạn văn bản tiếng Việt đủ dài để kiểm tra BRF',
      );
      final brf = formatter.format(unicode, lineLength: 20);
      for (final line in brf.split('\n')) {
        expect(line.length, lessThanOrEqualTo(20));
      }
    });
  });

  group('validation', () {
    test('rejects zero and negative lineLength', () {
      expect(() => formatter.format('⠁', lineLength: 0), throwsArgumentError);
      expect(() => formatter.format('⠁', lineLength: -1), throwsArgumentError);
    });

    test('rejects print text and 8-dot Braille', () {
      expect(() => formatter.format('xin chào'), throwsFormatException);
      expect(() => formatter.format('⣿'), throwsFormatException);
    });

    test('formatAscii rejects lowercase ASCII', () {
      expect(() => formatter.formatAscii('lowercase'), throwsFormatException);
    });
  });
}
