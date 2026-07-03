import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/conversion_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/app_drawer.dart';
import '../widgets/text_input_section.dart';
import '../widgets/status_section.dart';
import '../widgets/read_only_field.dart';
import '../widgets/braille_display_section.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(conversionProvider);
    final notifier = ref.read(conversionProvider.notifier);
    final isDark = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chuyển đổi Braille'),
        centerTitle: true,
        actions: [
          Semantics(
            label: isDark
                ? 'Chuyển sang chế độ sáng'
                : 'Chuyển sang chế độ tối',
            button: true,
            child: IconButton(
              onPressed: () => ref.read(themeProvider.notifier).toggle(),
              icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
              tooltip: isDark ? 'Chế độ sáng' : 'Chế độ tối',
            ),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 600;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: isWide
                ? _buildWideLayout(context, ref, state, notifier)
                : _buildNarrowLayout(context, ref, state, notifier),
          );
        },
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã sao chép vào clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Input section shared by both layouts.
  Widget _buildInputSection(ConversionNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextInputSection(notifier: notifier),
        const SizedBox(height: 12),
        const Row(
          children: [
            Expanded(child: Divider()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('HOẶC', style: TextStyle(color: Colors.grey)),
            ),
            Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 12),
        Semantics(
          label: 'Chọn file văn bản hoặc ảnh để chuyển đổi sang Braille',
          button: true,
          child: ElevatedButton.icon(
            onPressed: () => notifier.pickAndConvert(),
            icon: const Icon(Icons.file_open),
            label: const Text('Chọn file'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  /// Output section shared by both layouts.
  Widget _buildOutputSection(
    BuildContext context,
    ConversionState state,
    ConversionNotifier notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StatusSection(state: state),
        if (state.warningMessage != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange.shade700,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    state.warningMessage!,
                    style: TextStyle(color: Colors.orange.shade900),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        if (state.originalText.isNotEmpty)
          Semantics(
            label: 'Văn bản gốc: ${state.originalText}',
            readOnly: true,
            child: ReadOnlyField(
              label: 'Văn bản gốc',
              value: state.originalText,
            ),
          ),
        if (state.originalText.isNotEmpty) const SizedBox(height: 16),
        if (state.brailleUnicode.isNotEmpty) ...[
          BrailleDisplaySection(
            brailleText: state.brailleUnicode,
            onCopy: () => _copyToClipboard(context, state.brailleUnicode),
          ),
          const SizedBox(height: 16),
        ],
        if (state.reverseText.isNotEmpty) ...[
          Semantics(
            label: 'Văn bản giải mã từ Braille: ${state.reverseText}',
            readOnly: true,
            child: ReadOnlyField(
              label: 'Văn bản giải mã (Braille → Text)',
              value: state.reverseText,
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (state.status == AppStatus.success)
          Semantics(
            label: 'Xuất file BRF để chia sẻ',
            button: true,
            child: ElevatedButton.icon(
              onPressed: () => notifier.exportBrf(),
              icon: const Icon(Icons.share),
              label: const Text('Xuất file BRF'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
      ],
    );
  }

  /// Empty state shown when no conversion has been done.
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.translate, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Nhập văn bản để bắt đầu chuyển đổi',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Hỗ trợ chữ tiếng Việt, số, dấu câu và ký hiệu toán học',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Narrow layout (single column, <600px).
  Widget _buildNarrowLayout(
    BuildContext context,
    WidgetRef ref,
    ConversionState state,
    ConversionNotifier notifier,
  ) {
    final hasOutput =
        state.status != AppStatus.idle || state.brailleUnicode.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildInputSection(notifier),
        const SizedBox(height: 16),
        if (hasOutput)
          _buildOutputSection(context, state, notifier)
        else
          _buildEmptyState(),
      ],
    );
  }

  /// Wide layout (two columns, >=600px).
  Widget _buildWideLayout(
    BuildContext context,
    WidgetRef ref,
    ConversionState state,
    ConversionNotifier notifier,
  ) {
    final hasOutput =
        state.status != AppStatus.idle || state.brailleUnicode.isNotEmpty;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildInputSection(notifier)),
        const SizedBox(width: 24),
        Expanded(
          child: hasOutput
              ? _buildOutputSection(context, state, notifier)
              : _buildEmptyState(),
        ),
      ],
    );
  }
}
