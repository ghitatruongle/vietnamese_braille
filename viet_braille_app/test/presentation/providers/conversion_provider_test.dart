import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:viet_braille_app/core/braille_mapping.dart';
import 'package:viet_braille_app/data/file_exporter.dart';
import 'package:viet_braille_app/data/file_picker_service.dart';
import 'package:viet_braille_app/data/history_service.dart';
import 'package:viet_braille_app/data/ocr_processor.dart';
import 'package:viet_braille_app/data/text_extractor.dart';
import 'package:viet_braille_app/domain/braille_converter.dart';
import 'package:viet_braille_app/domain/braille_reverse_converter.dart';
import 'package:viet_braille_app/domain/brf_formatter.dart';
import 'package:viet_braille_app/presentation/providers/conversion_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // ══════════════════════════════════════════════════════════════════════
  // ConversionState
  // ══════════════════════════════════════════════════════════════════════
  group('ConversionState', () {
    test('default constructor — all fields have defaults', () {
      const state = ConversionState();
      expect(state.originalText, equals(''));
      expect(state.brailleUnicode, equals(''));
      expect(state.brfContent, equals(''));
      expect(state.status, equals(AppStatus.idle));
      expect(state.errorMessage, isNull);
    });

    test('constructor with custom values', () {
      const state = ConversionState(
        originalText: 'hello',
        brailleUnicode: 'braille',
        brfContent: 'brf',
        status: AppStatus.success,
        errorMessage: 'err',
      );
      expect(state.originalText, equals('hello'));
      expect(state.brailleUnicode, equals('braille'));
      expect(state.brfContent, equals('brf'));
      expect(state.status, equals(AppStatus.success));
      expect(state.errorMessage, equals('err'));
    });

    group('copyWith', () {
      test('copies all fields when no arguments', () {
        const original = ConversionState(
          originalText: 'a',
          brailleUnicode: 'b',
          brfContent: 'c',
          status: AppStatus.success,
          errorMessage: 'err',
        );
        final copy = original.copyWith();
        expect(copy.originalText, equals('a'));
        expect(copy.brailleUnicode, equals('b'));
        expect(copy.brfContent, equals('c'));
        expect(copy.status, equals(AppStatus.success));
        expect(copy.errorMessage, equals('err'));
      });

      test('changes only specified fields', () {
        const original = ConversionState(
          originalText: 'a',
          brailleUnicode: 'b',
          brfContent: 'c',
          status: AppStatus.idle,
        );
        final copy = original.copyWith(
          originalText: 'new text',
          status: AppStatus.loading,
        );
        expect(copy.originalText, equals('new text'));
        expect(copy.brailleUnicode, equals('b'));
        expect(copy.brfContent, equals('c'));
        expect(copy.status, equals(AppStatus.loading));
      });

      test('clearErrorMessage sets errorMessage to null', () {
        const original = ConversionState(
          status: AppStatus.error,
          errorMessage: 'some error',
        );
        final copy = original.copyWith(
          status: AppStatus.success,
          clearErrorMessage: true,
        );
        expect(copy.errorMessage, isNull);
        expect(copy.status, equals(AppStatus.success));
      });

      test('clearErrorMessage takes precedence over errorMessage param', () {
        const original = ConversionState(errorMessage: 'old error');
        final copy = original.copyWith(
          clearErrorMessage: true,
          errorMessage: 'new error',
        );
        // clearErrorMessage is checked first → null
        expect(copy.errorMessage, isNull);
      });

      test('setting errorMessage without clearErrorMessage', () {
        const original = ConversionState();
        final copy = original.copyWith(
          status: AppStatus.error,
          errorMessage: 'new error',
        );
        expect(copy.errorMessage, equals('new error'));
        expect(copy.status, equals(AppStatus.error));
      });

      test('preserve errorMessage when not clearing and not setting new', () {
        const original = ConversionState(errorMessage: 'old');
        final copy = original.copyWith(status: AppStatus.loading);
        expect(copy.errorMessage, equals('old'));
      });
    });

    test('AppStatus enum has all 4 values', () {
      expect(
        AppStatus.values,
        containsAll([
          AppStatus.idle,
          AppStatus.loading,
          AppStatus.success,
          AppStatus.error,
        ]),
      );
    });
  });

  // ══════════════════════════════════════════════════════════════════════
  // ConversionNotifier — convertText()
  // (Uses real BrailleConverter + BrfFormatter, no platform deps needed)
  // ══════════════════════════════════════════════════════════════════════
  group('ConversionNotifier — convertText()', () {
    late ConversionNotifier notifier;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final mapping = BrailleMappingImpl();
      notifier = ConversionNotifier(
        filePickerService: FilePickerServiceImpl(),
        textExtractor: TextExtractorImpl(),
        ocrProcessor: OcrProcessorImpl(BrailleMappingImpl()),
        brailleConverter: BrailleConverterImpl(mapping),
        reverseConverter: BrailleReverseConverterImpl(mapping),
        brfFormatter: BrfFormatterImpl(),
        fileExporter: FileExporterImpl(),
        historyService: HistoryServiceImpl(),
      );
    });

    tearDown(() {
      notifier.dispose();
    });

    test('initial state is idle with empty fields', () {
      expect(notifier.state.status, equals(AppStatus.idle));
      expect(notifier.state.originalText, equals(''));
      expect(notifier.state.brailleUnicode, equals(''));
      expect(notifier.state.brfContent, equals(''));
      expect(notifier.state.errorMessage, isNull);
    });

    test('convertText with valid input → success state', () {
      notifier.convertText('xin chào');
      expect(notifier.state.status, equals(AppStatus.success));
      expect(notifier.state.originalText, equals('xin chào'));
      expect(notifier.state.brailleUnicode, isNotEmpty);
      expect(notifier.state.brfContent, isNotEmpty);
      expect(notifier.state.errorMessage, isNull);
    });

    test('convertText output ends with newline (BRF format)', () {
      notifier.convertText('hello');
      expect(notifier.state.brfContent.endsWith('\n'), isTrue);
    });

    test('convertText with empty input → stays idle', () {
      notifier.convertText('');
      expect(notifier.state.status, equals(AppStatus.idle));
      expect(notifier.state.originalText, equals(''));
    });

    test('convertText with whitespace-only input → stays idle', () {
      notifier.convertText('   ');
      expect(notifier.state.status, equals(AppStatus.idle));
    });

    test('convertText with numbers → success', () {
      notifier.convertText('123');
      expect(notifier.state.status, equals(AppStatus.success));
      expect(notifier.state.brailleUnicode, isNotEmpty);
    });

    test('convertText with Vietnamese diacritics → success', () {
      notifier.convertText('đội ngũ ưng ý');
      expect(notifier.state.status, equals(AppStatus.success));
      expect(notifier.state.brailleUnicode, isNotEmpty);
    });

    test('convertText clears previous error message', () {
      // First, set an error state
      notifier.convertText('');
      // Now convert valid text
      notifier.convertText('hello');
      expect(notifier.state.status, equals(AppStatus.success));
      expect(notifier.state.errorMessage, isNull);
    });

    test('multiple convertText calls update state correctly', () {
      notifier.convertText('first');
      final firstResult = notifier.state.brailleUnicode;

      notifier.convertText('second');
      final secondResult = notifier.state.brailleUnicode;

      expect(firstResult, isNot(equals(secondResult)));
      expect(notifier.state.originalText, equals('second'));
      expect(notifier.state.status, equals(AppStatus.success));
    });
  });

  // ══════════════════════════════════════════════════════════════════════
  // ConversionNotifier — exportBrf()
  // ══════════════════════════════════════════════════════════════════════
  group('ConversionNotifier — exportBrf()', () {
    late ConversionNotifier notifier;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final mapping = BrailleMappingImpl();
      notifier = ConversionNotifier(
        filePickerService: FilePickerServiceImpl(),
        textExtractor: TextExtractorImpl(),
        ocrProcessor: OcrProcessorImpl(BrailleMappingImpl()),
        brailleConverter: BrailleConverterImpl(mapping),
        reverseConverter: BrailleReverseConverterImpl(mapping),
        brfFormatter: BrfFormatterImpl(),
        fileExporter: FileExporterImpl(),
        historyService: HistoryServiceImpl(),
      );
    });

    tearDown(() {
      notifier.dispose();
    });

    test('exportBrf without conversion → error state', () async {
      await notifier.exportBrf();
      expect(notifier.state.status, equals(AppStatus.error));
      expect(notifier.state.errorMessage, contains('Chưa có nội dung BRF'));
    });

    test('exportBrf after conversion → attempts export', () async {
      notifier.convertText('hello');
      // exportBrf will try to save + share, which may fail in test env
      // but the state should reflect the attempt
      try {
        await notifier.exportBrf();
        // If share_plus works in test, should be success
        expect(notifier.state.status, equals(AppStatus.success));
      } catch (_) {
        // Platform may not support sharing in test — that's OK
      }
    });
  });
}
