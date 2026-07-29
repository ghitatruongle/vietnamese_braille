/// Tiền xử lý văn bản thuần túy trước khi áp dụng quy tắc Braille.
///
/// Lớp này không biết bảng ánh xạ Braille. Nó chỉ chuẩn hóa những quy ước
/// trình bày mà converter cần nhìn thấy nhất quán.
final class BrailleTextPreprocessor {
  const BrailleTextPreprocessor();

  static final RegExp _attachedMeasurementUnit = RegExp(
    r'(\d)(km|hm|dam|dm|cm|mm|kg|hg|dag|g|tấn|tạ|yến)'
    r'(?=\b|[^a-zA-Z0-9àáảãạâầấẩẫậăằắẳẵặèéẻẽẹêềếểễệìíỉĩị'
    r'òóỏõọôồốổỗộơờớởỡợùúủũụưừứửữựỳýỷỹỵđ])',
    caseSensitive: false,
  );

  /// Lookaround giữ lại hai chữ số, vì vậy mọi toán tử trong một chuỗi như
  /// `1 + 2 + 3` đều được xử lý và không gặp lỗi match chồng lấn.
  static final RegExp _numericOperatorSpacing = RegExp(
    r'(?<=\d)\s*([+\-*/x:=<>≈≤≥])\s*(?=\d)',
    caseSensitive: false,
  );

  String preprocess(String text) {
    var result = text.replaceAllMapped(
      _attachedMeasurementUnit,
      (match) => '${match.group(1)} ${match.group(2)}',
    );

    result = result.replaceAllMapped(
      _numericOperatorSpacing,
      (match) => match.group(1)!,
    );

    return result.replaceAll('...', '…');
  }
}
