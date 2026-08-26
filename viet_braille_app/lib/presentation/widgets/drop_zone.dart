import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';

/// Vùng nhận kéo-thả tệp (desktop): bao quanh [child], khi đang kéo thì
/// phủ lớp gợi ý "thả tệp vào đây".
class DropZone extends StatefulWidget {
  const DropZone({super.key, required this.onFileDropped, required this.child});

  /// Được gọi với đường dẫn tệp đầu tiên khi người dùng thả vào cửa sổ.
  final void Function(String path) onFileDropped;
  final Widget child;

  @override
  State<DropZone> createState() => _DropZoneState();
}

class _DropZoneState extends State<DropZone> {
  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    return DropTarget(
      onDragEntered: (_) => setState(() => _dragging = true),
      onDragExited: (_) => setState(() => _dragging = false),
      onDragDone: (details) {
        setState(() => _dragging = false);
        if (details.files.isNotEmpty) {
          widget.onFileDropped(details.files.first.path);
        }
      },
      child: Stack(
        children: [
          widget.child,
          DropHintOverlay(visible: _dragging),
        ],
      ),
    );
  }
}

/// Lớp phủ gợi ý vùng thả tệp; [visible] = false thì không hiển thị gì.
///
/// Tách widget riêng để kiểm thử trực tiếp mà không cần sự kiện kéo-thả
/// từ hệ điều hành.
class DropHintOverlay extends StatelessWidget {
  const DropHintOverlay({super.key, required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    final colorScheme = Theme.of(context).colorScheme;
    return Positioned.fill(
      child: IgnorePointer(
        child: Container(
          color: colorScheme.primary.withValues(alpha: 0.15),
          padding: const EdgeInsets.all(24),
          alignment: Alignment.center,
          child: Card(
            color: colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.file_download_outlined,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      'Thả tệp TXT/DOCX/ảnh vào đây để chuyển đổi',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
