import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:viet_braille_app/data/file_picker_service.dart';
import 'package:viet_braille_app/data/file_exporter.dart';
import 'package:viet_braille_app/data/history_service.dart';
import 'package:viet_braille_app/data/ocr_processor.dart';
import 'package:viet_braille_app/data/text_extractor.dart';
import 'package:viet_braille_app/presentation/providers/conversion_notifier.dart';
import 'package:viet_braille_app/presentation/providers/conversion_state.dart';
import 'package:viet_braille_app/presentation/widgets/drop_zone.dart';
import 'package:viet_braille_core/viet_braille_core.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('DropHintOverlay', () {
    testWidgets('hiển thị gợi ý khi visible = true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [SizedBox.expand(), DropHintOverlay(visible: true)],
            ),
          ),
        ),
      );

      expect(find.textContaining('Thả tệp'), findsOneWidget);
    });

    testWidgets('ẩn hoàn toàn khi visible = false', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [SizedBox.expand(), DropHintOverlay(visible: false)],
            ),
          ),
        ),
      );

      expect(find.textContaining('Thả tệp'), findsNothing);
    });
  });

  group('DropZone', () {
    testWidgets('render con và không chặn tương tác khi không kéo', (
      tester,
    ) async {
      var dropped = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DropZone(
              onFileDropped: (_) => dropped++,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Nội dung chính'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Nội dung chính'), findsOneWidget);
      expect(find.textContaining('Thả tệp'), findsNothing);
      expect(dropped, 0);
    });
  });

  group('ConversionNotifier.convertDroppedFile — định tuyến', () {
    test('tệp TXT đi vào bộ đọc văn bản và chuyển đổi thành công', () async {
      final notifier = ConversionNotifier(
        filePickerService: _NoopPicker(),
        textExtractor: _FakeExtractor({
          'C:/drop/hoaso.txt': 'Nội dung kéo thả',
        }),
        ocrProcessor: _NoOcr(),
        brailleConverter: BrailleConverterImpl(BrailleMappingImpl()),
        reverseConverter: BrailleReverseConverterImpl(BrailleMappingImpl()),
        brfFormatter: BrfFormatterImpl(),
        fileExporter: _NoExporter(),
        historyService: _NoHistory(),
      );

      await notifier.convertDroppedFile('C:/drop/hoaso.txt');

      expect(notifier.state.status, AppStatus.success);
      expect(notifier.state.originalText, 'Nội dung kéo thả');
      expect(notifier.state.brailleUnicode, isNotEmpty);
    });

    test('tệp TXT rỗng → trạng thái lỗi với thông điệp rõ ràng', () async {
      final notifier = ConversionNotifier(
        filePickerService: _NoopPicker(),
        textExtractor: _FakeExtractor({'C:/drop/trong.txt': '   '}),
        ocrProcessor: _NoOcr(),
        brailleConverter: BrailleConverterImpl(BrailleMappingImpl()),
        reverseConverter: BrailleReverseConverterImpl(BrailleMappingImpl()),
        brfFormatter: BrfFormatterImpl(),
        fileExporter: _NoExporter(),
        historyService: _NoHistory(),
      );

      await notifier.convertDroppedFile('C:/drop/trong.txt');

      expect(notifier.state.status, AppStatus.error);
      expect(notifier.state.errorMessage, contains('không chứa văn bản'));
    });
  });
}

// ── Fakes tối giản cho notifier ──

class _NoopPicker implements FilePickerServiceBase {
  @override
  Future<FilePickResult?> pickFile() async => null;

  @override
  Future<List<FilePickResult>> pickMultipleFiles() async => [];
}

class _FakeExtractor implements TextExtractor {
  _FakeExtractor(this._contentByPath);
  final Map<String, String> _contentByPath;

  @override
  Future<String> extractText(
    String? path,
    String mimeType, {
    Uint8List? bytes,
  }) async => _contentByPath[path ?? ''] ?? '';
}

class _NoOcr implements OcrProcessor {
  @override
  Future<String> recognizeImage(String path) async =>
      throw UnsupportedError('OCR không được dùng trong test này');

  @override
  void dispose() {}
}

class _NoExporter implements FileExporterBase {
  @override
  Future<String> saveTemp(String content, [String baseName = 'output']) =>
      throw UnimplementedError();

  @override
  Future<void> share(String filePath) => throw UnimplementedError();

  @override
  Future<void> shareBrf(String content, [String baseName = 'output']) =>
      throw UnimplementedError();

  @override
  Future<void> exportPdf(String brailleText, String fileName) =>
      throw UnimplementedError();
}

class _NoHistory implements HistoryServiceBase {
  final List<ConversionHistoryEntry> entries = [];

  @override
  Future<List<ConversionHistoryEntry>> loadHistory() async => List.of(entries);

  @override
  Future<void> saveEntry(ConversionHistoryEntry entry) async {}

  @override
  Future<void> clearHistory() async {}

  @override
  Future<void> deleteEntry(int index) async {}

  @override
  Future<List<ConversionHistoryEntry>> searchHistory(String query) async => [];

  @override
  Future<int> replaceAll(List<ConversionHistoryEntry> newEntries) async =>
      newEntries.length;

  @override
  Future<int> mergeEntries(List<ConversionHistoryEntry> newEntries) async =>
      newEntries.length;
}
