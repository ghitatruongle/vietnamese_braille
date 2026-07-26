import 'package:test/test.dart';
import 'package:viet_braille_core/viet_braille_core.dart';

/// Regression tests cho gom cụm viết hoa (all-caps & init-caps phrases).
/// Bảo vệ Bug #2 (all-caps) và Bug #3 (init-caps) khỏi tái xuất hiện.
void main() {
  late BrailleConverter converter;

  setUp(() {
    converter = BrailleConverterImpl(BrailleMappingImpl());
  });

  group('Phrase grouping regression', () {
    test('All-caps phrase HÀ NỘI có chỉ báo cụm và endFormat', () {
      expect(converter.convert('HÀ NỘI'), '⠨⠨⠓⠰⠁ ⠝⠠⠹⠊⠱');
    });

    test('All-caps phrase với số THÔNG TƯ SỐ 15', () {
      expect(converter.convert('THÔNG TƯ SỐ 15'), '⠨⠨⠞⠓⠹⠝⠛ ⠞⠳ ⠎⠔⠹⠱ ⠼⠁⠑');
    });

    test('Init-caps phrase Hà Nội được gom cụm (chỉ báo cụm)', () {
      final result = converter.convert('Hà Nội');
      expect(result, isNotEmpty);
      expect(result, contains('⠒⠨'));
    });
  });
}
