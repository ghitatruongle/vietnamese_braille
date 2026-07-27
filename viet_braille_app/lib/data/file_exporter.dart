import 'dart:io';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:viet_braille_core/viet_braille_core.dart';

/// Interface cho dịch vụ xuất và chia sẻ file.
abstract class FileExporterBase {
  Future<String> saveTemp(String content, [String baseName = 'output']);
  Future<void> share(String filePath);
  Future<void> shareBrf(String content, [String baseName = 'output']);
  Future<void> exportPdf(String brailleText, String fileName);
}

/// Hộp thoại Save As được tách riêng để luồng Windows có thể kiểm thử.
abstract class FileSaveDialogBase {
  Future<String?> choosePath({
    required String dialogTitle,
    required String fileName,
    required String extension,
  });
}

class NativeFileSaveDialog implements FileSaveDialogBase {
  @override
  Future<String?> choosePath({
    required String dialogTitle,
    required String fileName,
    required String extension,
  }) => FilePicker.platform.saveFile(
    dialogTitle: dialogTitle,
    fileName: fileName,
    type: FileType.custom,
    allowedExtensions: [extension],
    lockParentWindow: true,
  );
}

class FileExporterImpl implements FileExporterBase {
  FileExporterImpl({FileSaveDialogBase? fileSaveDialog})
    : _fileSaveDialog = fileSaveDialog ?? NativeFileSaveDialog();

  static const _brailleFontAsset = 'assets/fonts/NotoSansSymbols2-Regular.ttf';

  final FileSaveDialogBase _fileSaveDialog;

  @override
  Future<String> saveTemp(String content, [String baseName = 'output']) async {
    try {
      _validateBrf(content);
      final dir = await getTemporaryDirectory();
      final safeBaseName = _safeBaseName(baseName);
      final filePath = '${dir.path}/$safeBaseName.brf';
      final file = File(filePath);
      await file.writeAsString(content, encoding: ascii, flush: true);
      return filePath;
    } on FormatException {
      rethrow;
    } catch (e) {
      throw Exception('Không thể lưu file tạm: $e');
    }
  }

  @override
  Future<void> shareBrf(String content, [String baseName = 'output']) async {
    _validateBrf(content);
    final safeBaseName = _safeBaseName(baseName);

    if (_isWindows) {
      final selectedPath = await _fileSaveDialog.choosePath(
        dialogTitle: 'Lưu tệp BRF',
        fileName: '$safeBaseName.brf',
        extension: 'brf',
      );
      if (selectedPath == null) return;

      final path = _ensureExtension(selectedPath, 'brf');
      await File(path).writeAsBytes(ascii.encode(content), flush: true);
      return;
    }

    if (kIsWeb) {
      await Share.shareXFiles([
        XFile.fromData(
          ascii.encode(content),
          mimeType: 'text/plain',
          name: '$safeBaseName.brf',
        ),
      ], text: 'Chia sẻ file Braille');
      return;
    }

    final path = await saveTemp(content, safeBaseName);
    await share(path);
  }

  @override
  Future<void> share(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File không tồn tại để chia sẻ: $filePath');
      }
      await Share.shareXFiles([XFile(filePath)], text: 'Chia sẻ file Braille');
    } catch (e) {
      if (e is Exception && e.toString().contains('File không tồn tại')) {
        rethrow;
      }
      throw Exception('Không thể chia sẻ file: $e');
    }
  }

  @override
  Future<void> exportPdf(String brailleText, String fileName) async {
    try {
      final pdf = pw.Document();
      final fontData = await rootBundle.load(_brailleFontAsset);
      final brailleFont = pw.Font.ttf(fontData);

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          header: (context) => pw.Header(
            level: 0,
            child: pw.Text('Vietnamese Braille Export'),
          ),
          footer: (context) => pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 10),
            child: pw.Text(
              'Trang ${context.pageNumber} / ${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 10),
            ),
          ),
          build: (context) => [
            pw.SizedBox(height: 10),
            pw.Paragraph(
              text: brailleText,
              style: pw.TextStyle(
                fontSize: 18,
                font: brailleFont,
                fontFallback: [pw.Font.helvetica()],
              ),
            ),
          ],
        ),
      );

      final bytes = await pdf.save();
      if (_isWindows) {
        final safeFileName = _safePdfFileName(fileName);
        final selectedPath = await _fileSaveDialog.choosePath(
          dialogTitle: 'Lưu tệp PDF',
          fileName: safeFileName,
          extension: 'pdf',
        );
        if (selectedPath == null) return;

        final path = _ensureExtension(selectedPath, 'pdf');
        await File(path).writeAsBytes(bytes, flush: true);
        return;
      }

      await Printing.layoutPdf(
        onLayout: (format) async => bytes,
        name: fileName,
      );
    } catch (e) {
      throw Exception('Không thể xuất PDF: $e');
    }
  }

  static void _validateBrf(String content) {
    if (!NabccBrailleAsciiCodec().isValid(content)) {
      throw const FormatException(
        'Nội dung BRF phải là North American Braille ASCII.',
      );
    }
  }

  static String _safeBaseName(String value) {
    final sanitized = value.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    return sanitized.isEmpty ? 'output' : sanitized;
  }

  static String _safePdfFileName(String value) {
    final withoutExtension = value.toLowerCase().endsWith('.pdf')
        ? value.substring(0, value.length - 4)
        : value;
    return '${_safeBaseName(withoutExtension)}.pdf';
  }

  static String _ensureExtension(String path, String extension) {
    return path.toLowerCase().endsWith('.$extension')
        ? path
        : '$path.$extension';
  }

  static bool get _isWindows =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;
}
