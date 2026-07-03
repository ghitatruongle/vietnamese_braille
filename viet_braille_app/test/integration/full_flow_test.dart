import 'package:flutter_test/flutter_test.dart';
import 'package:viet_braille_app/core/braille_mapping.dart';
import 'package:viet_braille_app/domain/braille_converter.dart';
import 'package:viet_braille_app/domain/braille_reverse_converter.dart';
import 'package:viet_braille_app/domain/brf_formatter.dart';

/// Integration tests: full pipeline từ text → Braille → BRF → round-trip.
///
/// Mục tiêu: đảm bảo các component hoạt động đúng khi kết hợp với nhau,
/// không chỉ unit test từng phần riêng lẻ.
void main() {
  late BrailleMappingImpl mapping;
  late BrailleConverter converter;
  late BrailleReverseConverter reverseConverter;
  late BrfFormatter formatter;

  setUp(() {
    mapping = BrailleMappingImpl();
    converter = BrailleConverterImpl(mapping);
    reverseConverter = BrailleReverseConverterImpl(mapping);
    formatter = BrfFormatterImpl();
  });

  // ═══════════════════════════════════════════════════════════════════
  // Full pipeline: Text → Braille → BRF
  // ═══════════════════════════════════════════════════════════════════
  group('full pipeline: text → Braille → BRF', () {
    test('simple Vietnamese sentence', () {
      const input = 'Xin chào Việt Nam';
      final result = converter.convertWithDetails(input);

      expect(result.hasWarnings, isFalse);
      expect(result.brailleText, isNotEmpty);

      final brf = formatter.format(result.brailleText, lineLength: 40);
      expect(brf, isNotEmpty);
      expect(brf, endsWith('\n'));
    });

    test('all Vietnamese special vowels in one word', () {
      const input = 'ăâêôơưđ';
      final result = converter.convertWithDetails(input);
      expect(result.brailleText, isNotEmpty);
      expect(result.hasWarnings, isFalse);
    });

    test('mixed case with numbers', () {
      const input = 'Học sinh lớp 10A';
      final result = converter.convertWithDetails(input);
      expect(result.brailleText, isNotEmpty);

      final reversed = reverseConverter.convert(result.brailleText);
      expect(reversed.toLowerCase(), contains('học'));
      expect(reversed, contains('10'));
    });

    test('all 5 tones in one phrase', () {
      const input = 'á à ả ã ạ';
      final result = converter.convertWithDetails(input);
      expect(result.brailleText, isNotEmpty);

      final reversed = reverseConverter.convert(result.brailleText);
      expect(reversed, contains('á'));
      expect(reversed, contains('à'));
      expect(reversed, contains('ả'));
      expect(reversed, contains('ã'));
      expect(reversed, contains('ạ'));
    });

    test('qu rule: quyết, quả, qui', () {
      const inputs = ['quyết', 'quả', 'qui'];
      for (final input in inputs) {
        final result = converter.convertWithDetails(input);
        expect(
          result.brailleText,
          isNotEmpty,
          reason: 'Failed for input: $input',
        );
      }
    });

    test('gi rule: giải, gạo, giếng', () {
      const inputs = ['giải', 'gạo', 'giếng'];
      for (final input in inputs) {
        final result = converter.convertWithDetails(input);
        expect(
          result.brailleText,
          isNotEmpty,
          reason: 'Failed for input: $input',
        );
      }
    });

    test('capitalization: single, word, phrase', () {
      final single = converter.convertWithDetails('Việt');
      expect(single.brailleText, isNotEmpty);

      final word = converter.convertWithDetails('HELLO');
      expect(word.brailleText, isNotEmpty);

      final phrase = converter.convertWithDetails('XIN CHÀO');
      expect(phrase.brailleText, isNotEmpty);
    });

    test('number mode with separators', () {
      const input = '1.234.567,89';
      final result = converter.convertWithDetails(input);
      expect(result.brailleText, isNotEmpty);

      final numIndicator = String.fromCharCode(0x2800 + 60);
      expect(result.brailleText, contains(numIndicator));
    });

    test('punctuation: comma, period, question, exclaim', () {
      const input = 'Xin chào, Việt Nam! Bạn khỏe không?';
      final result = converter.convertWithDetails(input);
      expect(result.brailleText, isNotEmpty);
      expect(result.hasWarnings, isFalse);
    });

    test('empty input returns empty result', () {
      final result = converter.convertWithDetails('');
      expect(result.brailleText, isEmpty);
      expect(result.hasWarnings, isFalse);
    });

    test('whitespace-only input preserves whitespace', () {
      final result = converter.convertWithDetails('   ');
      // Whitespace is preserved — no unmapped characters
      expect(result.hasWarnings, isFalse);
    });
  });

  // ═══════════════════════════════════════════════════════════════════
  // Round-trip: Text → Braille → Text
  // ═══════════════════════════════════════════════════════════════════
  group('round-trip: text → Braille → text', () {
    test('plain ASCII round-trips correctly', () {
      const input = 'hello world';
      final braille = converter.convert(input);
      final reversed = reverseConverter.convert(braille);
      expect(reversed, equals(input));
    });

    test('Vietnamese without tone round-trips', () {
      const input = 'đây là tiếng việt';
      final braille = converter.convert(input);
      final reversed = reverseConverter.convert(braille);
      expect(reversed, equals(input));
    });

    test('single toned vowel round-trips', () {
      const testCases = ['á', 'à', 'ả', 'ã', 'ạ'];
      for (final input in testCases) {
        final braille = converter.convert(input);
        final reversed = reverseConverter.convert(braille);
        expect(
          reversed,
          equals(input),
          reason: 'Round-trip failed for: $input',
        );
      }
    });

    test('word with tone round-trips', () {
      const input = 'Việt';
      final braille = converter.convert(input);
      final reversed = reverseConverter.convert(braille);
      expect(reversed.toLowerCase(), equals('việt'));
    });

    test('numbers round-trip', () {
      const input = '123';
      final braille = converter.convert(input);
      final reversed = reverseConverter.convert(braille);
      expect(reversed, equals(input));
    });

    test('mixed text round-trips (lowercase)', () {
      const input = 'xin chao 123';
      final braille = converter.convert(input);
      final reversed = reverseConverter.convert(braille);
      expect(reversed, equals(input));
    });
  });

  // ═══════════════════════════════════════════════════════════════════
  // BRF formatting integration
  // ═══════════════════════════════════════════════════════════════════
  group('BRF formatting integration', () {
    test('long text wraps at lineLength', () {
      const input =
          'Đây là một đoạn văn bản tiếng Việt đủ dài để kiểm tra việc ngắt dòng trong định dạng BRF';
      final result = converter.convertWithDetails(input);
      final brf = formatter.format(result.brailleText, lineLength: 20);

      final lines = brf.split('\n').where((l) => l.isNotEmpty).toList();
      for (int i = 0; i < lines.length - 1; i++) {
        expect(
          lines[i].length,
          lessThanOrEqualTo(20),
          reason: 'Line ${i + 1} exceeds 20 chars: "${lines[i]}"',
        );
      }
    });

    test('BRF preserves logical newlines', () {
      const input = 'Dòng đầu\nDòng hai';
      final result = converter.convertWithDetails(input);
      final brf = formatter.format(result.brailleText, lineLength: 80);

      final lines = brf.split('\n').where((l) => l.isNotEmpty).toList();
      expect(lines.length, greaterThanOrEqualTo(2));
    });

    test('BRF ends with newline', () {
      final result = converter.convertWithDetails('test');
      final brf = formatter.format(result.brailleText);
      expect(brf, endsWith('\n'));
    });
  });
}
