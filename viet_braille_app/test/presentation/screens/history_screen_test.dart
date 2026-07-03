import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:viet_braille_app/data/history_service.dart';
import 'package:viet_braille_app/presentation/providers/history_provider.dart';
import 'package:viet_braille_app/presentation/screens/history_screen.dart';

void main() {
  Widget buildSubject() {
    return const ProviderScope(child: MaterialApp(home: HistoryScreen()));
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('HistoryScreen', () {
    testWidgets('renders app bar with title', (tester) async {
      await tester.pumpWidget(buildSubject());
      expect(find.text('Lịch sử chuyển đổi'), findsOneWidget);
    });

    testWidgets('shows empty state when no history', (tester) async {
      await tester.pumpWidget(buildSubject());
      // Wait for async load
      await tester.pumpAndSettle();
      expect(find.text('Chưa có lịch sử chuyển đổi'), findsOneWidget);
      expect(find.byIcon(Icons.history), findsOneWidget);
    });

    testWidgets('does not show delete button when empty', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.delete_outline), findsNothing);
    });

    testWidgets('shows history entries when data exists', (tester) async {
      SharedPreferences.setMockInitialValues({
        'conversion_history':
            '[{"originalText":"xin chào","brailleText":"⠓⠊⠝","timestamp":"2025-01-15T10:30:00.000"}]',
      });

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.textContaining('xin chào'), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('uses historyServiceProvider with interface', (tester) async {
      final container = ProviderContainer(
        overrides: [
          historyServiceProvider.overrideWithValue(_FakeHistoryService()),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: HistoryScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Fake entry'), findsOneWidget);
    });
  });
}

class _FakeHistoryService implements HistoryServiceBase {
  @override
  Future<List<ConversionHistoryEntry>> loadHistory() async {
    return [
      ConversionHistoryEntry(
        originalText: 'Fake entry',
        brailleText: '⠋⠁⠅⠑',
        timestamp: DateTime(2025, 1, 1),
      ),
    ];
  }

  @override
  Future<void> saveEntry(ConversionHistoryEntry entry) async {}

  @override
  Future<void> clearHistory() async {}

  @override
  Future<void> deleteEntry(int index) async {}

  @override
  Future<List<ConversionHistoryEntry>> searchHistory(String query) async {
    return loadHistory();
  }
}
