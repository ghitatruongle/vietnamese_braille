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

  static const String ocrUnsupportedMessage =
      'OCR hiện chỉ được hỗ trợ trên Android và iOS.';
}
