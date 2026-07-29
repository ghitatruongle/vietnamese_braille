import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viet_braille_app/teaching/learning_screen.dart';

void main() {
  group('LearningScreen', () {
    testWidgets('hiển thị tiêu đề app bar', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: LearningScreen()));

      expect(find.text('Học chữ Braille'), findsOneWidget);
    });

    testWidgets('hiển thị hướng dẫn và mục bảng chữ cái', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: LearningScreen()));

      expect(
        find.text('Chạm vào các điểm để tạo ký tự Braille'),
        findsOneWidget,
      );
      expect(find.text('Bảng chữ cái Braille tiếng Việt'), findsOneWidget);
    });

    testWidgets('chạm dot 1 sẽ giải mã và hiển thị ký tự Braille', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: LearningScreen()));

      await tester.tap(find.text('1'));
      await tester.pump();

      // dot 1 bật => value = 1 => U+2801
      expect(find.textContaining('Ký tự Braille:'), findsOneWidget);
      expect(find.textContaining('U+2801'), findsOneWidget);
    });

    testWidgets('mỗi chấm có trạng thái ngữ nghĩa và hỗ trợ bàn phím', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(const MaterialApp(home: LearningScreen()));

      expect(find.bySemanticsLabel('Chấm 1, đang tắt'), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(find.bySemanticsLabel('Chấm 1, đang bật'), findsOneWidget);
      expect(
        find.bySemanticsLabel('Ký tự đã tạo: ô Braille có chấm 1'),
        findsOneWidget,
      );
      semantics.dispose();
    });

    testWidgets('xóa lưới cũng xóa kết quả ký tự hiện tại', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: LearningScreen()));

      await tester.tap(find.text('1'));
      await tester.pump();
      expect(find.textContaining('Ký tự Braille:'), findsOneWidget);

      await tester.tap(find.text('Xóa'));
      await tester.pump();
      expect(find.textContaining('Ký tự Braille:'), findsNothing);
    });
  });
}
