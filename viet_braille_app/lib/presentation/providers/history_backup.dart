import 'dart:convert';

import '../../data/history_service.dart';

/// Phiên bản schema của tệp backup lịch sử.
const int kHistoryBackupSchemaVersion = 1;

/// Xuất danh sách bản ghi ra chuỗi JSON có schema để nhập lại sau.
String exportHistoryJson(
  List<ConversionHistoryEntry> entries, {
  DateTime? exportedAt,
}) {
  return const JsonEncoder.withIndent('  ').convert({
    'schema_version': kHistoryBackupSchemaVersion,
    'app': 'vietnamese_braille',
    'kind': 'conversion_history',
    'exported_at': (exportedAt ?? DateTime.now()).toIso8601String(),
    'entries': entries.map((e) => e.toJson()).toList(),
  });
}

/// Kết quả phân tích tệp backup: [entries] khi hợp lệ, ngược lại [error].
class HistoryParseResult {
  const HistoryParseResult(this.entries) : error = null;
  const HistoryParseResult.failure(this.error) : entries = const [];

  final List<ConversionHistoryEntry> entries;
  final String? error;

  bool get ok => error == null;
}

/// Đọc và kiểm tra chuỗi JSON backup. Không ném ngoại lệ — mọi lỗi được
/// trả về qua [HistoryParseResult.error] bằng tiếng Việt cho UI hiển thị.
HistoryParseResult parseHistoryJson(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) {
    return const HistoryParseResult.failure('Tệp rỗng.');
  }

  dynamic decoded;
  try {
    decoded = jsonDecode(trimmed);
  } on FormatException catch (e) {
    return HistoryParseResult.failure('JSON không hợp lệ: ${e.message}');
  }

  if (decoded is! Map<String, dynamic>) {
    return const HistoryParseResult.failure(
      'Cấu trúc tệp không đúng — thiếu đối tượng gốc.',
    );
  }
  if (decoded['schema_version'] != kHistoryBackupSchemaVersion) {
    return HistoryParseResult.failure(
      'Schema không hỗ trợ: ${decoded['schema_version']} '
      '(mong đợi $kHistoryBackupSchemaVersion).',
    );
  }
  if (decoded['kind'] != 'conversion_history') {
    return const HistoryParseResult.failure(
      'Tệp không phải bản sao lưu lịch sử chuyển đổi.',
    );
  }
  final rawEntries = decoded['entries'];
  if (rawEntries is! List) {
    return const HistoryParseResult.failure('Thiếu danh sách "entries".');
  }

  final entries = <ConversionHistoryEntry>[];
  for (var i = 0; i < rawEntries.length; i++) {
    try {
      final item = rawEntries[i];
      if (item is! Map<String, dynamic>) throw const FormatException();
      entries.add(ConversionHistoryEntry.fromJson(item));
    } catch (_) {
      return HistoryParseResult.failure('Bản ghi thứ ${i + 1} không hợp lệ.');
    }
  }
  return HistoryParseResult(entries);
}
