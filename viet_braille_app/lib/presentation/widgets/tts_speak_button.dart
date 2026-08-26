import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/tts_providers.dart';

/// Nút đọc to một đoạn văn bản bằng TTS; tự ẩn trên nền tảng không hỗ trợ
/// hoặc khi văn bản rỗng.
class TtsSpeakButton extends ConsumerWidget {
  const TtsSpeakButton({
    super.key,
    required this.text,
    this.tooltip = 'Đọc to',
  });

  final String text;
  final String tooltip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supported = ref.watch(ttsSupportedProvider);
    if (!supported || text.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    final tts = ref.read(ttsServiceProvider);
    final rate = ref.read(ttsRateProvider);
    final pitch = ref.read(ttsPitchProvider);

    return IconButton(
      tooltip: tooltip,
      icon: const Icon(Icons.volume_up),
      onPressed: () async {
        await tts.setRate(rate);
        await tts.setPitch(pitch);
        await tts.speak(text);
      },
    );
  }
}
