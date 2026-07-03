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

  group('qu rule', () {
    test('quyết', () {
      final result = converter.convertWithDetails('quyết');
      expect(result.brailleText, isNotEmpty);
      expect(result.hasWarnings, isFalse);
    });
    test('quả', () {
      final result = converter.convertWithDetails('quả');
      expect(result.brailleText, isNotEmpty);
    });
    test('qui', () {
      final result = converter.convertWithDetails('qui');
      expect(result.brailleText, isNotEmpty);
    });
    test('quốc', () {
      final result = converter.convertWithDetails('quốc');
      expect(result.brailleText, isNotEmpty);
    });
  });

  group('gi rule', () {
    test('giải', () {
      final result = converter.convertWithDetails('giải');
      expect(result.brailleText, isNotEmpty);
      expect(result.hasWarnings, isFalse);
    });
    test('gạo', () {
      final result = converter.convertWithDetails('gạo');
      expect(result.brailleText, isNotEmpty);
    });
    test('giếng', () {
      final result = converter.convertWithDetails('giếng');
      expect(result.brailleText, isNotEmpty);
    });
  });
}
