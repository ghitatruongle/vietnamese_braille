import 'dart:io';

/// Xử lý lỗi tập trung cho ứng dụng.
class AppErrorHandler {
  /// Chuyển đổi exception thành thông báo lỗi thân thiện.
  static String handleError(dynamic error) {
    if (error is UnsupportedError) {
      return 'Định dạng file không được hỗ trợ.';
    }
    if (error is FormatException) {
      return 'Định dạng dữ liệu không hợp lệ: ${error.message}';
    }
    if (error is FileSystemException) {
      return 'Không thể truy cập file: ${error.message}';
    }
    if (error is Exception) {
      final msg = error.toString();
      if (msg.contains('File không tồn tại')) {
        return 'File không tồn tại hoặc đã bị xóa.';
      }
      if (msg.contains('Không thể')) {
        // Giữ nguyên thông báo tiếng Việt đã có
        return msg.replaceFirst('Exception: ', '');
      }
      return msg.replaceFirst('Exception: ', '');
    }
    return 'Đã xảy ra lỗi không xác định: $error';
  }
}
