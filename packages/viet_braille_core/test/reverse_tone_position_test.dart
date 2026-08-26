import 'package:test/test.dart';
import 'package:viet_braille_core/viet_braille_core.dart';

/// Regression tests cho vị trí đặt dấu thanh khi dịch ngược chuẩn
/// (Phase 2A.1 — sửa vần âm đệm 'o' + 'a': xoài, ngoài, hòa...).
void main() {
  final mapping = BrailleMappingImpl();
  final forward = BrailleConverterImpl(mapping);
  final reverse = BrailleReverseConverterImpl(mapping);

  String roundTrip(String text) => reverse.convert(forward.convert(text));

  group('reverse tone position — âm đệm o + a', () {
    for (final word in const [
      'xoài',
      'ngoài',
      'ngoái',
      'toài',
      'soài',
      'oái',
      'hoà',
      'toàn',
      'hoàn',
      'ngào',
      'ngoáy',
    ]) {
      test('round-trip "$word"', () {
        expect(roundTrip(word), word, reason: word);
      });
    }
  });

  group('reverse tone position — các quy tắc giữ nguyên', () {
    for (final word in const [
      // Cụm đầu 'u' là âm đệm ư mã hóa bằng ô u — dấu ở chữ đầu.
      'mùa',
      'của',
      'cửa',
      'xủa',
      // Ô nguyên âm chính: khỏe, thủy giữ hành vi cũ.
      'khỏe',
      'thủy',
      'suýt',
      // oi/ui hai chữ: dấu ở chữ đầu.
      'mòi',
      'mùi',
      'đói',
      // Vần iê/uô/ươ dùng nguyên âm chính ưu tiên.
      'triền',
      'muối',
      'nước',
      'mưa',
    ]) {
      test('round-trip "$word" không đổi', () {
        expect(roundTrip(word), word, reason: word);
      });
    }
  });
}
