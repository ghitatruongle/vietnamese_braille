import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:viet_braille_app/presentation/screens/settings_screen.dart';

void main() {
  Widget buildSubject() {
    return const ProviderScope(child: MaterialApp(home: SettingsScreen()));
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SettingsScreen', () {
    testWidgets('renders app bar title', (tester) async {
      await tester.pumpWidget(buildSubject());
      expect(find.text('Cài đặt'), findsOneWidget);
    });

    testWidgets('shows dark mode toggle', (tester) async {
      await tester.pumpWidget(buildSubject());
      expect(find.text('Chế độ tối'), findsOneWidget);
      expect(find.byType(SwitchListTile), findsOneWidget);
    });

    testWidgets('dark mode toggle is off by default', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      final switchTile = tester.widget<SwitchListTile>(
        find.byType(SwitchListTile),
      );
      expect(switchTile.value, isFalse);
    });

    testWidgets('tapping dark mode toggle changes state', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(SwitchListTile));
      await tester.pumpAndSettle();

      final switchTile = tester.widget<SwitchListTile>(
        find.byType(SwitchListTile),
      );
      expect(switchTile.value, isTrue);
    });

    testWidgets('shows app info section', (tester) async {
      await tester.pumpWidget(buildSubject());
      expect(find.text('Thông tin ứng dụng'), findsOneWidget);
      expect(find.text('Vietnamese Braille v1.0.1'), findsOneWidget);
    });

    testWidgets('shows architecture info', (tester) async {
      await tester.pumpWidget(buildSubject());
      expect(find.text('Kiến trúc'), findsOneWidget);
      expect(
        find.text('Flutter + Riverpod + Clean Architecture'),
        findsOneWidget,
      );
    });

    testWidgets('shows Braille standard info', (tester) async {
      await tester.pumpWidget(buildSubject());
      expect(find.text('Chuẩn Braille'), findsOneWidget);
      expect(
        find.text('Braille tiếng Việt 6 chấm + BRF ASCII'),
        findsOneWidget,
      );
    });

    testWidgets('tapping app info opens about dialog', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.tap(find.text('Thông tin ứng dụng'));
      await tester.pumpAndSettle();

      expect(find.text('Vietnamese Braille'), findsOneWidget);
      expect(find.text('1.0.1'), findsOneWidget);
    });
  });
}
