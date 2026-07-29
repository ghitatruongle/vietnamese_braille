import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viet_braille_app/teaching/learning_screen.dart';
import 'package:viet_braille_app/teaching/quiz_screen.dart';

void main() {
  Future<void> setDesktopViewport(WidgetTester tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
  }

  Future<void> audit(WidgetTester tester, Widget screen) async {
    await setDesktopViewport(tester);
    await tester.pumpWidget(MaterialApp(home: screen));
    await tester.pumpAndSettle();

    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
  }

  testWidgets('màn hình học đạt các guideline tự động', (tester) async {
    await audit(tester, const LearningScreen());
  });

  testWidgets('màn hình quiz đạt các guideline tự động', (tester) async {
    await audit(tester, const QuizScreen());
  });

  testWidgets('quiz không tràn bố cục ở cỡ chữ 200%', (tester) async {
    await setDesktopViewport(tester);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: const QuizScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
