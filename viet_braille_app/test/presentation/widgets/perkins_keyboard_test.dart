import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:viet_braille_app/presentation/screens/braille_to_text_screen.dart';
import 'package:viet_braille_app/presentation/widgets/perkins_keyboard.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('PerkinsKeyboard unit widget tests', () {
    final cells = <String>[];
    var backspaces = 0;

    Future<void> pumpSubject(WidgetTester tester) async {
      cells.clear();
      backspaces = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PerkinsKeyboard(
              onCell: cells.add,
              onBackspace: () => backspaces++,
            ),
          ),
        ),
      );
    }

    testWidgets('S + J + Space chốt ô dots 1+4 (U+2809)', (tester) async {
      await pumpSubject(tester);

      await tester.tap(find.byKey(const ValueKey('perkins-dot-1')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('perkins-dot-4')));
      await tester.pump();
      // Bật lại S phải bỏ chọn (toggle).
      await tester.tap(find.byKey(const ValueKey('perkins-dot-1')));
      await tester.pump();
      expect(cells, isEmpty);

      await tester.tap(find.byKey(const ValueKey('perkins-dot-1')));
      await tester.pump();
      await tester.tap(find.textContaining('Chốt ô (Space)'));
      await tester.pump();

      expect(cells, ['\u2809']);
    });

    testWidgets('Space không chốt khi không có chấm nào', (tester) async {
      await pumpSubject(tester);

      await tester.tap(find.textContaining('Chốt ô (Space)'));
      await tester.pump();

      expect(cells, isEmpty);
    });

    testWidgets('⌫ gọi onBackspace', (tester) async {
      await pumpSubject(tester);

      await tester.tap(find.byTooltip('Xóa ô cuối'));
      await tester.pump();

      expect(backspaces, 1);
    });

    testWidgets('ô xem trước hiển thị đúng bitmask', (tester) async {
      await pumpSubject(tester);

      // D+F = chấm 2+3 → U+2806
      await tester.tap(find.byKey(const ValueKey('perkins-dot-2')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('perkins-dot-3')));
      await tester.pump();

      final preview = tester.widget<Text>(
        find.byKey(const ValueKey('perkins-preview')),
      );
      expect(preview.data, '\u2806');
    });
  });

  group('BrailleToTextScreen tích hợp Perkins', () {
    testWidgets('gõ S+A? bằng phím rồi chuyển đổi được', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: BrailleToTextScreen())),
      );

      // ⠁ (chấm 1) + ⠎ (chấm 2,3,4) + Space mỗi ô → "⠁⠎".
      await tester.ensureVisible(find.byKey(const ValueKey('perkins-dot-1')));
      await tester.tap(find.byKey(const ValueKey('perkins-dot-1')));
      await tester.pump();
      await tester.ensureVisible(find.textContaining('Chốt ô (Space)'));
      await tester.tap(find.textContaining('Chốt ô (Space)'));
      await tester.pump();
      await tester.ensureVisible(find.byKey(const ValueKey('perkins-dot-2')));
      await tester.tap(find.byKey(const ValueKey('perkins-dot-2')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('perkins-dot-3')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('perkins-dot-4')));
      await tester.pump();
      await tester.ensureVisible(find.textContaining('Chốt ô (Space)'));
      await tester.tap(find.textContaining('Chốt ô (Space)'));
      await tester.pump();

      final field = tester.widget<TextField>(find.byType(TextField).first);
      expect(field.controller!.text, '⠁⠎');

      // Đặt con trỏ về giữa chuỗi rồi chèn ô mới tại vị trí đó.
      field.controller!.selection = const TextSelection.collapsed(offset: 1);
      await tester.tap(find.byKey(const ValueKey('perkins-dot-1')));
      await tester.pump();
      await tester.ensureVisible(find.textContaining('Chốt ô (Space)'));
      await tester.tap(find.textContaining('Chốt ô (Space)'));
      await tester.pump();

      final fieldAfter = tester.widget<TextField>(find.byType(TextField).first);
      expect(fieldAfter.controller!.text, '⠁⠁⠎');

      // ⠁⠎ dịch ngược ra "as"; sau khi chèn thêm ô 'a' kết quả là "aas".
      await tester.ensureVisible(find.text('Chuyển đổi'));
      await tester.tap(find.text('Chuyển đổi'));
      await tester.pumpAndSettle();

      expect(find.text('aas'), findsOneWidget);
    });
  });
}
