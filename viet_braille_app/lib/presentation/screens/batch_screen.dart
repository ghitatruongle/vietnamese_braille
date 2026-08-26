import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';

import '../providers/batch_conversion_providers.dart';

/// Màn hình chuyển đổi batch: chọn nhiều file TXT/DOCX, convert từng file,
/// xuất tất cả thành BRF vào thư mục do người dùng chọn.
class BatchScreen extends ConsumerWidget {
  const BatchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(batchConversionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Chuyển đổi hàng loạt')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: state.isConverting
                        ? null
                        : () => ref
                              .read(batchConversionProvider.notifier)
                              .pickFiles(),
                    icon: const Icon(Icons.file_open),
                    label: const Text('Chọn file TXT/DOCX'),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: state.items.isEmpty || state.isConverting
                      ? null
                      : () => ref
                            .read(batchConversionProvider.notifier)
                            .convertAll(),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Chuyển đổi'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: state.items.isEmpty || state.isConverting
                      ? null
                      : () =>
                            ref.read(batchConversionProvider.notifier).clear(),
                  icon: const Icon(Icons.clear),
                  label: const Text('Xóa'),
                ),
              ],
            ),
          ),
          if (state.items.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    'Tổng: ${state.items.length} • '
                    'Thành công: ${state.successCount} • '
                    'Lỗi: ${state.errorCount}',
                  ),
                  const Spacer(),
                  OutlinedButton.icon(
                    onPressed: state.successCount == 0 || state.isConverting
                        ? null
                        : () => _exportBrf(context, ref),
                    icon: const Icon(Icons.folder_zip),
                    label: const Text('Xuất BRF ra thư mục'),
                  ),
                ],
              ),
            ),
          if (state.isConverting)
            const Padding(
              padding: EdgeInsets.all(8),
              child: LinearProgressIndicator(),
            ),
          const Divider(height: 1),
          Expanded(
            child: state.items.isEmpty
                ? const _EmptyState()
                : ListView.builder(
                    itemCount: state.items.length,
                    itemBuilder: (context, index) {
                      final item = state.items[index];
                      return _BatchTile(item: item);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportBrf(BuildContext context, WidgetRef ref) async {
    final directory = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Chọn thư mục xuất BRF',
    );
    if (directory == null) return;

    try {
      final written = await ref
          .read(batchConversionProvider.notifier)
          .exportBrfFiles(directory);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã xuất $written file BRF vào $directory')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Xuất BRF thất bại: $e')));
      }
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.folder_open, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'Chưa có file nào. Nhấn "Chọn file" để bắt đầu.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _BatchTile extends StatelessWidget {
  const _BatchTile({required this.item});

  final BatchFileResult item;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _StatusIcon(status: item.status),
      title: Text(item.fileName),
      subtitle: item.errorMessage != null
          ? Text(
              item.errorMessage!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            )
          : item.warningMessage != null
          ? Text(item.warningMessage!)
          : item.status == BatchFileStatus.success
          ? Text(
              '${item.brailleUnicode.length} ký tự Braille • ${item.brfContent.length} bytes BRF',
            )
          : null,
      trailing: item.status == BatchFileStatus.converting
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : null,
    );
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.status});
  final BatchFileStatus status;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case BatchFileStatus.pending:
        return const Icon(Icons.schedule, color: Colors.grey);
      case BatchFileStatus.converting:
        return const Icon(Icons.hourglass_empty, color: Colors.blue);
      case BatchFileStatus.success:
        return const Icon(Icons.check_circle, color: Colors.green);
      case BatchFileStatus.error:
        return const Icon(Icons.error, color: Colors.red);
    }
  }
}
