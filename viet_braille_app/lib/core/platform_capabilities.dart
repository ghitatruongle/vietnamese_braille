import 'package:flutter/foundation.dart';

/// Ma trận tính năng theo nền tảng.
///
/// Các getter tập trung tại đây để giao diện và tầng dữ liệu không quảng bá
/// một tính năng mà plugin phía dưới không thể thực hiện.
abstract final class PlatformCapabilities {
  static bool get supportsOcr =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  static bool get supportsSpeech =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.windows;

  /// Đọc to văn bản bằng flutter_tts: Android, iOS, Windows, macOS.
  static bool get supportsTts =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.macOS);

  static const String ocrUnsupportedMessage =
      'OCR hiện chỉ được hỗ trợ trên Android và iOS.';
  static const String ttsUnsupportedMessage =
      'Đọc to (TTS) chưa được hỗ trợ trên nền tảng này.';
}
