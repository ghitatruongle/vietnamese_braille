abstract class BrfFormatter {
  String format(String braille, {int lineLength = 40});
}

/// Implementation của BrfFormatter.
///
/// Định dạng Braille ASCII thành các dòng có độ dài tối đa [lineLength].
/// Không cắt giữa từ, giữ nguyên các dòng logic (phân tách bằng \n).
class BrfFormatterImpl implements BrfFormatter {
  @override
  String format(String braille, {int lineLength = 40}) {
    final buffer = StringBuffer();

    // Tách thành các dòng logic dựa trên \n
    final logicalLines = braille.split('\n');
    // Bỏ phần tử rỗng cuối cùng nếu input kết thúc bằng \n (tránh dòng trống thừa)
    if (logicalLines.isNotEmpty && logicalLines.last.isEmpty) {
      logicalLines.removeLast();
    }

    for (var i = 0; i < logicalLines.length; i++) {
      final line = logicalLines[i];
      _formatLogicalLine(line, lineLength, buffer);

      // Thêm \n giữa các dòng logic
      buffer.write('\n');
    }

    // Đảm bảo file kết thúc bằng \n (quy ước BRF)
    if (buffer.isEmpty) {
      buffer.write('\n');
    }

    return buffer.toString();
  }

  /// Định dạng một dòng logic thành các dòng vật lý.
  void _formatLogicalLine(String line, int lineLength, StringBuffer buffer) {
    final words = line.split(' ');
    String currentLine = '';

    for (final word in words) {
      // Bỏ qua empty string từ split (khi có nhiều khoảng trắng liên tiếp)
      if (word.isEmpty) continue;

      // Cắt từ quá dài thành nhiều phần
      final chunks = _splitLongWord(word, lineLength);

      for (final chunk in chunks) {
        if (currentLine.isEmpty) {
          currentLine = chunk;
        } else {
          final proposedLength = currentLine.length + 1 + chunk.length;

          if (proposedLength <= lineLength) {
            currentLine += ' $chunk';
          } else {
            buffer.write(currentLine);
            buffer.write('\n');
            currentLine = chunk;
          }
        }
      }
    }

    // Xuất dòng cuối cùng (nếu có)
    if (currentLine.isNotEmpty) {
      buffer.write(currentLine);
    }
  }

  /// Cắt từ dài hơn lineLength thành các chunk nhỏ hơn.
  List<String> _splitLongWord(String word, int lineLength) {
    if (word.length <= lineLength) return [word];

    final chunks = <String>[];
    int start = 0;
    while (start < word.length) {
      final end = (start + lineLength < word.length)
          ? start + lineLength
          : word.length;
      chunks.add(word.substring(start, end));
      start = end;
    }
    return chunks;
  }
}
