import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:viet_braille_app/presentation/screens/braille_to_text_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('BrailleToTextScreen widget tests', () {
    testWidgets('renders app bar title', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: BrailleToTextScreen())),
      );

      expect(find.text('Braille → Văn bản'), findsOneWidget);
    });

    testWidgets('renders input field, convert, paste and clear buttons', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: BrailleToTextScreen())),
      );

      expect(find.text('Ô Braille Unicode'), findsOneWidget);
      expect(find.text('Chuyển đổi'), findsOneWidget);
      expect(find.text('Dán'), findsOneWidget);
      expect(find.text('Xóa'), findsOneWidget);
    });

    testWidgets('converts braille input to Vietnamese text', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: BrailleToTextScreen())),
      );

      // "sai banh" in Braille
      await tester.enterText(find.byType(TextField).first, '⠎⠁⠊ ⠃⠁⠝⠓');
      await tester.tap(find.text('Chuyển đổi'));
      await tester.pumpAndSettle();

      expect(find.text('sai banh'), findsOneWidget);
    });

    testWidgets('shows warning for empty input', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: BrailleToTextScreen())),
      );

      await tester.tap(find.text('Chuyển đổi'));
      await tester.pumpAndSettle();

      expect(
        find.text('Vui lòng nhập hoặc dán văn bản Braille.'),
        findsOneWidget,
      );
    });

    testWidgets('clear button resets input and result', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: BrailleToTextScreen())),
      );

      await tester.enterText(find.byType(TextField).first, '⠁');
      await tester.tap(find.text('Chuyển đổi'));
      await tester.pumpAndSettle();
      expect(find.text('a'), findsOneWidget);

      await tester.tap(find.text('Xóa'));
      await tester.pumpAndSettle();

      final inputField = tester.widget<TextField>(find.byType(TextField).first);
      expect(inputField.controller!.text, isEmpty);
      expect(find.text('a'), findsNothing);
    });

    testWidgets('copy result button appears after conversion', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: BrailleToTextScreen())),
      );

      await tester.enterText(find.byType(TextField).first, '⠁');
      await tester.tap(find.text('Chuyển đổi'));
      await tester.pumpAndSettle();

      expect(find.text('Sao chép kết quả'), findsOneWidget);
    });
  });
}
