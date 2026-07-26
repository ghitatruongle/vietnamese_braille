import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:viet_braille_app/data/text_extractor.dart';

void main() {
  late TextExtractorImpl extractor;
  late Directory tempDir;

  setUp(() async {
    extractor = TextExtractorImpl();
    tempDir = await Directory.systemTemp.createTemp('braille_test_');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  // ══════════════════════════════════════════════════════════════════════
  // TXT file reading
  // ══════════════════════════════════════════════════════════════════════
  group('TXT file', () {
    test('reads UTF-8 text file correctly', () async {
      final file = File('${tempDir.path}/test.txt');
      await file.writeAsString('Xin chào Việt Nam!', encoding: utf8);
      final result = await extractor.extractText(file.path, 'text/plain');
      expect(result, equals('Xin chào Việt Nam!'));
    });

    test('reads empty text file', () async {
      final file = File('${tempDir.path}/empty.txt');
      await file.writeAsString('');
      final result = await extractor.extractText(file.path, 'text/plain');
      expect(result, equals(''));
    });

    test('reads text file with Vietnamese diacritics', () async {
      final file = File('${tempDir.path}/viet.txt');
      const text = 'Đội ngũ ưng ý ế ồ ớ ứ ự ắ ầ';
      await file.writeAsString(text, encoding: utf8);
      final result = await extractor.extractText(file.path, 'text/plain');
      expect(result, equals(text));
    });

    test('reads text file with newlines', () async {
      final file = File('${tempDir.path}/multi.txt');
      const text = 'line 1\nline 2\nline 3';
      await file.writeAsString(text, encoding: utf8);
      final result = await extractor.extractText(file.path, 'text/plain');
      expect(result, equals(text));
    });

    test('reads UTF-8 bytes when web has no local path', () async {
      final bytes = Uint8List.fromList(utf8.encode('Tiếng Việt trên web'));
      final result = await extractor.extractText(
        null,
        'text/plain',
        bytes: bytes,
      );
      expect(result, equals('Tiếng Việt trên web'));
    });

    test('throws Exception for non-existent TXT file', () async {
      expect(
        () => extractor.extractText('/nonexistent/path.txt', 'text/plain'),
        throwsA(isA<Exception>()),
      );
    });
  });

  // ══════════════════════════════════════════════════════════════════════
  // Unsupported MIME types
  // ══════════════════════════════════════════════════════════════════════
  group('unsupported MIME types', () {
    test('throws UnsupportedError for unknown MIME type', () async {
      final file = File('${tempDir.path}/test.xyz');
      await file.writeAsString('data');
      expect(
        () => extractor.extractText(file.path, 'application/octet-stream'),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('throws UnsupportedError for application/pdf', () async {
      final file = File('${tempDir.path}/test.pdf');
      await file.writeAsString('%PDF-1.4');
      expect(
        () => extractor.extractText(file.path, 'application/pdf'),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('throws UnsupportedError for HTML', () async {
      final file = File('${tempDir.path}/test.html');
      await file.writeAsString('<html></html>');
      expect(
        () => extractor.extractText(file.path, 'text/html'),
        throwsA(isA<UnsupportedError>()),
      );
    });
  });

  // ══════════════════════════════════════════════════════════════════════
  // DOCX file reading (needs real docx bytes — test may need to be skipped
  // if docx_to_text is not available in test environment)
  // ══════════════════════════════════════════════════════════════════════
  group('DOCX file', () {
    test('throws Exception for non-existent DOCX file', () async {
      expect(
        () => extractor.extractText(
          '/nonexistent/path.docx',
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('throws Exception for invalid DOCX bytes', () async {
      final file = File('${tempDir.path}/fake.docx');
      await file.writeAsBytes([0x00, 0x01, 0x02, 0x03]);
      expect(
        () => extractor.extractText(
          file.path,
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
