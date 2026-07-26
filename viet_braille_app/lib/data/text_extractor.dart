import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

import 'package:docx_to_text/docx_to_text.dart';

abstract class TextExtractor {
  Future<String> extractText(String? path, String mimeType, {Uint8List? bytes});
}

class TextExtractorImpl implements TextExtractor {
  @override
  Future<String> extractText(
    String? path,
    String mimeType, {
    Uint8List? bytes,
  }) async {
    try {
      switch (mimeType) {
        case 'text/plain':
          return await _extractFromTxt(path, bytes);
        case 'application/vnd.openxmlformats-officedocument.wordprocessingml.document':
          return await _extractFromDocx(path, bytes);
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

  Future<String> _extractFromTxt(String? path, Uint8List? bytes) async {
    try {
      if (bytes != null) {
        return utf8.decode(bytes);
      }
      if (path == null) {
        throw Exception('Không có đường dẫn hoặc dữ liệu file TXT.');
      }
      final file = File(path);
      if (!await file.exists()) {
        throw Exception('File không tồn tại: $path');
      }
      return await file.readAsString(encoding: utf8);
    } catch (e) {
      throw Exception('Không thể đọc file TXT: $e');
    }
  }

  Future<String> _extractFromDocx(String? path, Uint8List? bytes) async {
    try {
      if (bytes != null) {
        return docxToText(bytes);
      }
      if (path == null) {
        throw Exception('Không có đường dẫn hoặc dữ liệu file DOCX.');
      }
      final file = File(path);
      if (!await file.exists()) {
        throw Exception('File không tồn tại: $path');
      }
      final fileBytes = await file.readAsBytes();
      return docxToText(fileBytes);
    } catch (e) {
      throw Exception('Không thể đọc file DOCX: $e');
    }
  }
}
