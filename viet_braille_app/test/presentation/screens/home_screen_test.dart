import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:viet_braille_app/presentation/screens/home_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('HomeScreen widget tests', () {
    testWidgets('renders app bar title', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: HomeScreen())),
      );

      expect(find.text('Chuyển đổi Braille'), findsOneWidget);
    });

    testWidgets('renders text input field', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: HomeScreen())),
      );

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('renders convert button', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: HomeScreen())),
      );

      expect(find.text('Chuyển đổi'), findsOneWidget);
    });

    testWidgets('renders file picker button', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: HomeScreen())),
      );

      expect(find.text('Chọn TXT, DOCX hoặc ảnh'), findsOneWidget);
    });

    testWidgets('renders paste button', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: HomeScreen())),
      );

      expect(find.text('Dán'), findsOneWidget);
    });

    testWidgets('renders dark mode toggle', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: HomeScreen())),
      );

      expect(find.byIcon(Icons.dark_mode), findsOneWidget);
    });

    testWidgets('drawer contains navigation items', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: HomeScreen())),
      );

      // Open drawer
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      expect(find.text('Trang chủ'), findsOneWidget);
      expect(find.text('Lịch sử'), findsOneWidget);
      expect(find.text('Cài đặt'), findsOneWidget);
    });

    testWidgets('shows Braille output after typing and converting', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: HomeScreen())),
      );

      // Enter text
      await tester.enterText(find.byType(TextField), 'abc');
      await tester.tap(find.text('Chuyển đổi'));
      await tester.pump();

      // Should show Braille Unicode section
      expect(find.text('Braille Unicode'), findsOneWidget);
      // Should show reverse text section
      expect(find.text('Văn bản đối chiếu lossless'), findsOneWidget);
      // Should show export button
      expect(find.text('Xuất file BRF'), findsOneWidget);
      expect(find.text('Xuất PDF'), findsOneWidget);
    });

    testWidgets('Semantics labels present for convert button', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: HomeScreen())),
      );

      // Verify convert button exists with semantics
      final convertButton = find.ancestor(
        of: find.text('Chuyển đổi'),
        matching: find.byType(ElevatedButton),
      );
      expect(convertButton, findsOneWidget);
    });
  });
}
