import 'package:flutter_test/flutter_test.dart';
import 'package:viet_braille_app/core/error_handler.dart';

void main() {
  group('AppErrorHandler', () {
    test('UnsupportedError → readable message', () {
      final result = AppErrorHandler.handleError(
        UnsupportedError('application/json'),
      );
      expect(result, contains('Định dạng file không được hỗ trợ'));
    });

    test('FormatException → readable message', () {
      final result = AppErrorHandler.handleError(
        const FormatException('invalid encoding'),
      );
      expect(result, contains('Định dạng dữ liệu không hợp lệ'));
    });

    test('Exception with Vietnamese message preserved', () {
      final result = AppErrorHandler.handleError(
        Exception('Không thể đọc file TXT: test'),
      );
      expect(result, contains('Không thể đọc file TXT'));
    });

    test('Exception with "File không tồn tại" → friendly message', () {
      final result = AppErrorHandler.handleError(
        Exception('File không tồn tại: /path/to/file'),
      );
      expect(result, contains('File không tồn tại'));
    });

    test('unknown error type → generic message', () {
      final result = AppErrorHandler.handleError('some string error');
      expect(result, contains('Đã xảy ra lỗi không xác định'));
    });
  });
}
