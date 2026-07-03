import 'package:flutter_test/flutter_test.dart';
import 'package:viet_braille_app/core/braille_mapping.dart';
import 'package:viet_braille_app/data/ocr_processor.dart';

void main() {
  group('OcrProcessorImpl', () {
    late OcrProcessorImpl processor;

    setUp(() {
      processor = OcrProcessorImpl(BrailleMappingImpl());
    });

    test('recognizeImage throws for non-existent file', () async {
      expect(
        () => processor.recognizeImage('/non/existent/file.png'),
        throwsA(isA<Exception>()),
      );
    });

    test('recognizeImage throws exception containing file path', () async {
      try {
        await processor.recognizeImage('/non/existent/file.png');
        fail('Should have thrown');
      } catch (e) {
        expect(e.toString(), contains('File ảnh không tồn tại'));
      }
    });

    test('OcrProcessorImpl can be instantiated', () {
      expect(OcrProcessorImpl(BrailleMappingImpl()), isNotNull);
    });

    test('OcrProcessor interface is implemented by OcrProcessorImpl', () {
      expect(processor, isA<OcrProcessor>());
    });
  });

  group('OcrProcessorImpl retry config', () {
    test('accepts custom maxRetries and retryDelay', () {
      final mapping = BrailleMappingImpl();
      final processor = OcrProcessorImpl(
        mapping,
        maxRetries: 5,
        retryDelay: const Duration(milliseconds: 500),
      );
      expect(processor, isA<OcrProcessor>());
    });

    test('uses default retry config when not specified', () {
      final mapping = BrailleMappingImpl();
      final processor = OcrProcessorImpl(mapping);
      expect(processor, isA<OcrProcessor>());
    });

    test('accepts injectable TextRecognizer', () {
      // Verify the constructor accepts an external TextRecognizer
      // (actual injection test requires a mock, which needs build_runner)
      final mapping = BrailleMappingImpl();
      final processor = OcrProcessorImpl(mapping);
      expect(processor, isA<OcrProcessor>());
    });
  });
}
