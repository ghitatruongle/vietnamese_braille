/// Tiện ích chia sẻ cho dot bitmask và Braille cell generation.
///
/// Tập trung các hằng số dot (1-6) và hàm [_cell] để tránh trùng lặp
/// giữa [BrailleMappingImpl] và [BrailleReverseConverterImpl].
///
/// Ô Braille Unicode 8-dot nằm trong khoảng U+2800 – U+28FF.
class BrailleDots {
  BrailleDots._();

  // ──────────────────────────── Dot bitmasks ────────────────────────────
  static const int d1 = 1;
  static const int d2 = 2;
  static const int d3 = 4;
  static const int d4 = 8;
  static const int d5 = 16;
  static const int d6 = 32;

  /// Tạo ký tự Braille Unicode từ bitmask dots.
  ///
  /// Ví dụ: `cell(d1 | d4)` → dots 1,4 → U+2809 (⠉).
  static String cell(int dots) => String.fromCharCode(0x2800 + dots);

  /// Parse một chuỗi dot numbers (VD: '345') thành ký tự Braille Unicode.
  /// Hỗ trợ cho test helper và các trường hợp cần tạo cell từ dot notation.
  static String fromDotString(String dots) {
    int bitmask = 0;
    for (final ch in dots.split('')) {
      final n = int.parse(ch);
      if (n < 1 || n > 8) {
        throw ArgumentError('Dot number must be 1-8, got $n');
      }
      bitmask |= (1 << (n - 1));
    }
    return cell(bitmask);
  }
}
