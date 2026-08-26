import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:viet_braille_app/data/file_picker_service.dart';
import 'package:viet_braille_app/data/text_extractor.dart';
import 'package:viet_braille_app/presentation/providers/batch_conversion_providers.dart';
import 'package:viet_braille_core/viet_braille_core.dart';

/// Bộ chọn giả trả về danh sách cấu hình sẵn.
class _FakeMultiPicker implements FilePickerServiceBase {
  _FakeMultiPicker(this.results);
  final List<FilePickResult> results;

  @override
  Future<FilePickResult?> pickFile() async => null;

  @override
  Future<List<FilePickResult>> pickMultipleFiles() async => results;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('batch_test');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  FilePickResult txt(String name) =>
      FilePickResult(path: 'C:/fake/$name', mimeType: 'text/plain', name: name);

  BatchConversionNotifier buildNotifier({
    required List<FilePickResult> picks,
    required Map<String, String?> contentByName,
    bool Function()? markdownEnabled,
  }) {
    return BatchConversionNotifier(
      filePickerService: _FakeMultiPicker(picks),
      textExtractor: _PathKeyedExtractor(contentByName),
      brailleConverter: BrailleConverterImpl(BrailleMappingImpl()),
      brfFormatter: BrfFormatterImpl(),
      getMarkdownEnabled: markdownEnabled,
    );
  }

  group('BatchConversionNotifier', () {
    test('pickFiles bỏ qua lựa chọn rỗng', () async {
      final notifier = buildNotifier(picks: const [], contentByName: {});
      await notifier.pickFiles();
      expect(notifier.state.items, isEmpty);
      expect(notifier.state.isConverting, isFalse);
    });

    test('pickFiles tạo danh sách item ở trạng thái pending', () async {
      final notifier = buildNotifier(
        picks: [txt('a.txt'), txt('b.docx')],
        contentByName: {},
      );
      await notifier.pickFiles();
      expect(notifier.state.items.length, 2);
      expect(
        notifier.state.items.every((i) => i.status == BatchFileStatus.pending),
        isTrue,
      );
    });

    test('convertAll xử lý hỗn hợp: thành công, rỗng, ảnh, lỗi đọc', () async {
      final notifier = buildNotifier(
        picks: [
          txt('ok.txt'),
          txt('empty.txt'),
          const FilePickResult(
            path: 'C:/fake/img.png',
            mimeType: 'image/png',
            name: 'img.png',
          ),
          txt('broken.txt'),
        ],
        contentByName: {
          'ok.txt': 'Xin chào Việt Nam',
          'empty.txt': '   ',
          'broken.txt': null,
        },
      );
      await notifier.pickFiles();
      await notifier.convertAll();

      expect(notifier.state.isConverting, isFalse);
      final items = notifier.state.items;
      expect(items, hasLength(4));

      expect(items[0].status, BatchFileStatus.success);
      expect(items[0].brailleUnicode, isNotEmpty);
      expect(items[0].brfContent, isNotEmpty);

      expect(items[1].status, BatchFileStatus.error);
      expect(items[1].errorMessage, 'File rỗng.');

      expect(items[2].status, BatchFileStatus.error);
      expect(items[2].errorMessage, 'OCR chưa hỗ trợ trong chuyển đổi batch.');

      expect(items[3].status, BatchFileStatus.error);
      expect(items[3].errorMessage, contains('Không đọc được tệp'));
    });

    test('cờ markdown được truyền tới lõi khi bật', () async {
      final boldMarker = BrailleMappingImpl().boldMarker;
      final enabled = buildNotifier(
        picks: [txt('md.txt')],
        contentByName: {'md.txt': '**đậm**'},
        markdownEnabled: () => true,
      );
      await enabled.pickFiles();
      await enabled.convertAll();
      expect(
        enabled.state.items.first.brailleUnicode.contains(boldMarker),
        isTrue,
      );

      final disabled = buildNotifier(
        picks: [txt('md.txt')],
        contentByName: {'md.txt': '**đậm**'},
      );
      await disabled.pickFiles();
      await disabled.convertAll();
      expect(
        disabled.state.items.first.brailleUnicode.contains(boldMarker),
        isFalse,
      );
    });

    test('convertAll không chạy khi chưa chọn file', () async {
      final notifier = buildNotifier(picks: const [], contentByName: {});
      await notifier.convertAll();
      expect(notifier.state.isConverting, isFalse);
      expect(notifier.state.items, isEmpty);
    });

    test('clear xóa sạch trạng thái', () async {
      final notifier = buildNotifier(
        picks: [txt('a.txt')],
        contentByName: {'a.txt': 'nội dung'},
      );
      await notifier.pickFiles();
      await notifier.convertAll();
      expect(notifier.state.items.first.status, BatchFileStatus.success);

      notifier.clear();
      expect(notifier.state.items, isEmpty);
      expect(notifier.state.isConverting, isFalse);
    });

    test('exportBrfFiles chỉ ghi các file thành công', () async {
      final notifier = buildNotifier(
        picks: [txt('ok.txt'), txt('empty.txt')],
        contentByName: {'ok.txt': 'Nội dung xuất', 'empty.txt': '   '},
      );
      await notifier.pickFiles();
      await notifier.convertAll();

      final written = await notifier.exportBrfFiles(tempDir.path);
      expect(written, 1);

      final entries = tempDir.listSync();
      expect(entries, hasLength(1));
      final outFile = entries.single as File;
      expect(fileSystemEntityName(outFile.path), 'ok.brf');
      expect(outFile.readAsStringSync(), notifier.state.items.first.brfContent);
    });
  });
}

String fileSystemEntityName(String p) => p.split(Platform.pathSeparator).last;

class _PathKeyedExtractor implements TextExtractor {
  _PathKeyedExtractor(this._contentByName);
  final Map<String, String?> _contentByName;

  @override
  Future<String> extractText(
    String? path,
    String mimeType, {
    Uint8List? bytes,
  }) async {
    final name = (path ?? '').split('/').last.split('\\').last;
    if (!_contentByName.containsKey(name)) {
      throw FileSystemException('Không đọc được tệp', name);
    }
    final content = _contentByName[name];
    if (content == null) {
      throw FileSystemException('Không đọc được tệp', name);
    }
    return content;
  }
}
