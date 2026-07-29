/// Tạo mô tả dễ đọc bằng trình đọc màn hình cho một ô Braille Unicode.
String describeBrailleCell(String cell) {
  if (cell.isEmpty) return 'không có ô Braille';

  final codePoint = cell.runes.first;
  if (codePoint < 0x2800 || codePoint > 0x28ff) {
    return 'ký tự $cell';
  }

  final mask = codePoint - 0x2800;
  final dots = <int>[
    for (var dot = 1; dot <= 8; dot++)
      if (mask & (1 << (dot - 1)) != 0) dot,
  ];
  if (dots.isEmpty) return 'ô Braille trống';
  return 'ô Braille có chấm ${dots.join(', ')}';
}

/// Tạo mô tả cho chuỗi gồm một hoặc nhiều ô Braille.
String describeBraille(String braille) {
  final cells = braille.runes
      .map(String.fromCharCode)
      .where((cell) => cell.trim().isNotEmpty)
      .toList();
  if (cells.length <= 1) {
    return describeBrailleCell(cells.isEmpty ? '' : cells.single);
  }

  return [
    for (var index = 0; index < cells.length; index++)
      'ô ${index + 1}: ${describeBrailleCell(cells[index]).replaceFirst('ô Braille ', '')}',
  ].join('; ');
}
