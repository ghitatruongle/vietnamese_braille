void main() {
  final bold = 0x2800 | (1 << 3) | (1 << 4);
  print('bold (dots 4,5) = U+${bold.toRadixString(16).toUpperCase()}');
  print('char = ${String.fromCharCode(bold)}');
  final italic = 0x2800 | (1 << 4);
  print('italic (dot 5) = U+${italic.toRadixString(16).toUpperCase()}');
  print('char = ${String.fromCharCode(italic)}');
  final underline = 0x2800 | (1 << 3) | (1 << 4) | (1 << 5);
  print(
    'underline (dots 4,5,6) = U+${underline.toRadixString(16).toUpperCase()}',
  );
  print('char = ${String.fromCharCode(underline)}');
}
