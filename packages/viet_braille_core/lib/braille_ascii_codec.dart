/// Codec giữa Unicode Braille 6 chấm và North American Braille ASCII.
///
/// BRF truyền thống lưu từng ô Braille bằng một ký tự ASCII in được. Vì vậy
/// chuỗi U+2800–U+283F không thể được ghi thẳng ra tệp `.brf`.
abstract class BrailleAsciiCodec {
  /// Mã hóa Unicode Braille 6 chấm thành Braille ASCII.
  ///
  /// Khoảng trắng và các ký tự điều khiển bố cục BRF (`CR`, `LF`, `FF`) được
  /// giữ nguyên. Ký tự ngoài phạm vi Braille 6 chấm gây [FormatException].
  String encode(String unicodeBraille);

  /// Giải mã Braille ASCII thành Unicode Braille 6 chấm.
  String decode(String brailleAscii);

  /// Kiểm tra chuỗi có chỉ chứa Braille ASCII và điều khiển bố cục BRF.
  bool isValid(String brailleAscii);
}

/// North American Braille Computer Code (NABCC), bộ 64 ký tự dùng phổ biến
/// trong tệp BRF.
class NabccBrailleAsciiCodec implements BrailleAsciiCodec {
  static const int _unicodeBrailleStart = 0x2800;
  static const int _unicodeBrailleSixDotEnd = 0x283f;

  /// Bit mask chấm Braille → mã ASCII.
  ///
  /// Bit 0...5 tương ứng chấm 1...6 của Unicode Braille.
  static const Map<int, int> _dotsToAscii = {
    0: 0x20,
    1: 0x41,
    3: 0x42,
    9: 0x43,
    25: 0x44,
    17: 0x45,
    11: 0x46,
    27: 0x47,
    19: 0x48,
    10: 0x49,
    26: 0x4a,
    5: 0x4b,
    7: 0x4c,
    13: 0x4d,
    29: 0x4e,
    21: 0x4f,
    15: 0x50,
    31: 0x51,
    23: 0x52,
    14: 0x53,
    30: 0x54,
    37: 0x55,
    39: 0x56,
    58: 0x57,
    45: 0x58,
    61: 0x59,
    53: 0x5a,
    52: 0x30,
    2: 0x31,
    6: 0x32,
    18: 0x33,
    50: 0x34,
    34: 0x35,
    22: 0x36,
    54: 0x37,
    38: 0x38,
    20: 0x39,
    4: 0x27,
    8: 0x40,
    16: 0x22,
    32: 0x2c,
    33: 0x2a,
    12: 0x2f,
    36: 0x2d,
    24: 0x5e,
    40: 0x2e,
    48: 0x3b,
    35: 0x3c,
    41: 0x25,
    49: 0x3a,
    42: 0x5b,
    28: 0x3e,
    44: 0x2b,
    56: 0x5f,
    43: 0x24,
    51: 0x5c,
    57: 0x3f,
    46: 0x21,
    60: 0x23,
    47: 0x26,
    55: 0x28,
    59: 0x5d,
    62: 0x29,
    63: 0x3d,
  };

  static final Map<int, int> _asciiToDots = {
    for (final entry in _dotsToAscii.entries) entry.value: entry.key,
  };

  @override
  String encode(String unicodeBraille) {
    final output = StringBuffer();

    for (var index = 0; index < unicodeBraille.length; index++) {
      final codeUnit = unicodeBraille.codeUnitAt(index);
      if (_isLayoutControl(codeUnit) || codeUnit == 0x20) {
        output.writeCharCode(codeUnit);
        continue;
      }

      if (codeUnit < _unicodeBrailleStart ||
          codeUnit > _unicodeBrailleSixDotEnd) {
        throw FormatException(
          'BRF chỉ hỗ trợ Unicode Braille 6 chấm U+2800–U+283F; '
          'gặp U+${codeUnit.toRadixString(16).toUpperCase().padLeft(4, '0')} '
          'tại vị trí $index.',
          unicodeBraille,
          index,
        );
      }

      final ascii = _dotsToAscii[codeUnit - _unicodeBrailleStart];
      if (ascii == null) {
        throw StateError('Bảng NABCC thiếu mẫu chấm tại vị trí $index.');
      }
      output.writeCharCode(ascii);
    }

    return output.toString();
  }

  @override
  String decode(String brailleAscii) {
    final output = StringBuffer();

    for (var index = 0; index < brailleAscii.length; index++) {
      final codeUnit = brailleAscii.codeUnitAt(index);
      if (_isLayoutControl(codeUnit)) {
        output.writeCharCode(codeUnit);
        continue;
      }
      if (codeUnit == 0x20) {
        output.write(' ');
        continue;
      }

      final dots = _asciiToDots[codeUnit];
      if (dots == null) {
        throw FormatException(
          'Ký tự tại vị trí $index không thuộc Braille ASCII: '
          'U+${codeUnit.toRadixString(16).toUpperCase().padLeft(4, '0')}.',
          brailleAscii,
          index,
        );
      }
      output.writeCharCode(_unicodeBrailleStart + dots);
    }

    return output.toString();
  }

  @override
  bool isValid(String brailleAscii) {
    for (final codeUnit in brailleAscii.codeUnits) {
      if (_isLayoutControl(codeUnit) || codeUnit == 0x20) {
        continue;
      }
      if (!_asciiToDots.containsKey(codeUnit)) {
        return false;
      }
    }
    return true;
  }

  static bool _isLayoutControl(int codeUnit) =>
      codeUnit == 0x0a || codeUnit == 0x0d || codeUnit == 0x0c;
}
