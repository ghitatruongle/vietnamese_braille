import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:viet_braille_app/core/constants.dart';
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
      // Two SwitchListTiles now: dark mode + markdown format
      expect(find.byType(SwitchListTile), findsNWidgets(2));
    });

    testWidgets('dark mode toggle is off by default', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      final darkTile = tester.widget<SwitchListTile>(
        find.ancestor(
          of: find.text('Chế độ tối'),
          matching: find.byType(SwitchListTile),
        ),
      );
      expect(darkTile.value, isFalse);
    });

    testWidgets('tapping dark mode toggle changes state', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.tap(
        find.ancestor(
          of: find.text('Chế độ tối'),
          matching: find.byType(SwitchListTile),
        ),
      );
      await tester.pumpAndSettle();

      final darkTile = tester.widget<SwitchListTile>(
        find.ancestor(
          of: find.text('Chế độ tối'),
          matching: find.byType(SwitchListTile),
        ),
      );
      expect(darkTile.value, isTrue);
    });

    testWidgets('shows markdown format toggle', (tester) async {
      await tester.pumpWidget(buildSubject());
      expect(find.text('Hỗ trợ định dạng văn bản'), findsOneWidget);
    });

    testWidgets('markdown format toggle persists state', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.tap(
        find.ancestor(
          of: find.text('Hỗ trợ định dạng văn bản'),
          matching: find.byType(SwitchListTile),
        ),
      );
      await tester.pumpAndSettle();

      final tile = tester.widget<SwitchListTile>(
        find.ancestor(
          of: find.text('Hỗ trợ định dạng văn bản'),
          matching: find.byType(SwitchListTile),
        ),
      );
      expect(tile.value, isTrue);
    });

    testWidgets('shows app info section', (tester) async {
      await tester.pumpWidget(buildSubject());
      expect(find.text('Thông tin ứng dụng'), findsOneWidget);
      expect(find.text('$kAppName v$kAppVersion'), findsOneWidget);
    });

    testWidgets('shows architecture info', (tester) async {
      await tester.pumpWidget(buildSubject());
      // Mục TTS mới đẩy tile này xuống dưới nếp gấp mặc định của test.
      await tester.scrollUntilVisible(
        find.text('Kiến trúc'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Kiến trúc'), findsOneWidget);
      expect(
        find.text('Flutter + Riverpod + Clean Architecture'),
        findsOneWidget,
      );
    });

    testWidgets('shows Braille standard info', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.scrollUntilVisible(
        find.text('Chuẩn Braille'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Chuẩn Braille'), findsOneWidget);
      expect(
        find.text('Braille tiếng Việt 6 chấm + BRF ASCII'),
        findsOneWidget,
      );
    });

    testWidgets('privacy disclosure is visible from settings', (tester) async {
      await tester.pumpWidget(buildSubject());

      // Privacy tile is below the visible viewport now that markdown toggle
      // was added; scroll the ListView until visible.
      await tester.scrollUntilVisible(
        find.text('Quyền riêng tư'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Quyền riêng tư'), findsOneWidget);
      await tester.tap(find.text('Quyền riêng tư'));
      await tester.pumpAndSettle();

      expect(find.textContaining('không tự động tải nội dung'), findsOneWidget);
      expect(find.textContaining('dịch vụ của hệ điều hành'), findsOneWidget);
    });

    testWidgets('tapping app info opens about dialog', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.tap(find.text('Thông tin ứng dụng'));
      await tester.pumpAndSettle();

      expect(find.text(kAppName), findsOneWidget);
      expect(find.text(kAppVersion), findsOneWidget);
    });
  });
}
