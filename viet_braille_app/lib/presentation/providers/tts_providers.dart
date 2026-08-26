import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/platform_capabilities.dart';
import '../../data/tts_service.dart';

/// Nền tảng hiện tại có hỗ trợ TTS hay không (override được trong test).
final ttsSupportedProvider = Provider<bool>((ref) {
  return PlatformCapabilities.supportsTts;
});

final ttsServiceProvider = Provider<TtsServiceBase>((ref) {
  return createTtsService();
});

/// Tốc độ đọc 0.0–1.0, mặc định 0.5; lưu shared_preferences.
final ttsRateProvider = StateNotifierProvider<TtsRateNotifier, double>((ref) {
  return TtsRateNotifier();
});

class TtsRateNotifier extends StateNotifier<double> {
  TtsRateNotifier() : super(0.5) {
    _load();
  }

  static const _key = 'tts_rate';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getDouble(_key) ?? 0.5;
  }

  Future<void> setRate(double value) async {
    state = value.clamp(0.0, 1.0);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_key, state);
  }
}

/// Cao độ giọng 0.5–2.0, mặc định 1.0; lưu shared_preferences.
final ttsPitchProvider = StateNotifierProvider<TtsPitchNotifier, double>((ref) {
  return TtsPitchNotifier();
});

class TtsPitchNotifier extends StateNotifier<double> {
  TtsPitchNotifier() : super(1.0) {
    _load();
  }

  static const _key = 'tts_pitch';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getDouble(_key) ?? 1.0;
  }

  Future<void> setPitch(double value) async {
    state = value.clamp(0.5, 2.0);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_key, state);
  }
}
