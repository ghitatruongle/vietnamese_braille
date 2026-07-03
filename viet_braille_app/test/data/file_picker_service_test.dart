import 'package:flutter_test/flutter_test.dart';
import 'package:viet_braille_app/data/file_picker_service.dart';

void main() {
  group('FilePickResult', () {
    test('stores path and mimeType correctly', () {
      const result = FilePickResult(
        path: '/some/path/file.txt',
        mimeType: 'text/plain',
      );
      expect(result.path, equals('/some/path/file.txt'));
      expect(result.mimeType, equals('text/plain'));
    });

    test('const constructor works for identical instances', () {
      const a = FilePickResult(path: '/a.txt', mimeType: 'text/plain');
      const b = FilePickResult(path: '/a.txt', mimeType: 'text/plain');
      expect(a.path, equals(b.path));
      expect(a.mimeType, equals(b.mimeType));
    });
  });

  group('FilePickerServiceImpl', () {
    test('implements FilePickerServiceBase', () {
      final service = FilePickerServiceImpl();
      expect(service, isA<FilePickerServiceBase>());
    });
  });
}
