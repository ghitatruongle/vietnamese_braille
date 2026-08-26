import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../providers/theme_provider.dart';
import '../providers/tts_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);
    final fontScale = ref.watch(fontScaleProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          // Dark mode
          SwitchListTile(
            title: const Text('Chế độ tối'),
            subtitle: const Text('Giao diện tối giúp giảm mỏi mắt'),
            value: isDark,
            onChanged: (_) => ref.read(themeProvider.notifier).toggle(),
            secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
          ),
          const Divider(),
          // Font size
          ListTile(
            leading: const Icon(Icons.text_fields),
            title: const Text('Cỡ chữ'),
            subtitle: Text('${(fontScale * 100).round()}%'),
          ),
          Slider(
            value: fontScale,
            min: 0.8,
            max: 2.0,
            divisions: 12,
            label: '${(fontScale * 100).round()}%',
            onChanged: (value) {
              ref.read(fontScaleProvider.notifier).setFontScale(value);
            },
          ),
          const Divider(),
          Consumer(
            builder: (context, ref, _) {
              final markdownEnabled = ref.watch(markdownFormatProvider);
              return SwitchListTile(
                title: const Text('Hỗ trợ định dạng văn bản'),
                subtitle: const Text(
                  'Nhận diện **đậm**, *nghiêng*, _gạch chân_ trong văn bản',
                ),
                value: markdownEnabled,
                onChanged: (value) => ref
                    .read(markdownFormatProvider.notifier)
                    .setMarkdownFormat(value),
                secondary: const Icon(Icons.format_bold),
              );
            },
          ),
          const Divider(),
          // TTS (đọc to) — Phase 2C
          Consumer(
            builder: (context, ref, _) {
              final supported = ref.watch(ttsSupportedProvider);
              if (!supported) {
                return const ListTile(
                  leading: Icon(Icons.volume_off),
                  title: Text('Đọc to (TTS)'),
                  subtitle: Text('Nền tảng này không hỗ trợ đọc to.'),
                );
              }
              final rate = ref.watch(ttsRateProvider);
              final pitch = ref.watch(ttsPitchProvider);
              return Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.volume_up),
                    title: const Text('Đọc to (TTS)'),
                    subtitle: Text(
                      'Tốc độ ${(rate * 100).round()}% · '
                      'Cao độ ${pitch.toStringAsFixed(1)}×',
                    ),
                  ),
                  Slider(
                    value: rate,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    label: 'Tốc độ ${(rate * 100).round()}%',
                    onChanged: (value) =>
                        ref.read(ttsRateProvider.notifier).setRate(value),
                  ),
                  Slider(
                    value: pitch,
                    min: 0.5,
                    max: 2.0,
                    divisions: 15,
                    label: 'Cao độ ${pitch.toStringAsFixed(1)}×',
                    onChanged: (value) =>
                        ref.read(ttsPitchProvider.notifier).setPitch(value),
                  ),
                ],
              );
            },
          ),
          const Divider(),
          // About
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Thông tin ứng dụng'),
            subtitle: const Text('$kAppName v$kAppVersion'),
            onTap: () => _showAbout(context),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.code),
            title: Text('Kiến trúc'),
            subtitle: Text('Flutter + Riverpod + Clean Architecture'),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.accessibility_new),
            title: Text('Chuẩn Braille'),
            subtitle: Text('Braille tiếng Việt 6 chấm + BRF ASCII'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Quyền riêng tư'),
            subtitle: const Text(
              'Dữ liệu cục bộ, tệp, OCR và nhận dạng giọng nói',
            ),
            onTap: () => _showPrivacy(context),
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: kAppName,
      applicationVersion: kAppVersion,
      applicationLegalese:
          'Ứng dụng chuyển đổi văn bản tiếng Việt sang chữ Braille Unicode.',
      children: [
        const SizedBox(height: 16),
        const Text(
          'Hỗ trợ:\n'
          '- Chữ cái tiếng Việt có dấu\n'
          '- Chữ số với number indicator\n'
          '- Dấu câu\n'
          '- Ký hiệu toán học cơ bản\n'
          '- Xuất BRF bằng North American Braille ASCII',
        ),
      ],
    );
  }

  void _showPrivacy(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quyền riêng tư'),
        content: const SingleChildScrollView(
          child: Text(
            'Chuyển đổi Braille chạy trên thiết bị và ứng dụng không tự động '
            'tải nội dung lên máy chủ.\n\n'
            'Lịch sử và cài đặt được lưu trên thiết bị; bạn có thể xóa lịch '
            'sử trong màn hình Lịch sử. Ứng dụng chỉ đọc tệp bạn chủ động '
            'chọn.\n\n'
            'OCR dùng ML Kit trên thiết bị. Nhận dạng giọng nói dùng dịch vụ '
            'của hệ điều hành và có thể gửi âm thanh đến nhà cung cấp nền '
            'tảng tùy thiết bị và cài đặt của bạn.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
}
