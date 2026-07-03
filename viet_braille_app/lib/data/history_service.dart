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
}

class HistoryServiceImpl implements HistoryServiceBase {
  static const _key = 'conversion_history';
  static const _maxEntries = 50;
  static const _maxAgeDays = 30;

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
  Future<void> saveEntry(ConversionHistoryEntry entry) async {
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
  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  @override
  Future<void> deleteEntry(int index) async {
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
}
