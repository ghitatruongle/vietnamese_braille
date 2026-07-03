import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/speech_service.dart';
import '../providers/conversion_provider.dart';

/// Phần nhập văn bản trực tiếp với nút chuyển đổi và dán.
class TextInputSection extends StatefulWidget {
  const TextInputSection({super.key, required this.notifier});

  final ConversionNotifier notifier;

  @override
  State<TextInputSection> createState() => _TextInputSectionState();
}

class _TextInputSectionState extends State<TextInputSection> {
  final _controller = TextEditingController();
  final _speechService = SpeechService();
  bool _isListening = false;

  @override
  void dispose() {
    _controller.dispose();
    _speechService.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          label: 'Ô nhập văn bản tiếng Việt để chuyển đổi sang Braille',
          textField: true,
          child: TextField(
            controller: _controller,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Nhập văn bản tiếng Việt',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
              hintText: 'Ví dụ: Xin chào thế giới',
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Semantics(
                label: 'Chuyển đổi văn bản đã nhập sang Braille',
                button: true,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final text = _controller.text.trim();
                    if (text.isNotEmpty) {
                      widget.notifier.convertText(text);
                    }
                  },
                  icon: const Icon(Icons.translate),
                  label: const Text('Chuyển đổi'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Semantics(
              label: 'Dán văn bản từ clipboard',
              button: true,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final data = await Clipboard.getData(Clipboard.kTextPlain);
                  if (data?.text != null && data!.text!.isNotEmpty) {
                    setState(() {
                      _controller.text = data.text!;
                    });
                  }
                },
                icon: const Icon(Icons.paste),
                label: const Text('Dán'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Semantics(
              label: _isListening
                  ? 'Dừng nhận dạng giọng nói'
                  : 'Nhập liệu bằng giọng nói',
              button: true,
              child: IconButton(
                onPressed: () async {
                  if (_isListening) {
                    await _speechService.stopListening();
                    setState(() => _isListening = false);
                  } else {
                    setState(() => _isListening = true);
                    await _speechService.startListening(
                      onResult: (text) {
                        setState(() {
                          _controller.text += text;
                        });
                      },
                    );
                  }
                },
                icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
                color: _isListening ? Colors.red : null,
                tooltip: _isListening ? 'Dừng' : 'Nhập bằng giọng nói',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
