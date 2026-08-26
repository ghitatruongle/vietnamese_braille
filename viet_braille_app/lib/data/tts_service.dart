import 'package:flutter_tts/flutter_tts.dart';

import '../core/platform_capabilities.dart';

/// Dịch vụ đọc to văn bản (TTS) — Phase 2C.
abstract class TtsServiceBase {
  /// Đọc [text]; trả về true nếu nền tảng đã nhận lệnh đọc.
  Future<bool> speak(String text);

  /// Tốc độ đọc theo thang flutter_tts 0.0–1.0 (mặc định 0.5).
  Future<void> setRate(double rate);

  /// Cao độ giọng 0.5–2.0 (mặc định 1.0).
  Future<void> setPitch(double pitch);
}

/// Impl thật trên nền tảng được flutter_tts hỗ trợ.
class TtsServiceImpl implements TtsServiceBase {
  final FlutterTts _tts = FlutterTts();
  bool _configured = false;
  double _rate = 0.5;
  double _pitch = 1.0;

  Future<void> _ensureConfigured() async {
    if (_configured) return;
    await _tts.setLanguage('vi-VN');
    await _tts.setSpeechRate(_rate);
    await _tts.setPitch(_pitch);
    _configured = true;
  }

  @override
  Future<bool> speak(String text) async {
    if (text.trim().isEmpty) return false;
    try {
      await _ensureConfigured();
      await _tts.stop();
      return await _tts.speak(text);
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> setRate(double rate) async {
    _rate = rate.clamp(0.0, 1.0);
    _configured = false;
  }

  @override
  Future<void> setPitch(double pitch) async {
    _pitch = pitch.clamp(0.5, 2.0);
    _configured = false;
  }
}

/// Stub cho nền tảng không hỗ trợ — luôn im lặng.
class UnsupportedTtsService implements TtsServiceBase {
  @override
  Future<bool> speak(String text) async => false;

  @override
  Future<void> setRate(double rate) async {}

  @override
  Future<void> setPitch(double pitch) async {}
}

TtsServiceBase createTtsService() => PlatformCapabilities.supportsTts
    ? TtsServiceImpl()
    : UnsupportedTtsService();
