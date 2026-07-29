import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import 'package:viet_braille_core/viet_braille_core.dart';

abstract class OcrProcessor {
  Future<String> recognizeImage(String path);
  void dispose();
}

class OcrProcessorImpl implements OcrProcessor {
  final BrailleMapping _mapping;
  final TextRecognizer? _textRecognizer;
  final Future<String> Function(String path)? _recognizeText;
  final void Function()? _onDispose;
  final int _maxRetries;
  final Duration _retryDelay;

  OcrProcessorImpl(
    this._mapping, {
    TextRecognizer? textRecognizer,
    Future<String> Function(String path)? recognizeText,
    void Function()? onDispose,
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 1),
  }) : _textRecognizer = recognizeText == null
           ? textRecognizer ??
                 TextRecognizer(script: TextRecognitionScript.latin)
           : textRecognizer,
       _recognizeText = recognizeText,
       _onDispose = onDispose,
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
        final injectedText = _recognizeText;
        final text = injectedText != null
            ? await injectedText(path)
            : (await _textRecognizer!.processImage(
                InputImage.fromFilePath(path),
              )).text;

        // Chuẩn hóa NFC: ghép combining marks thành ký tự precomposed
        return _mapping.composeNfc(text);
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

  @override
  void dispose() {
    _onDispose?.call();
    _textRecognizer?.close();
  }
}

class UnsupportedOcrProcessor implements OcrProcessor {
  const UnsupportedOcrProcessor();

  @override
  Future<String> recognizeImage(String path) {
    throw UnsupportedError('OCR hiện chỉ được hỗ trợ trên Android và iOS.');
  }

  @override
  void dispose() {}
}
