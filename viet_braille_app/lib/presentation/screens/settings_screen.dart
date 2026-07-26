import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/theme_provider.dart';

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
          // About
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Thông tin ứng dụng'),
            subtitle: const Text('Vietnamese Braille v1.0.0'),
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
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Vietnamese Braille',
      applicationVersion: '1.0.0',
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
}
