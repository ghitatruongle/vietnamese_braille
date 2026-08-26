import 'package:viet_braille_core/viet_braille_core.dart';

void main() {
  final mapping = BrailleMappingImpl();
  final forward = BrailleConverterImpl(mapping);
  final reverse = BrailleReverseConverterImpl(mapping);

  print('=== Verifying ≈≤≥≠ round-trip ===');

  // Test forward conversion
  final testCases = [
    ['a ≈ b', 'a ≈ b'],
    ['1 ≤ 2', '1 ≤ 2'],
    ['3 ≥ 2', '3 ≥ 2'],
    ['x ≠ y', 'x ≠ y'],
    ['a <= b', 'a <= b'],
    ['a >= b', 'a >= b'],
    ['a != b', 'a != b'],
  ];

  for (final testCase in testCases) {
    final input = testCase[0];
    final expected = testCase[1];

    print('\nInput: "$input"');
    final braille = forward.convert(input);
    print('Braille: "$braille"');
    print('Braille length: ${braille.length}');

    // Show individual rune values
    for (var i = 0; i < braille.length; i++) {
      final rune = braille.codeUnitAt(i);
      final char = String.fromCharCode(rune);
      final hex = rune.toRadixString(16).padLeft(4, '0');
      print('  [$i] Rune: U+$hex, char: $char');
    }

    final decoded = reverse.convert(braille);
    print('Decoded: "$decoded"');
    print('Expected: "$expected"');
    print('Match: ${decoded == expected}');
  }

  // Additional test: check what the symbols map to
  print('\n=== Symbol mapping details ===');

  final symbols = ['≈', '≤', '≥', '≠', '+', '=', '*', '<', '>'];
  for (final symbol in symbols) {
    final braille = mapping.mapChar(symbol);
    if (braille == null) {
      print('$symbol → NULL (not mapped!)');
      continue;
    }
    print('$symbol → "$braille" (length: ${braille.length})');
    for (var i = 0; i < braille.length; i++) {
      final rune = braille.codeUnitAt(i);
      final hex = rune.toRadixString(16).padLeft(4, '0');
      print('  Cell $i: U+$hex');
    }
  }

  // Test with spacing
  print('\n=== Testing with different spacing ===');
  final spacedTests = [
    '1+2', // No spaces
    '1 + 2', // Standard spaces
    '1  +  2', // Extra spaces
    '1≤2', // No spaces
    '1 ≤ 2', // Standard spaces
  ];

  for (final test in spacedTests) {
    final braille = forward.convert(test);
    final decoded = reverse.convert(braille);
    print('"$test" → "$braille" → "$decoded"');
  }
}
