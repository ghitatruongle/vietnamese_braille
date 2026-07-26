import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viet_braille_app/teaching/quiz_screen.dart';

void main() {
  group('QuizScreen', () {
    testWidgets('hiển thị app bar và điểm khởi tạo', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: QuizScreen()));

      expect(find.text('Quiz Braille'), findsOneWidget);
      expect(find.text('Điểm: 0 / 0'), findsOneWidget);
    });

    testWidgets('hiển thị câu hỏi và 4 lựa chọn đáp án', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: QuizScreen()));

      expect(find.textContaining('Chuyển đổi chữ'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsNWidgets(4));
    });

    testWidgets('trả lời làm tăng tổng số câu và hiện nút câu tiếp theo', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: QuizScreen()));

      await tester.tap(find.byType(ElevatedButton).first);
      await tester.pump();

      expect(find.textContaining('/ 1'), findsOneWidget);
      expect(find.text('Câu tiếp theo'), findsOneWidget);
    });
  });
}
