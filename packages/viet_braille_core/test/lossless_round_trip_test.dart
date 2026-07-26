import 'package:test/test.dart';
import 'package:viet_braille_core/viet_braille_core.dart';

void main() {
  final mapping = BrailleMappingImpl();
  final forward = BrailleConverterImpl(mapping);
  final reverse = BrailleReverseConverterImpl(mapping);

  String losslessRoundTrip(String text) {
    final braille = forward.convert(text, mode: BrailleConversionMode.lossless);
    return reverse.convert(braille, mode: BrailleConversionMode.lossless);
  }

  group('collision handling', () {
    for (final text in ['a-a', 'a?a', 'Á-Âu', 'Có?Ai', 'cà-phê']) {
      test('lossless round-trip: $text', () {
        expect(losslessRoundTrip(text), text);
      });
    }

    test('standard reverse uses punctuation after a decoded vowel', () {
      for (final text in ['a-a', 'a?a', 'Á-Âu', 'Có?Ai']) {
        expect(reverse.convert(forward.convert(text)), text, reason: text);
      }
    });

    test('standard qu tone is not mistaken for punctuation', () {
      for (final text in ['quả', 'quã', 'Quảng']) {
        expect(reverse.convert(forward.convert(text)), text, reason: text);
      }
    });

    test('lossless escape is deliberately not BRF-compatible', () {
      final lossless = forward.convert(
        'a?a',
        mode: BrailleConversionMode.lossless,
      );
      expect(lossless, contains(losslessBrailleEscape));
      expect(() => BrfFormatterImpl().format(lossless), throwsFormatException);
    });

    test('malformed lossless escape fails explicitly', () {
      expect(
        () => reverse.convert(
          losslessBrailleEscape,
          mode: BrailleConversionMode.lossless,
        ),
        throwsFormatException,
      );
    });
  });
}
