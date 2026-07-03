import 'package:flutter_test/flutter_test.dart';
import 'package:viet_braille_app/data/file_exporter.dart';

void main() {
  group('FileExporterImpl', () {
    late FileExporterImpl exporter;

    setUp(() {
      exporter = FileExporterImpl();
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
  });
}
