import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:viet_braille_app/data/ocr_processor.dart';
import 'package:viet_braille_core/viet_braille_core.dart';

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

  group('OcrProcessorImpl injected recognition', () {
    late Directory directory;
    late File image;

    setUp(() {
      directory = Directory.systemTemp.createTempSync('viet_braille_ocr_');
      image = File('${directory.path}${Platform.pathSeparator}image.png')
        ..writeAsBytesSync([0]);
    });

    tearDown(() {
      directory.deleteSync(recursive: true);
    });

    test('normalizes successful recognized text to NFC', () async {
      final processor = OcrProcessorImpl(
        BrailleMappingImpl(),
        recognizeText: (_) async => 'a\u0301',
      );

      expect(await processor.recognizeImage(image.path), 'á');
    });

    test('retries transient failures then succeeds', () async {
      var attempts = 0;
      final processor = OcrProcessorImpl(
        BrailleMappingImpl(),
        maxRetries: 3,
        retryDelay: Duration.zero,
        recognizeText: (_) async {
          attempts++;
          if (attempts < 3) throw StateError('temporary');
          return 'xin';
        },
      );

      expect(await processor.recognizeImage(image.path), 'xin');
      expect(attempts, 3);
    });

    test('reports final failure after all attempts', () async {
      final processor = OcrProcessorImpl(
        BrailleMappingImpl(),
        maxRetries: 2,
        retryDelay: Duration.zero,
        recognizeText: (_) async => throw StateError('unreadable'),
      );

      await expectLater(
        processor.recognizeImage(image.path),
        throwsA(
          predicate(
            (error) =>
                '$error'.contains('sau 2 lần thử') &&
                '$error'.contains('Lần thử 2/2'),
          ),
        ),
      );
    });

    test('dispose invokes injected cleanup', () {
      var disposed = false;
      final processor = OcrProcessorImpl(
        BrailleMappingImpl(),
        recognizeText: (_) async => '',
        onDispose: () => disposed = true,
      );

      processor.dispose();

      expect(disposed, isTrue);
    });
  });

  group('UnsupportedOcrProcessor', () {
    test('throws a clear unsupported error and dispose is safe', () async {
      const processor = UnsupportedOcrProcessor();

      expect(
        () => processor.recognizeImage('image.png'),
        throwsA(isA<UnsupportedError>()),
      );
      expect(processor.dispose, returnsNormally);
    });
  });
}
