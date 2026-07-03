import 'package:speech_to_text/speech_to_text.dart';

/// Dịch vụ nhận dạng giọng nói, hỗ trợ tiếng Việt.
class SpeechService {
  final SpeechToText _speech = SpeechToText();
  bool _isInitialized = false;

  Future<bool> initialize() async {
    _isInitialized = await _speech.initialize();
    return _isInitialized;
  }

  Future<void> startListening({
    required Function(String) onResult,
    String localeId = 'vi_VN',
  }) async {
    if (!_isInitialized) await initialize();
    await _speech.listen(
      onResult: (result) => onResult(result.recognizedWords),
      listenOptions: SpeechListenOptions(localeId: localeId),
    );
  }

  Future<void> stopListening() async {
    await _speech.stop();
  }

  bool get isListening => _speech.isListening;
}
