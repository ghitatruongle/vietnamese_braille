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
    widget.onCharacterDecoded('');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Row 1: dots 1, 4
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [_buildDot(0), const SizedBox(width: 20), _buildDot(3)],
        ),
        const SizedBox(height: 8),
        // Row 2: dots 2, 5
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [_buildDot(1), const SizedBox(width: 20), _buildDot(4)],
        ),
        const SizedBox(height: 8),
        // Row 3: dots 3, 6
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [_buildDot(2), const SizedBox(width: 20), _buildDot(5)],
        ),
        const SizedBox(height: 16),
        Semantics(
          button: true,
          label: 'Xóa toàn bộ chấm Braille',
          onTap: _clear,
          child: ExcludeSemantics(
            child: ElevatedButton(onPressed: _clear, child: const Text('Xóa')),
          ),
        ),
      ],
    );
  }

  Widget _buildDot(int index) {
    final dotNumber = index + 1;
    final isOn = dots[index];
    return SizedBox(
      width: 48,
      height: 48,
      child: Semantics(
        label: 'Chấm $dotNumber, ${isOn ? "đang bật" : "đang tắt"}',
        button: true,
        toggled: isOn,
        onTap: () => _toggleDot(index),
        child: ExcludeSemantics(
          child: Material(
            color: isOn ? Theme.of(context).primaryColor : Colors.grey[300],
            shape: const CircleBorder(side: BorderSide(width: 2)),
            child: InkWell(
              canRequestFocus: true,
              customBorder: const CircleBorder(),
              onTap: () => _toggleDot(index),
              child: Center(
                child: Text(
                  '$dotNumber',
                  style: TextStyle(
                    color: isOn ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
