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

  group('tone stacking', () {
    test('ấ (a + circumflex + acute)', () {
      final result = converter.convertWithDetails('ấ');
      expect(result.brailleText, isNotEmpty);
      expect(result.hasWarnings, isFalse);
    });
    test('ầ (a + circumflex + grave)', () {
      final result = converter.convertWithDetails('ầ');
      expect(result.brailleText, isNotEmpty);
    });
    test('ẩ (a + circumflex + hook)', () {
      final result = converter.convertWithDetails('ẩ');
      expect(result.brailleText, isNotEmpty);
    });
    test('ẫ (a + circumflex + tilde)', () {
      final result = converter.convertWithDetails('ẫ');
      expect(result.brailleText, isNotEmpty);
    });
    test('ậ (a + circumflex + dot)', () {
      final result = converter.convertWithDetails('ậ');
      expect(result.brailleText, isNotEmpty);
    });
    test('all double toned vowels in sentence', () {
      const input = 'ấ ầ ẩ ẫ ậ';
      final result = converter.convertWithDetails(input);
      expect(result.brailleText, isNotEmpty);
      expect(result.hasWarnings, isFalse);
    });
  });
}
