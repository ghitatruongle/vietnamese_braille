import 'dart:io';
import 'dart:convert';

import 'package:docx_to_text/docx_to_text.dart';

abstract class TextExtractor {
  Future<String> extractText(String path, String mimeType);
}

class TextExtractorImpl implements TextExtractor {
  @override
  Future<String> extractText(String path, String mimeType) async {
    try {
      switch (mimeType) {
        case 'text/plain':
          return await _extractFromTxt(path);
        case 'application/vnd.openxmlformats-officedocument.wordprocessingml.document':
          return await _extractFromDocx(path);
        case 'application/pdf':
          throw UnsupportedError(
            'Đọc file PDF chưa được hỗ trợ. Vui lòng sử dụng file TXT hoặc DOCX.',
          );
        default:
          throw UnsupportedError('Định dạng file không được hỗ trợ: $mimeType');
      }
    } catch (e) {
      if (e is UnsupportedError) rethrow;
      throw Exception('Không thể trích xuất văn bản: $e');
    }
  }

  Future<String> _extractFromTxt(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) {
        throw Exception('File không tồn tại: $path');
      }
      return await file.readAsString(encoding: utf8);
    } catch (e) {
      throw Exception('Không thể đọc file TXT: $e');
    }
  }

  Future<String> _extractFromDocx(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) {
        throw Exception('File không tồn tại: $path');
      }
      final bytes = await file.readAsBytes();
      return docxToText(bytes);
    } catch (e) {
      throw Exception('Không thể đọc file DOCX: $e');
    }
  }
}
