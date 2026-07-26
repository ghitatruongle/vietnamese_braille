import 'braille_ascii_codec.dart';

abstract class BrfFormatter {
  /// Mã hóa Unicode Braille sang Braille ASCII và định dạng thành tệp BRF.
  String format(String braille, {int lineLength = 40});

  /// Định dạng chuỗi đã ở dạng Braille ASCII.
  String formatAscii(String brailleAscii, {int lineLength = 40});
}

/// Implementation của BrfFormatter.
///
/// Đầu vào của [format] là Unicode Braille 6 chấm. Kết quả chỉ chứa bộ ký tự
/// Braille ASCII, khoảng trắng và các ký tự điều khiển bố cục BRF.
class BrfFormatterImpl implements BrfFormatter {
  BrfFormatterImpl({BrailleAsciiCodec? codec})
    : _codec = codec ?? NabccBrailleAsciiCodec();

  final BrailleAsciiCodec _codec;

  @override
  String format(String braille, {int lineLength = 40}) {
    return formatAscii(_codec.encode(braille), lineLength: lineLength);
  }

  @override
  String formatAscii(String brailleAscii, {int lineLength = 40}) {
    if (lineLength <= 0) {
      throw ArgumentError.value(
        lineLength,
        'lineLength',
        'Độ dài dòng BRF phải lớn hơn 0.',
      );
    }
    if (!_codec.isValid(brailleAscii)) {
      throw const FormatException(
        'Nội dung chứa ký tự không thuộc Braille ASCII.',
      );
    }

    final normalized = brailleAscii
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n');
    final logicalLines = normalized.split('\n');
    if (normalized.endsWith('\n')) {
      logicalLines.removeLast();
    }

    final buffer = StringBuffer();
    for (final logicalLine in logicalLines) {
      for (final physicalLine in _wrapLogicalLine(logicalLine, lineLength)) {
        buffer
          ..write(physicalLine)
          ..write('\n');
      }
    }

    // Chuỗi rỗng vẫn tạo một dòng BRF rỗng hợp lệ.
    if (buffer.isEmpty) buffer.write('\n');
    return buffer.toString();
  }

  List<String> _wrapLogicalLine(String line, int lineLength) {
    if (line.isEmpty) return const [''];

    final result = <String>[];
    var remaining = line;
    while (remaining.length > lineLength) {
      // Ưu tiên ngắt ở khoảng trắng; một dấu cách biên được thay bằng newline.
      final breakAt = remaining.lastIndexOf(' ', lineLength);
      if (breakAt > 0) {
        result.add(remaining.substring(0, breakAt));
        remaining = remaining.substring(breakAt + 1);
      } else {
        // Một từ dài hơn cả dòng phải được cắt cứng để giữ giới hạn BRF.
        result.add(remaining.substring(0, lineLength));
        remaining = remaining.substring(lineLength);
      }
    }
    result.add(remaining);
    return result;
  }
}
