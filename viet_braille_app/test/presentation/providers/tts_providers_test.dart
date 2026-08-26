import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:viet_braille_app/data/tts_service.dart';
import 'package:viet_braille_app/presentation/providers/tts_providers.dart';
import 'package:viet_braille_app/presentation/screens/braille_to_text_screen.dart';

/// Ghi lại mọi lời gọi speak để kiểm chứng.
class _RecordingTts implements TtsServiceBase {
  final spoken = <String>[];
  double? rate;
  double? pitch;

  @override
  Future<bool> speak(String text) async {
    spoken.add(text);
    return true;
  }

  @override
  Future<void> setRate(double value) async => rate = value;

  @override
  Future<void> setPitch(double value) async => pitch = value;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('TTS tích hợp BrailleToTextScreen', () {
    testWidgets('nút đọc to gọi service với kết quả chuyển ngược', (
      tester,
    ) async {
      final tts = _RecordingTts();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ttsSupportedProvider.overrideWithValue(true),
            ttsServiceProvider.overrideWithValue(tts),
          ],
          child: const MaterialApp(home: BrailleToTextScreen()),
        ),
      );

      await tester.enterText(find.byType(TextField).first, '⠁⠎');
      await tester.tap(find.text('Chuyển đổi'));
      await tester.pumpAndSettle();

      // Kết quả "as" hiển thị → nút loa xuất hiện.
      expect(find.text('as'), findsOneWidget);
      final speakButton = find.byTooltip('Đọc to');
      expect(speakButton, findsOneWidget);

      await tester.ensureVisible(speakButton);
      await tester.tap(speakButton);
      await tester.pumpAndSettle();

      expect(tts.spoken, ['as']);
    });

    testWidgets('nút đọc to ẩn khi nền tảng không hỗ trợ', (tester) async {
      final tts = _RecordingTts();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ttsSupportedProvider.overrideWithValue(false),
            ttsServiceProvider.overrideWithValue(tts),
          ],
          child: const MaterialApp(home: BrailleToTextScreen()),
        ),
      );

      await tester.enterText(find.byType(TextField).first, '⠁⠎');
      await tester.tap(find.text('Chuyển đổi'));
      await tester.pumpAndSettle();

      expect(find.text('as'), findsOneWidget);
      expect(find.byTooltip('Đọc to'), findsNothing);
      expect(tts.spoken, isEmpty);
    });
  });

  group('UnsupportedTtsService', () {
    test('luôn im lặng', () async {
      final tts = UnsupportedTtsService();
      expect(await tts.speak('xin chào'), isFalse);
      await tts.setRate(0.9);
      await tts.setPitch(1.5);
    });
  });

  group('TtsRateNotifier / TtsPitchNotifier', () {
    test('setRate kẹp trong [0, 1]', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(ttsRateProvider.notifier); // khởi động _load
      await Future<void>.delayed(Duration.zero); // chờ load xong

      await container.read(ttsRateProvider.notifier).setRate(2.0);
      expect(container.read(ttsRateProvider), 1.0);
      await container.read(ttsRateProvider.notifier).setRate(-1);
      expect(container.read(ttsRateProvider), 0.0);
    });

    test('setPitch kẹp trong [0.5, 2.0]', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(ttsPitchProvider.notifier);
      await Future<void>.delayed(Duration.zero);

      await container.read(ttsPitchProvider.notifier).setPitch(5);
      expect(container.read(ttsPitchProvider), 2.0);
      await container.read(ttsPitchProvider.notifier).setPitch(0.1);
      expect(container.read(ttsPitchProvider), 0.5);
    });
  });
}
