import 'package:viet_braille_core/viet_braille_core.dart';

void main() {
  final mapping = BrailleMappingImpl();
  final forward = BrailleConverterImpl(mapping);
  final reverse = BrailleReverseConverterImpl(mapping);

  // Test markers via direct ctrl chars
  final tests = [
    '\u0002đậm\u0002',
    '\u000Enghiêng\u000E',
    '\u001Fgạch chân\u001F',
    '\u0002chào\u0002 mừng',
    'một \u000Enghiêng\u000E và \u0002đậm\u0002',
  ];
  for (final t in tests) {
    final b = forward.convert(t);
    final r = reverse.convert(b);
    print('"$t" → "$b" → "$r" ${r == t ? "OK" : "FAIL"}');
  }

  // Test markdown-style
  final mdTests = [
    '**in đậm**',
    '*in nghiêng*',
    '_gạch chân_',
    'chào **bạn** thân mến',
  ];
  for (final t in mdTests) {
    final b = forward.convert(t, enableMarkdown: true);
    final r = reverse.convert(b);
    print('"$t" → "$b" → "$r"');
  }
}
