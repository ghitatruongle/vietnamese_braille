import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:viet_braille_app/data/ocr_processor.dart';
import 'package:viet_braille_app/presentation/providers/conversion_provider.dart';
import 'package:viet_braille_app/presentation/screens/history_screen.dart';
import 'package:viet_braille_app/presentation/screens/home_screen.dart';
import 'package:viet_braille_app/presentation/screens/settings_screen.dart';

void main() {
  Future<void> setDesktopViewport(WidgetTester tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
  }

  Future<void> audit(WidgetTester tester, Widget screen) async {
    await setDesktopViewport(tester);
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ocrProcessorProvider.overrideWithValue(
            const UnsupportedOcrProcessor(),
          ),
        ],
        child: MaterialApp(home: screen),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
  }

  Future<void> auditAtTwoHundredPercent(
    WidgetTester tester,
    Widget screen,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(400, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ocrProcessorProvider.overrideWithValue(
            const UnsupportedOcrProcessor(),
          ),
        ],
        child: MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          ),
          home: screen,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  }

  testWidgets('home screen meets automated accessibility guidelines', (
    tester,
  ) async {
    await audit(tester, const HomeScreen());
  });

  testWidgets('converted output meets automated accessibility guidelines', (
    tester,
  ) async {
    await setDesktopViewport(tester);
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ocrProcessorProvider.overrideWithValue(
            const UnsupportedOcrProcessor(),
          ),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.enterText(find.byType(TextField), 'Việt Nam');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Chuyển đổi'));
    await tester.pumpAndSettle();

    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
  });

  testWidgets('history screen meets automated accessibility guidelines', (
    tester,
  ) async {
    await audit(tester, const HistoryScreen());
  });

  testWidgets('settings screen meets automated accessibility guidelines', (
    tester,
  ) async {
    await audit(tester, const SettingsScreen());
  });

  for (final entry in <(String, Widget)>[
    ('home', const HomeScreen()),
    ('history', const HistoryScreen()),
    ('settings', const SettingsScreen()),
  ]) {
    testWidgets('${entry.$1} does not overflow at 200% text', (tester) async {
      await auditAtTwoHundredPercent(tester, entry.$2);
    });
  }
}
