import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:viet_braille_app/data/file_exporter.dart';
import 'package:viet_braille_app/data/file_picker_service.dart';
import 'package:viet_braille_app/data/history_service.dart';
import 'package:viet_braille_app/data/ocr_processor.dart';
import 'package:viet_braille_app/data/text_extractor.dart';
import 'package:viet_braille_app/presentation/providers/conversion_provider.dart';
import 'package:viet_braille_core/viet_braille_core.dart';

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
    late int feedbackCalls;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      feedbackCalls = 0;
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
        onConversionSuccess: () async {
          feedbackCalls++;
        },
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

    test('convertText with valid input → success state', () async {
      await notifier.convertText('xin chào');
      expect(notifier.state.status, equals(AppStatus.success));
      expect(notifier.state.originalText, equals('xin chào'));
      expect(notifier.state.brailleUnicode, isNotEmpty);
      expect(notifier.state.brfContent, isNotEmpty);
      expect(notifier.state.errorMessage, isNull);
      expect(feedbackCalls, 1);
    });

    test('convertText output ends with newline (BRF format)', () async {
      await notifier.convertText('hello');
      expect(notifier.state.brfContent.endsWith('\n'), isTrue);
    });

    test('convertText with empty input → stays idle', () async {
      await notifier.convertText('');
      expect(notifier.state.status, equals(AppStatus.idle));
      expect(notifier.state.originalText, equals(''));
      expect(feedbackCalls, 0);
    });

    test('convertText with whitespace-only input → stays idle', () async {
      await notifier.convertText('   ');
      expect(notifier.state.status, equals(AppStatus.idle));
    });

    test('convertText with numbers → success', () async {
      await notifier.convertText('123');
      expect(notifier.state.status, equals(AppStatus.success));
      expect(notifier.state.brailleUnicode, isNotEmpty);
    });

    test('convertText with Vietnamese diacritics → success', () async {
      await notifier.convertText('đội ngũ ưng ý');
      expect(notifier.state.status, equals(AppStatus.success));
      expect(notifier.state.brailleUnicode, isNotEmpty);
    });

    test('convertText clears previous error message', () async {
      // First, set an error state
      await notifier.convertText('');
      // Now convert valid text
      await notifier.convertText('hello');
      expect(notifier.state.status, equals(AppStatus.success));
      expect(notifier.state.errorMessage, isNull);
    });

    test('multiple convertText calls update state correctly', () async {
      await notifier.convertText('first');
      final firstResult = notifier.state.brailleUnicode;

      await notifier.convertText('second');
      final secondResult = notifier.state.brailleUnicode;

      expect(firstResult, isNot(equals(secondResult)));
      expect(notifier.state.originalText, equals('second'));
      expect(notifier.state.status, equals(AppStatus.success));
    });

    test('history failure keeps result and exposes a warning', () async {
      final mapping = BrailleMappingImpl();
      final failingNotifier = ConversionNotifier(
        filePickerService: FilePickerServiceImpl(),
        textExtractor: TextExtractorImpl(),
        ocrProcessor: OcrProcessorImpl(mapping),
        brailleConverter: BrailleConverterImpl(mapping),
        reverseConverter: BrailleReverseConverterImpl(mapping),
        brfFormatter: BrfFormatterImpl(),
        fileExporter: FileExporterImpl(),
        historyService: _FailingHistoryService(),
      );
      addTearDown(failingNotifier.dispose);

      await failingNotifier.convertText('xin chào');

      expect(failingNotifier.state.status, AppStatus.success);
      expect(failingNotifier.state.brailleUnicode, isNotEmpty);
      expect(failingNotifier.state.warningMessage, contains('lưu vào lịch sử'));
    });

    test('feedback failure does not turn conversion into an error', () async {
      final mapping = BrailleMappingImpl();
      final feedbackFailingNotifier = ConversionNotifier(
        filePickerService: FilePickerServiceImpl(),
        textExtractor: TextExtractorImpl(),
        ocrProcessor: OcrProcessorImpl(mapping),
        brailleConverter: BrailleConverterImpl(mapping),
        reverseConverter: BrailleReverseConverterImpl(mapping),
        brfFormatter: BrfFormatterImpl(),
        fileExporter: FileExporterImpl(),
        historyService: HistoryServiceImpl(),
        onConversionSuccess: () => throw UnsupportedError('no haptics'),
      );
      addTearDown(feedbackFailingNotifier.dispose);

      await feedbackFailingNotifier.convertText('xin chào');

      expect(feedbackFailingNotifier.state.status, AppStatus.success);
      expect(feedbackFailingNotifier.state.errorMessage, isNull);
    });
  });

  // ══════════════════════════════════════════════════════════════════════
  // ConversionNotifier — exportBrf()
  // ══════════════════════════════════════════════════════════════════════
  group('ConversionNotifier — exportBrf()', () {
    late ConversionNotifier notifier;
    late _RecordingFileExporter fileExporter;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final mapping = BrailleMappingImpl();
      fileExporter = _RecordingFileExporter();
      notifier = ConversionNotifier(
        filePickerService: FilePickerServiceImpl(),
        textExtractor: TextExtractorImpl(),
        ocrProcessor: OcrProcessorImpl(BrailleMappingImpl()),
        brailleConverter: BrailleConverterImpl(mapping),
        reverseConverter: BrailleReverseConverterImpl(mapping),
        brfFormatter: BrfFormatterImpl(),
        fileExporter: fileExporter,
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

    test('exportBrf after conversion → exports once', () async {
      await notifier.convertText('hello');
      await notifier.exportBrf();

      expect(fileExporter.brfExports, 1);
      expect(notifier.state.status, equals(AppStatus.success));
    });

    test('exportPdf without conversion → error state', () async {
      await notifier.exportPdf();

      expect(notifier.state.status, equals(AppStatus.error));
      expect(notifier.state.errorMessage, contains('xuất PDF'));
      expect(fileExporter.pdfExports, 0);
    });

    test('exportPdf after conversion → exports Unicode Braille once', () async {
      await notifier.convertText('hello');
      await notifier.exportPdf();

      expect(fileExporter.pdfExports, 1);
      expect(fileExporter.lastPdfContent, notifier.state.brailleUnicode);
      expect(notifier.state.status, equals(AppStatus.success));
    });
  });
}

class _RecordingFileExporter implements FileExporterBase {
  int brfExports = 0;
  int pdfExports = 0;
  String? lastPdfContent;

  @override
  Future<void> exportPdf(String brailleText, String fileName) async {
    pdfExports++;
    lastPdfContent = brailleText;
  }

  @override
  Future<String> saveTemp(String content, [String baseName = 'output']) async =>
      '$baseName.brf';

  @override
  Future<void> share(String filePath) async {}

  @override
  Future<void> shareBrf(String content, [String baseName = 'output']) async {
    brfExports++;
  }
}

class _FailingHistoryService implements HistoryServiceBase {
  @override
  Future<void> saveEntry(ConversionHistoryEntry entry) {
    throw Exception('storage unavailable');
  }

  @override
  Future<void> clearHistory() async {}

  @override
  Future<void> deleteEntry(int index) async {}

  @override
  Future<List<ConversionHistoryEntry>> loadHistory() async => [];

  @override
  Future<List<ConversionHistoryEntry>> searchHistory(String query) async => [];
}
