import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ConversionHistoryEntry {
  const ConversionHistoryEntry({
    required this.originalText,
    required this.brailleText,
    required this.timestamp,
  });

  final String originalText;
  final String brailleText;
  final DateTime timestamp;

  Map<String, dynamic> toJson() => {
    'originalText': originalText,
    'brailleText': brailleText,
    'timestamp': timestamp.toIso8601String(),
  };

  factory ConversionHistoryEntry.fromJson(Map<String, dynamic> json) =>
      ConversionHistoryEntry(
        originalText: json['originalText'] as String,
        brailleText: json['brailleText'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}

/// Interface cho dịch vụ lưu trữ lịch sử chuyển đổi.
abstract class HistoryServiceBase {
  Future<List<ConversionHistoryEntry>> loadHistory();
  Future<void> saveEntry(ConversionHistoryEntry entry);
  Future<void> clearHistory();
  Future<void> deleteEntry(int index);
  Future<List<ConversionHistoryEntry>> searchHistory(String query);

  /// Ghi đè toàn bộ lịch sử (nhập backup chế độ "thay thế").
  /// Trả về số bản ghi đã ghi (chịu giới hạn số mục tối đa).
  Future<int> replaceAll(List<ConversionHistoryEntry> entries);

  /// Gộp [entries] vào lịch sử hiện có, bỏ qua bản ghi trùng lặp (so khớp
  /// thời điểm + nội dung). Trả về số bản ghi mới được thêm.
  Future<int> mergeEntries(List<ConversionHistoryEntry> entries);
}

class HistoryServiceImpl implements HistoryServiceBase {
  static const _key = 'conversion_history';
  static const _maxEntries = 50;
  static const _maxAgeDays = 30;
  Future<void> _mutationQueue = Future<void>.value();

  @override
  Future<List<ConversionHistoryEntry>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    if (json == null) return [];
    final list = jsonDecode(json) as List;
    return list
        .map((e) => ConversionHistoryEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveEntry(ConversionHistoryEntry entry) {
    return _enqueueMutation(() => _saveEntry(entry));
  }

  Future<void> _saveEntry(ConversionHistoryEntry entry) async {
    final history = await loadHistory();
    history.insert(0, entry);

    // Auto-cleanup: remove entries older than max age
    final cutoff = DateTime.now().subtract(const Duration(days: _maxAgeDays));
    history.removeWhere((e) => e.timestamp.isBefore(cutoff));

    // Enforce max entries limit
    if (history.length > _maxEntries) {
      history.removeRange(_maxEntries, history.length);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(history.map((e) => e.toJson()).toList()),
    );
  }

  @override
  Future<void> clearHistory() {
    return _enqueueMutation(_clearHistory);
  }

  Future<void> _clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  @override
  Future<void> deleteEntry(int index) {
    return _enqueueMutation(() => _deleteEntry(index));
  }

  Future<void> _deleteEntry(int index) async {
    final history = await loadHistory();
    if (index >= 0 && index < history.length) {
      history.removeAt(index);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _key,
        jsonEncode(history.map((e) => e.toJson()).toList()),
      );
    }
  }

  @override
  Future<List<ConversionHistoryEntry>> searchHistory(String query) async {
    final history = await loadHistory();
    if (query.isEmpty) return history;
    final lowerQuery = query.toLowerCase();
    return history
        .where(
          (e) =>
              e.originalText.toLowerCase().contains(lowerQuery) ||
              e.brailleText.toLowerCase().contains(lowerQuery),
        )
        .toList();
  }

  @override
  Future<int> replaceAll(List<ConversionHistoryEntry> entries) {
    return _enqueueMutationWithValue(entries, _replaceAll);
  }

  Future<int> _replaceAll(List<ConversionHistoryEntry> entries) async {
    final capped = entries.take(_maxEntries).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(capped.map((e) => e.toJson()).toList()),
    );
    return capped.length;
  }

  @override
  Future<int> mergeEntries(List<ConversionHistoryEntry> entries) {
    return _enqueueMutationWithValue(entries, _mergeEntries);
  }

  Future<int> _mergeEntries(List<ConversionHistoryEntry> entries) async {
    final history = await loadHistory();
    final seen = history.map(_identityOf).toSet();
    var added = 0;
    for (final entry in entries) {
      if (seen.add(_identityOf(entry))) {
        history.add(entry);
        added++;
      }
    }
    // Chuẩn hóa thứ tự mới nhất đứng đầu bất kể thứ tự trong tệp backup.
    history.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    if (history.length > _maxEntries) {
      history.removeRange(_maxEntries, history.length);
    }
    if (added > 0) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _key,
        jsonEncode(history.map((e) => e.toJson()).toList()),
      );
    }
    return added;
  }

  static String _identityOf(ConversionHistoryEntry e) =>
      '${e.timestamp.toIso8601String()}|${e.originalText}|${e.brailleText}';

  /// Tuần tự hóa mutation có giá trị trả về.
  Future<int> _enqueueMutationWithValue(
    List<ConversionHistoryEntry> arg,
    Future<int> Function(List<ConversionHistoryEntry>) mutation,
  ) {
    final operation = _mutationQueue.then((_) => mutation(arg));
    _mutationQueue = operation.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    return operation;
  }

  /// Tuần tự hóa mọi mutation để hai lần chuyển đổi đồng thời không cùng đọc
  /// một snapshot cũ rồi ghi đè lịch sử của nhau.
  Future<void> _enqueueMutation(Future<void> Function() mutation) {
    final operation = _mutationQueue.then((_) => mutation());
    _mutationQueue = operation.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    return operation;
  }
}
