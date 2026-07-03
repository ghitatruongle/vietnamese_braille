import 'dart:io';
import 'dart:convert';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

/// Interface cho dịch vụ xuất và chia sẻ file.
abstract class FileExporterBase {
  Future<String> saveTemp(String content, [String baseName = 'output']);
  Future<void> share(String filePath);
  Future<void> exportPdf(String brailleText, String fileName);
}

class FileExporterImpl implements FileExporterBase {
  @override
  Future<String> saveTemp(String content, [String baseName = 'output']) async {
    try {
      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/$baseName.brf';
      final file = File(filePath);
      await file.writeAsString(content, encoding: utf8);
      return filePath;
    } catch (e) {
      throw Exception('Không thể lưu file tạm: $e');
    }
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

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(level: 0, child: pw.Text('Vietnamese Braille Export')),
              pw.SizedBox(height: 20),
              pw.Paragraph(
                text: brailleText,
                style: pw.TextStyle(fontSize: 24, font: pw.Font.courier()),
              ),
            ],
          ),
        ),
      );

      await Printing.layoutPdf(
        onLayout: (format) => pdf.save(),
        name: fileName,
      );
    } catch (e) {
      throw Exception('Không thể xuất PDF: $e');
    }
  }
}
