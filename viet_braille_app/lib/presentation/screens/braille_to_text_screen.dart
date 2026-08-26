import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/reverse_conversion_providers.dart';
import '../widgets/perkins_keyboard.dart';
import '../widgets/read_only_field.dart';
import '../widgets/tts_speak_button.dart';

/// Màn hình chuyển ngược: dán ô Braille Unicode → văn bản tiếng Việt.
class BrailleToTextScreen extends ConsumerStatefulWidget {
  const BrailleToTextScreen({super.key});

  @override
  ConsumerState<BrailleToTextScreen> createState() =>
      _BrailleToTextScreenState();
}

class _BrailleToTextScreenState extends ConsumerState<BrailleToTextScreen> {
  late final TextEditingController _brailleController;
  final FocusNode _brailleFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _brailleController = TextEditingController();
  }

  @override
  void dispose() {
    _brailleController.dispose();
    _brailleFocus.dispose();
    super.dispose();
  }

  void _pasteBraille() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.isNotEmpty) {
      _brailleController.text = data.text!;
      ref.read(reverseConversionProvider.notifier).setBrailleInput(data.text!);
    }
  }

  void _convert() {
    ref
        .read(reverseConversionProvider.notifier)
        .setBrailleInput(_brailleController.text);
    ref.read(reverseConversionProvider.notifier).convert();
  }

  void _clear() {
    _brailleController.clear();
    ref.read(reverseConversionProvider.notifier).clear();
  }

  void _copyResult() async {
    final result = ref.read(reverseConversionProvider).result;
    if (result.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: result));
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đã sao chép kết quả')));
      }
    }
  }

  /// Chèn [inserted] tại vị trí con trỏ (thay vùng đang chọn nếu có),
  /// rồi đặt con trỏ ngay sau nội dung mới chèn.
  void _insertAtCursor(String inserted) {
    final text = _brailleController.text;
    var start = _brailleController.selection.baseOffset;
    var end = _brailleController.selection.extentOffset;
    if (start < 0 || end < 0) {
      start = text.length;
      end = text.length;
    }
    if (start > end) {
      final tmp = start;
      start = end;
      end = tmp;
    }
    _brailleController
      ..text = text.replaceRange(start, end, inserted)
      ..selection = TextSelection.collapsed(offset: start + inserted.length);
  }

  /// Xóa 1 ký tự trước con trỏ, hoặc xóa toàn bộ vùng chọn nếu có.
  void _deleteBeforeCursor() {
    final text = _brailleController.text;
    var start = _brailleController.selection.baseOffset;
    var end = _brailleController.selection.extentOffset;
    if (start < 0 || end < 0) {
      start = text.length;
      end = text.length;
    }
    if (start > end) {
      final tmp = start;
      start = end;
      end = tmp;
    }
    if (start == end) {
      if (start == 0) return;
      start -= 1;
    }
    _brailleController
      ..text = text.replaceRange(start, end, '')
      ..selection = TextSelection.collapsed(offset: start);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reverseConversionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Braille → Văn bản')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _brailleController,
              focusNode: _brailleFocus,
              maxLines: 4,
              style: const TextStyle(fontFamily: 'NotoSansSymbols2'),
              decoration: const InputDecoration(
                labelText: 'Ô Braille Unicode',
                hintText: 'Dán ô Braille tại đây, ví dụ: ⠎⠁⠊ ⠃⠁⠝⠓',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => ref
                  .read(reverseConversionProvider.notifier)
                  .setBrailleInput(value),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _convert,
                    icon: const Icon(Icons.swap_horiz),
                    label: const Text('Chuyển đổi'),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _pasteBraille,
                  icon: const Icon(Icons.content_paste),
                  label: const Text('Dán'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _clear,
                  icon: const Icon(Icons.clear),
                  label: const Text('Xóa'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Bàn phím 6 chấm (Perkins)'),
            const SizedBox(height: 8),
            PerkinsKeyboard(
              onCell: (cell) {
                setState(() {
                  _insertAtCursor(cell);
                });
                ref
                    .read(reverseConversionProvider.notifier)
                    .setBrailleInput(_brailleController.text);
              },
              onBackspace: () {
                setState(() {
                  _deleteBeforeCursor();
                });
                ref
                    .read(reverseConversionProvider.notifier)
                    .setBrailleInput(_brailleController.text);
              },
            ),
            const SizedBox(height: 16),
            if (state.warnings.isNotEmpty) ...[
              for (final warning in state.warnings)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    warning,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              const SizedBox(height: 8),
            ],
            ReadOnlyField(label: 'Văn bản tiếng Việt', value: state.result),
            const SizedBox(height: 12),
            if (state.result.isNotEmpty)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _copyResult,
                      icon: const Icon(Icons.copy),
                      label: const Text('Sao chép kết quả'),
                    ),
                  ),
                  TtsSpeakButton(text: state.result),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
