import 'package:test/test.dart';
import 'package:viet_braille_core/viet_braille_core.dart';

void main() {
  test('100,000 ký tự được chuyển trong dưới 2 giây', () {
    final converter = BrailleConverterImpl(BrailleMappingImpl());
    final input = List.filled(5556, 'Xin chào Việt Nam. ').join();

    // Warm up JIT và các bảng lazy trước khi đo.
    converter.convert('Xin chào Việt Nam.');

    final stopwatch = Stopwatch()..start();
    final result = converter.convertWithDetails(input);
    stopwatch.stop();

    expect(input.length, greaterThanOrEqualTo(100000));
    expect(result.unmappedCharacters, isEmpty);
    expect(result.brailleText.length, greaterThan(100000));
    expect(
      stopwatch.elapsed,
      lessThan(const Duration(seconds: 2)),
      reason: 'Thời gian thực tế: ${stopwatch.elapsedMilliseconds} ms',
    );
  });
}
