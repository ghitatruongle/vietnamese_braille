import 'package:flutter/material.dart';

import '../providers/conversion_provider.dart';

/// Hiển thị trạng thái chuyển đổi: loading, error, success.
class StatusSection extends StatelessWidget {
  const StatusSection({super.key, required this.state});

  final ConversionState state;

  @override
  Widget build(BuildContext context) {
    switch (state.status) {
      case AppStatus.loading:
        return Semantics(
          label: 'Đang xử lý chuyển đổi',
          liveRegion: true,
          child: const Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Expanded(child: Text('Đang xử lý...')),
            ],
          ),
        );
      case AppStatus.error:
        return Semantics(
          label: 'Lỗi: ${state.errorMessage}',
          liveRegion: true,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    state.errorMessage ?? 'Đã xảy ra lỗi.',
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                ),
              ],
            ),
          ),
        );
      case AppStatus.success:
        return Semantics(
          label: 'Chuyển đổi thành công',
          liveRegion: true,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.green.shade700),
                const SizedBox(width: 8),
                const Expanded(child: Text('Đã chuyển đổi thành công.')),
              ],
            ),
          ),
        );
      case AppStatus.idle:
        return const SizedBox.shrink();
    }
  }
}
