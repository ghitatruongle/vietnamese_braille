// ignore_for_file: avoid_print
import 'package:flutter_test/flutter_test.dart';
import 'package:viet_braille_core/viet_braille_core.dart';

void main() {
  late BrailleMapping mapping;
  late BrailleConverter converter;

  setUp(() {
    mapping = BrailleMappingImpl();
    converter = BrailleConverterImpl(mapping);
  });

  group('performance benchmarks', () {
    test('convert 1000 words under 1 second', () {
      final input = 'Xin chào Việt Nam. ' * 200;
      final stopwatch = Stopwatch()..start();
      final result = converter.convertWithDetails(input);
      stopwatch.stop();
      expect(result.brailleText, isNotEmpty);
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(1000),
        reason: '1000 words took ${stopwatch.elapsedMilliseconds}ms',
      );
      print('1000 words: ${stopwatch.elapsedMilliseconds}ms');
    });

    test('convert 10000 words under 5 seconds', () {
      final input = 'Xin chào Việt Nam. ' * 2000;
      final stopwatch = Stopwatch()..start();
      final result = converter.convertWithDetails(input);
      stopwatch.stop();
      expect(result.brailleText, isNotEmpty);
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(5000),
        reason: '10000 words took ${stopwatch.elapsedMilliseconds}ms',
      );
      print('10000 words: ${stopwatch.elapsedMilliseconds}ms');
    });
  });
}
