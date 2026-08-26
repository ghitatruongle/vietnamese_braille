import 'vietnamese_letters.dart';

/// Tiền xử lý văn bản thuần túy trước khi áp dụng quy tắc Braille.
///
/// Lớp này không biết bảng ánh xạ Braille. Nó chỉ chuẩn hóa những quy ước
/// trình bày mà converter cần nhìn thấy nhất quán.
final class BrailleTextPreprocessor {
  const BrailleTextPreprocessor();

  // Lookahead chặn tách đơn vị đo khi nó là một phần của từ dài hơn
  // (ví dụ không tách `g` trong `gam`). Danh sách chữ cái tiếng Việt lấy
  // từ hằng số dùng chung thay vì liệt kê tay tại đây.
  static final RegExp _attachedMeasurementUnit = RegExp(
    r'(\d)(km|hm|dam|dm|cm|mm|kg|hg|dag|g|tấn|tạ|yến)'
    '(?=\\b|[^a-zA-Z0-9$kVietnameseTonedVowels$kVietnameseExtraLetters])',
    caseSensitive: false,
  );

  /// Lookaround giữ lại hai chữ số, vì vậy mọi toán tử trong một chuỗi như
  /// `1 + 2 + 3` đều được xử lý và không gặp lỗi match chồng lấn.
  ///
  /// Khớp chuỗi toán tử nhiều ký tự (`>=`, `<=`, `!=`) như một khối duy nhất
  /// để không tách `=` trong `>=`/`<=`/`!=` thành ký hiệu riêng.
  static final RegExp _numericOperatorSpacing = RegExp(
    r'(?<=\d)\s*([+\-*/x:=<>≈≤≥≠±×÷√!]+)\s*(?=\d)',
    caseSensitive: false,
  );

  String preprocess(String text, {bool enableMarkdown = false}) {
    var result = text.replaceAllMapped(
      _attachedMeasurementUnit,
      (match) => '${match.group(1)} ${match.group(2)}',
    );

    result = result.replaceAllMapped(
      _numericOperatorSpacing,
      (match) => match.group(1)!,
    );

    if (enableMarkdown) {
      result = _markdownToFormattingMarkers(result);
    }

    return result.replaceAll('...', '…');
  }

  /// Convert markdown-style formatting (bold/italic/underline) into the
  /// control-character markers that the forward converter maps to Braille
  /// formatting cells.
  ///
  /// Supported syntax:
  ///   **bold text**       → `\u0002bold text\u0002`
  ///   *italic text*       → `\u000Eitalic text\u000E`
  ///   _underline text_    → `\u001Funderline text\u001F`
  ///
  /// Hạn chế: dùng marker control (STX/SO/US) để phân biệt với văn bản;
  /// nếu nguồn chứa các ký tự này thì chuyển đổi sẽ lẫn lộn — chấp nhận
  /// được cho mục đích hiển thị.
  String _markdownToFormattingMarkers(String text) {
    var result = text;

    // Order matters: bold (**) trước italic (*) để không bị match mỗi dấu *
    final bold = RegExp(r'\*\*([^*]+)\*\*');
    result = result.replaceAllMapped(bold, (m) => '\u0002${m.group(1)}\u0002');

    // Italic single asterisk (after bold is processed)
    final italic = RegExp(r'(?<!\*)\*(?!\*)([^*]+?)\*(?!\*)');
    result = result.replaceAllMapped(
      italic,
      (m) => '\u000E${m.group(1)}\u000E',
    );

    final underline = RegExp(r'(?<![a-zA-Z0-9])_([^_]+)_(?![a-zA-Z0-9])');
    result = result.replaceAllMapped(
      underline,
      (m) => '\u001F${m.group(1)}\u001F',
    );

    return result;
  }
}
