import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:viet_braille_app/data/history_service.dart';

void main() {
  late HistoryServiceImpl service;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    service = HistoryServiceImpl();
  });

  group('HistoryService', () {
    test('loadHistory returns empty list initially', () async {
      final history = await service.loadHistory();
      expect(history, isEmpty);
    });

    test('saveEntry + loadHistory round-trip', () async {
      final entry = ConversionHistoryEntry(
        originalText: 'xin chào',
        brailleText: 'braille_data',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      );

      await service.saveEntry(entry);
      final history = await service.loadHistory();

      expect(history, hasLength(1));
      expect(history.first.originalText, equals('xin chào'));
      expect(history.first.brailleText, equals('braille_data'));
    });

    test('newest entry appears first', () async {
      await service.saveEntry(
        ConversionHistoryEntry(
          originalText: 'first',
          brailleText: 'b1',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        ),
      );
      await service.saveEntry(
        ConversionHistoryEntry(
          originalText: 'second',
          brailleText: 'b2',
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        ),
      );

      final history = await service.loadHistory();
      expect(history.first.originalText, equals('second'));
    });

    test('concurrent saves are serialized without losing entries', () async {
      final now = DateTime.now();
      await Future.wait([
        for (var i = 0; i < 20; i++)
          service.saveEntry(
            ConversionHistoryEntry(
              originalText: 'concurrent $i',
              brailleText: 'b$i',
              timestamp: now.add(Duration(microseconds: i)),
            ),
          ),
      ]);

      final history = await service.loadHistory();
      expect(history, hasLength(20));
      expect(history.map((entry) => entry.originalText).toSet(), hasLength(20));
    });

    test('clearHistory removes all entries', () async {
      await service.saveEntry(
        ConversionHistoryEntry(
          originalText: 'test',
          brailleText: 'braille',
          timestamp: DateTime.now(),
        ),
      );

      await service.clearHistory();
      final history = await service.loadHistory();
      expect(history, isEmpty);
    });

    test('max 50 entries enforced', () async {
      for (int i = 0; i < 55; i++) {
        await service.saveEntry(
          ConversionHistoryEntry(
            originalText: 'entry $i',
            brailleText: 'b$i',
            timestamp: DateTime.now().subtract(Duration(minutes: i)),
          ),
        );
      }

      final history = await service.loadHistory();
      expect(history.length, equals(50));
      // Newest (i=54) should be first
      expect(history.first.originalText, equals('entry 54'));
    });

    test('ConversionHistoryEntry JSON round-trip', () {
      final entry = ConversionHistoryEntry(
        originalText: 'test',
        brailleText: 'braille',
        timestamp: DateTime(2025, 6, 15, 14, 30),
      );

      final json = entry.toJson();
      final restored = ConversionHistoryEntry.fromJson(json);

      expect(restored.originalText, equals(entry.originalText));
      expect(restored.brailleText, equals(entry.brailleText));
      expect(restored.timestamp, equals(entry.timestamp));
    });

    test('deleteEntry removes specific entry by index', () async {
      await service.saveEntry(
        ConversionHistoryEntry(
          originalText: 'first',
          brailleText: 'b1',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        ),
      );
      await service.saveEntry(
        ConversionHistoryEntry(
          originalText: 'second',
          brailleText: 'b2',
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        ),
      );

      // Delete the newest entry (index 0)
      await service.deleteEntry(0);
      final history = await service.loadHistory();
      expect(history, hasLength(1));
      expect(history.first.originalText, equals('first'));
    });

    test('deleteEntry with invalid index does nothing', () async {
      await service.saveEntry(
        ConversionHistoryEntry(
          originalText: 'test',
          brailleText: 'b',
          timestamp: DateTime.now(),
        ),
      );

      await service.deleteEntry(-1);
      await service.deleteEntry(5);
      final history = await service.loadHistory();
      expect(history, hasLength(1));
    });

    test('searchHistory filters by original text', () async {
      await service.saveEntry(
        ConversionHistoryEntry(
          originalText: 'xin chào',
          brailleText: 'b1',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        ),
      );
      await service.saveEntry(
        ConversionHistoryEntry(
          originalText: 'tạm biệt',
          brailleText: 'b2',
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        ),
      );

      final results = await service.searchHistory('xin');
      expect(results, hasLength(1));
      expect(results.first.originalText, equals('xin chào'));
    });

    test('searchHistory with empty query returns all', () async {
      await service.saveEntry(
        ConversionHistoryEntry(
          originalText: 'a',
          brailleText: 'b1',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        ),
      );
      await service.saveEntry(
        ConversionHistoryEntry(
          originalText: 'b',
          brailleText: 'b2',
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        ),
      );

      final results = await service.searchHistory('');
      expect(results, hasLength(2));
    });

    test('auto-cleanup removes old entries', () async {
      // Save an entry with a very old timestamp
      final oldEntry = ConversionHistoryEntry(
        originalText: 'old',
        brailleText: 'b_old',
        timestamp: DateTime.now().subtract(const Duration(days: 60)),
      );
      // Manually insert old entry
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'conversion_history',
        jsonEncode([oldEntry.toJson()]),
      );

      // Save a new entry - should trigger cleanup
      await service.saveEntry(
        ConversionHistoryEntry(
          originalText: 'new',
          brailleText: 'b_new',
          timestamp: DateTime.now(),
        ),
      );

      final history = await service.loadHistory();
      expect(history, hasLength(1));
      expect(history.first.originalText, equals('new'));
    });
  });
}
