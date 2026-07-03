import 'package:file_picker/file_picker.dart';

class FilePickResult {
  const FilePickResult({required this.path, required this.mimeType});

  final String path;
  final String mimeType;
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
        allowedExtensions: ['txt', 'docx', 'jpg', 'jpeg', 'png'],
      );

      if (result == null || result.files.isEmpty) {
        return null;
      }

      final file = result.files.first;
      final path = file.path;

      if (path == null) {
        throw Exception('Không thể lấy đường dẫn file');
      }

      final mimeType = _getMimeType(file.extension);

      return FilePickResult(path: path, mimeType: mimeType);
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
