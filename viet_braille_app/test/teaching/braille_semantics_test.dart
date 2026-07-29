import 'package:flutter_test/flutter_test.dart';
import 'package:viet_braille_app/teaching/braille_semantics.dart';

void main() {
  test('mô tả đúng chấm của một ô Braille', () {
    expect(describeBrailleCell('⠕'), 'ô Braille có chấm 1, 3, 5');
    expect(describeBrailleCell('⠀'), 'ô Braille trống');
  });

  test('mô tả chuỗi Braille theo thứ tự từng ô', () {
    expect(
      describeBraille('⠟⠥'),
      'ô 1: có chấm 1, 2, 3, 4, 5; ô 2: có chấm 1, 3, 6',
    );
  });
}
