import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../core/braille_mapping.dart';

abstract class OcrProcessor {
  Future<String> recognizeImage(String path);
}

class OcrProcessorImpl implements OcrProcessor {
  final BrailleMapping _mapping;
  final TextRecognizer _textRecognizer;
  final int _maxRetries;
  final Duration _retryDelay;

  OcrProcessorImpl(
    this._mapping, {
    TextRecognizer? textRecognizer,
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 1),
  }) : _textRecognizer =
           textRecognizer ??
           TextRecognizer(script: TextRecognitionScript.latin),
       _maxRetries = maxRetries,
       _retryDelay = retryDelay;

  @override
  Future<String> recognizeImage(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw Exception('File ảnh không tồn tại: $path');
    }

    Exception? lastException;

    for (int attempt = 0; attempt < _maxRetries; attempt++) {
      try {
        final inputImage = InputImage.fromFilePath(path);
        final recognizedText = await _textRecognizer.processImage(inputImage);

        // Chuẩn hóa NFC: ghép combining marks thành ký tự precomposed
        return _mapping.composeNfc(recognizedText.text);
      } catch (e) {
        lastException = Exception(
          'Lần thử ${attempt + 1}/$_maxRetries thất bại: $e',
        );

        if (attempt < _maxRetries - 1) {
          // Exponential backoff: 1s, 2s, 4s...
          final delay = _retryDelay * (1 << attempt);
          await Future.delayed(delay);
        }
      }
    }

    throw Exception(
      'Lỗi nhận dạng văn bản từ ảnh sau $_maxRetries lần thử: $lastException',
    );
  }

  void dispose() {
    _textRecognizer.close();
  }
}
