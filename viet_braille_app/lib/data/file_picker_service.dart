import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';

import '../core/platform_capabilities.dart';

class FilePickResult {
  const FilePickResult({
    this.path,
    this.bytes,
    required this.mimeType,
    this.name = '',
  }) : assert(path != null || bytes != null);

  final String? path;
  final Uint8List? bytes;
  final String mimeType;
  final String name;
}

/// Interface cho dịch vụ chọn file.
abstract class FilePickerServiceBase {
  Future<FilePickResult?> pickFile();
}

class FilePickerServiceImpl implements FilePickerServiceBase {
  @override
  Future<FilePickResult?> pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: PlatformCapabilities.supportsOcr
            ? ['txt', 'docx', 'jpg', 'jpeg', 'png']
            : ['txt', 'docx'],
        withData: kIsWeb,
      );

      if (result == null || result.files.isEmpty) {
        return null;
      }

      final file = result.files.first;
      final path = file.path;

      if (path == null && file.bytes == null) {
        throw Exception('Không thể đọc dữ liệu file đã chọn');
      }

      final mimeType = _getMimeType(file.extension);

      return FilePickResult(
        path: path,
        bytes: file.bytes,
        mimeType: mimeType,
        name: file.name,
      );
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Lỗi khi chọn file: $e');
    }
  }

  String _getMimeType(String? extension) {
    switch (extension?.toLowerCase()) {
      case 'txt':
        return 'text/plain';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'pdf':
        return 'application/pdf';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      default:
        return 'application/octet-stream';
    }
  }
}
