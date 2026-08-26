import 'package:flutter/material.dart';

/// Bàn phím 6 chấm kiểu Perkins.
///
/// Bố cục phím theo máy Perkins cổ điển:
/// - `S D F` = chấm 1, 2, 3 (bên trái)
/// - `J K L` = chấm 4, 5, 6 (bên phải)
///
/// Cách dùng: bật/tắt các chấm rồi nhấn **Space** để chốt một ô Braille
/// (U+2800 + bitmask) qua [onCell]; nút ⌫ gọi [onBackspace] để xóa ô cuối.
class PerkinsKeyboard extends StatefulWidget {
  const PerkinsKeyboard({super.key, required this.onCell, this.onBackspace});

  /// Được gọi khi một ô được chốt; tham số là ký tự ô Braille Unicode.
  final void Function(String cell) onCell;
  final VoidCallback? onBackspace;

  @override
  State<PerkinsKeyboard> createState() => _PerkinsKeyboardState();
}

class _PerkinsKeyboardState extends State<PerkinsKeyboard> {
  static const List<(String, int)> _keys = [
    ('S', 1),
    ('D', 2),
    ('F', 3),
    ('J', 4),
    ('K', 5),
    ('L', 6),
  ];

  final Set<int> _activeDots = {};

  void _toggle(int dot) {
    setState(() {
      if (!_activeDots.add(dot)) {
        _activeDots.remove(dot);
      }
    });
  }

  void _commitCell() {
    if (_activeDots.isEmpty) return;
    final mask = _activeDots.fold(0, (mask, dot) => mask | (1 << (dot - 1)));
    widget.onCell(String.fromCharCode(0x2800 + mask));
    setState(_activeDots.clear);
  }

  String get _previewCell => _activeDots.isEmpty
      ? ''
      : String.fromCharCode(
          0x2800 + _activeDots.fold(0, (mask, dot) => mask | (1 << (dot - 1))),
        );

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            for (var i = 0; i < _keys.length; i++) ...[
              if (i == 3) const SizedBox(width: 12),
              Expanded(
                child: Semantics(
                  button: true,
                  label: 'Chấm ${_keys[i].$2}, phím ${_keys[i].$1}',
                  child: _DotKey(
                    key: ValueKey('perkins-dot-${_keys[i].$2}'),
                    letter: _keys[i].$1,
                    dot: _keys[i].$2,
                    active: _activeDots.contains(_keys[i].$2),
                    onPressed: () => _toggle(_keys[i].$2),
                  ),
                ),
              ),
              if (i != _keys.length - 1 && i != 2) const SizedBox(width: 6),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: colorScheme.outline),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _previewCell,
                key: const ValueKey('perkins-preview'),
                style: const TextStyle(
                  fontFamily: 'NotoSansSymbols2',
                  fontSize: 24,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _commitCell,
                icon: const Icon(Icons.space_bar),
                label: const Text('Chốt ô (Space)'),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.outlined(
              onPressed: widget.onBackspace,
              tooltip: 'Xóa ô cuối',
              icon: const Icon(Icons.backspace_outlined),
            ),
          ],
        ),
      ],
    );
  }
}

class _DotKey extends StatelessWidget {
  const _DotKey({
    super.key,
    required this.letter,
    required this.dot,
    required this.active,
    required this.onPressed,
  });

  final String letter;
  final int dot;
  final bool active;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      child: Material(
        color: active
            ? colorScheme.primaryContainer
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  active ? Icons.circle : Icons.circle_outlined,
                  size: 14,
                  color: active
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 2),
                Text(
                  '$letter\n$dot',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
