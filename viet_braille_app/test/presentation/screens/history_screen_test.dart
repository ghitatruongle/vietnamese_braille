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

  Widget buildWithService(_FakeHistoryService service) {
    return ProviderScope(
      overrides: [historyServiceProvider.overrideWithValue(service)],
      child: const MaterialApp(home: HistoryScreen()),
    );
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('HistoryScreen', () {
    testWidgets('renders app bar with a title', (tester) async {
      await tester.pumpWidget(buildSubject());

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.title, isA<Text>());
      expect((appBar.title! as Text).data, isNotEmpty);
    });

    testWidgets('shows empty state when no history', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

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
            '[{"originalText":"entry","brailleText":"braille",'
            '"timestamp":"2025-01-15T10:30:00.000"}]',
      });

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('entry'), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('uses historyServiceProvider with interface', (tester) async {
      final container = ProviderContainer(
        overrides: [
          historyServiceProvider.overrideWithValue(_FakeHistoryService()),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: HistoryScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Fake entry'), findsOneWidget);
    });

    testWidgets('filters entries and clears the search query', (tester) async {
      final service = _FakeHistoryService(
        entries: [
          _entry('Alpha entry', 'alpha braille'),
          _entry('Beta entry', 'beta braille'),
        ],
      );
      await tester.pumpWidget(buildWithService(service));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'alpha');
      await tester.pump();
      expect(find.text('Alpha entry'), findsOneWidget);
      expect(find.text('Beta entry'), findsNothing);

      await tester.enterText(find.byType(TextField), 'missing');
      await tester.pump();
      expect(find.byIcon(Icons.search_off), findsOneWidget);

      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();
      expect(find.text('Alpha entry'), findsOneWidget);
      expect(find.text('Beta entry'), findsOneWidget);
    });

    testWidgets('can cancel and confirm clearing all history', (tester) async {
      final service = _FakeHistoryService();
      await tester.pumpWidget(buildWithService(service));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(TextButton).first);
      await tester.pumpAndSettle();
      expect(service.clearCalls, 0);
      expect(find.text('Fake entry'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(TextButton).last);
      await tester.pumpAndSettle();
      expect(service.clearCalls, 1);
      expect(find.text('Fake entry'), findsNothing);
      expect(find.byIcon(Icons.history), findsOneWidget);
    });

    testWidgets('copies Braille and opens entry details', (tester) async {
      final service = _FakeHistoryService();
      await tester.pumpWidget(buildWithService(service));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.copy));
      await tester.pump();
      expect(find.byType(SnackBar), findsOneWidget);

      await tester.tap(find.text('Fake entry'));
      await tester.pumpAndSettle();
      expect(find.byType(DraggableScrollableSheet), findsOneWidget);
      expect(find.text('Fake entry'), findsNWidgets(2));
      expect(find.text('fake braille'), findsOneWidget);
    });
  });
}

class _FakeHistoryService implements HistoryServiceBase {
  _FakeHistoryService({List<ConversionHistoryEntry>? entries})
    : _entries = entries ?? [_entry('Fake entry', 'fake braille')];

  final List<ConversionHistoryEntry> _entries;
  int clearCalls = 0;

  @override
  Future<List<ConversionHistoryEntry>> loadHistory() async {
    return List.of(_entries);
  }

  @override
  Future<void> saveEntry(ConversionHistoryEntry entry) async {}

  @override
  Future<void> clearHistory() async {
    clearCalls++;
    _entries.clear();
  }

  @override
  Future<void> deleteEntry(int index) async {
    _entries.removeAt(index);
  }

  @override
  Future<List<ConversionHistoryEntry>> searchHistory(String query) async {
    final normalized = query.toLowerCase();
    return _entries
        .where(
          (entry) =>
              entry.originalText.toLowerCase().contains(normalized) ||
              entry.brailleText.toLowerCase().contains(normalized),
        )
        .toList();
  }
}

ConversionHistoryEntry _entry(String originalText, String brailleText) {
  return ConversionHistoryEntry(
    originalText: originalText,
    brailleText: brailleText,
    timestamp: DateTime(2025, 1, 1),
  );
}
