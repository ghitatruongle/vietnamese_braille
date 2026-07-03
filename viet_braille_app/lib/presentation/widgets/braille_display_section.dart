import 'package:flutter/material.dart';

/// Hiển thị kết quả Braille Unicode với nút sao chép.
class BrailleDisplaySection extends StatelessWidget {
  const BrailleDisplaySection({
    super.key,
    required this.brailleText,
    required this.onCopy,
  });

  final String brailleText;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          'Kết quả Braille Unicode: $brailleText. Nhấn nút Sao chép để copy.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Braille Unicode',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Semantics(
                label: 'Sao chép kết quả Braille vào clipboard',
                button: true,
                child: IconButton(
                  onPressed: onCopy,
                  icon: const Icon(Icons.copy),
                  tooltip: 'Sao chép',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            child: SelectableText(
              brailleText,
              style: const TextStyle(fontSize: 28, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
