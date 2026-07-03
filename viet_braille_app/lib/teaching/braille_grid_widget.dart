import 'package:flutter/material.dart';

/// Widget lưới 6 điểm Braille tương tác — chạm để bật/tắt dots.
class BrailleGridWidget extends StatefulWidget {
  final Function(String) onCharacterDecoded;

  const BrailleGridWidget({super.key, required this.onCharacterDecoded});

  @override
  State<BrailleGridWidget> createState() => _BrailleGridWidgetState();
}

class _BrailleGridWidgetState extends State<BrailleGridWidget> {
  // 6 dots: positions 1-6
  // Row 1: dots 1, 4
  // Row 2: dots 2, 5
  // Row 3: dots 3, 6
  List<bool> dots = List.filled(6, false);

  void _toggleDot(int index) {
    setState(() => dots[index] = !dots[index]);
    _decodeCharacter();
  }

  void _decodeCharacter() {
    int value = 0;
    for (int i = 0; i < 6; i++) {
      if (dots[i]) value += (1 << i);
    }
    final char = String.fromCharCode(0x2800 + value);
    widget.onCharacterDecoded(char);
  }

  void _clear() {
    setState(() => dots = List.filled(6, false));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Row 1: dots 1, 4
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDot(0, 'Dot 1'),
            const SizedBox(width: 20),
            _buildDot(3, 'Dot 4'),
          ],
        ),
        const SizedBox(height: 8),
        // Row 2: dots 2, 5
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDot(1, 'Dot 2'),
            const SizedBox(width: 20),
            _buildDot(4, 'Dot 5'),
          ],
        ),
        const SizedBox(height: 8),
        // Row 3: dots 3, 6
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDot(2, 'Dot 3'),
            const SizedBox(width: 20),
            _buildDot(5, 'Dot 6'),
          ],
        ),
        const SizedBox(height: 16),
        ElevatedButton(onPressed: _clear, child: const Text('Xóa')),
      ],
    );
  }

  Widget _buildDot(int index, String label) {
    return Semantics(
      label: '$label - ${dots[index] ? "bật" : "tắt"}',
      button: true,
      child: GestureDetector(
        onTap: () => _toggleDot(index),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: dots[index]
                ? Theme.of(context).primaryColor
                : Colors.grey[300],
            border: Border.all(width: 2),
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: TextStyle(
                color: dots[index] ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
