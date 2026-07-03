import 'package:flutter_test/flutter_test.dart';
import 'package:viet_braille_app/core/braille_mapping.dart';
import 'package:viet_braille_app/domain/braille_converter.dart';

void main() {
  late BrailleMapping mapping;
  late BrailleConverter converter;

  setUp(() {
    mapping = BrailleMappingImpl();
    converter = BrailleConverterImpl(mapping);
  });

  group('special characters', () {
    test('punctuation: comma, period, question, exclaim', () {
      const input = 'Xin chào, Việt Nam! Bạn khỏe không?';
      final result = converter.convertWithDetails(input);
      expect(result.brailleText, isNotEmpty);
      expect(result.hasWarnings, isFalse);
    });

    test('numbers with separators', () {
      const input = '1.234.567,89';
      final result = converter.convertWithDetails(input);
      expect(result.brailleText, isNotEmpty);
    });

    test('very long text', () {
      final input = 'Xin chào Việt Nam. ' * 100;
      final result = converter.convertWithDetails(input);
      expect(result.brailleText, isNotEmpty);
    });

    test('whitespace input preserves spaces', () {
      final result = converter.convertWithDetails('   ');
      expect(result.brailleText, equals('   '));
    });

    test('empty input returns empty', () {
      final result = converter.convertWithDetails('');
      expect(result.brailleText, isEmpty);
    });
  });
}
