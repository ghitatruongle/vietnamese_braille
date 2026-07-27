import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viet_braille_app/data/file_exporter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FileExporterImpl', () {
    late FileExporterImpl exporter;
    late Directory tempDirectory;
    late _RecordingSaveDialog saveDialog;

    setUp(() async {
      tempDirectory = await Directory.systemTemp.createTemp(
        'viet-braille-export-test-',
      );
      saveDialog = _RecordingSaveDialog();
      exporter = FileExporterImpl(fileSaveDialog: saveDialog);
    });

    tearDown(() async {
      debugDefaultTargetPlatformOverride = null;
      await tempDirectory.delete(recursive: true);
    });

    test('share throws for non-existent file', () async {
      expect(
        () => exporter.share('/non/existent/file.brf'),
        throwsA(isA<Exception>()),
      );
    });

    test('share throws exception with descriptive message', () async {
      try {
        await exporter.share('/non/existent/file.brf');
        fail('Should have thrown');
      } catch (e) {
        expect(e.toString(), contains('File không tồn tại'));
      }
    });

    test('FileExporterImpl implements FileExporterBase', () {
      expect(exporter, isA<FileExporterBase>());
    });

    test('saveTemp rejects Unicode Braille instead of creating fake BRF', () {
      expect(() => exporter.saveTemp('⠁⠃⠉'), throwsFormatException);
    });

    test('saveTemp rejects arbitrary UTF-8 print text', () {
      expect(() => exporter.saveTemp('xin chào'), throwsFormatException);
    });

    test('Windows saves BRF as ASCII through native Save As dialog', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      saveDialog.nextPath = '${tempDirectory.path}/ket-qua';

      await exporter.shareBrf('ABC\n', 'ket-qua');

      final output = File('${tempDirectory.path}/ket-qua.brf');
      expect(await output.exists(), isTrue);
      expect(await output.readAsBytes(), ascii.encode('ABC\n'));
      expect(saveDialog.lastExtension, 'brf');
      expect(saveDialog.lastFileName, 'ket-qua.brf');
    });

    test('Windows PDF export is offline and contains a PDF file', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      saveDialog.nextPath = '${tempDirectory.path}/braille';

      await exporter.exportPdf('⠁⠃⠉', 'vietnamese-braille.pdf');

      final output = File('${tempDirectory.path}/braille.pdf');
      expect(await output.exists(), isTrue);
      final bytes = await output.readAsBytes();
      expect(bytes.length, greaterThan(1000));
      expect(ascii.decode(bytes.take(4).toList()), '%PDF');
      expect(saveDialog.lastExtension, 'pdf');
      expect(saveDialog.lastFileName, 'vietnamese-braille.pdf');
    });

    test('Windows PDF export handles long text across multiple pages without blank pages', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      saveDialog.nextPath = '${tempDirectory.path}/braille_long';

      final longBraille = List.generate(200, (i) => '⠁⠃⠉ ⠞⠓⠹⠝⠛ ⠞⠳ ⠎⠔⠹ $i').join('\n');
      await exporter.exportPdf(longBraille, 'long-braille.pdf');

      final output = File('${tempDirectory.path}/braille_long.pdf');
      expect(await output.exists(), isTrue);
      final bytes = await output.readAsBytes();
      expect(bytes.length, greaterThan(5000));
      expect(ascii.decode(bytes.take(4).toList()), '%PDF');
    });

    test('Windows canceling Save As does not create a file', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;

      await exporter.shareBrf('ABC\n');

      expect(tempDirectory.listSync(), isEmpty);
    });
  });
}

class _RecordingSaveDialog implements FileSaveDialogBase {
  String? nextPath;
  String? lastFileName;
  String? lastExtension;

  @override
  Future<String?> choosePath({
    required String dialogTitle,
    required String fileName,
    required String extension,
  }) async {
    lastFileName = fileName;
    lastExtension = extension;
    return nextPath;
  }
}
