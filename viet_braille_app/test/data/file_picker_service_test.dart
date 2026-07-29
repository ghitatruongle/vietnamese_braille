import 'package:flutter_test/flutter_test.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
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

    test('supports in-memory bytes when web path is null', () {
      final bytes = Uint8List.fromList([1, 2, 3]);
      final result = FilePickResult(
        bytes: bytes,
        mimeType: 'text/plain',
        name: 'test.txt',
      );
      expect(result.path, isNull);
      expect(result.bytes, same(bytes));
      expect(result.name, 'test.txt');
    });
  });

  group('FilePickerServiceImpl', () {
    test('implements FilePickerServiceBase', () {
      final service = FilePickerServiceImpl();
      expect(service, isA<FilePickerServiceBase>());
    });

    test('returns null for a cancelled or empty selection', () async {
      final cancelled = FilePickerServiceImpl(
        pickFiles:
            ({
              required allowMultiple,
              required type,
              required allowedExtensions,
              required withData,
            }) async => null,
      );
      final empty = FilePickerServiceImpl(
        pickFiles:
            ({
              required allowMultiple,
              required type,
              required allowedExtensions,
              required withData,
            }) async => const FilePickerResult([]),
      );

      expect(await cancelled.pickFile(), isNull);
      expect(await empty.pickFile(), isNull);
    });

    test('maps every supported extension to its MIME type', () async {
      const cases = {
        'txt': 'text/plain',
        'docx':
            'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        'pdf': 'application/pdf',
        'jpg': 'image/jpeg',
        'jpeg': 'image/jpeg',
        'png': 'image/png',
        'bin': 'application/octet-stream',
      };

      for (final entry in cases.entries) {
        final service = FilePickerServiceImpl(
          pickFiles:
              ({
                required allowMultiple,
                required type,
                required allowedExtensions,
                required withData,
              }) async => FilePickerResult([
                PlatformFile(
                  name: 'sample.${entry.key}',
                  path: '/sample.${entry.key}',
                  size: 1,
                ),
              ]),
        );

        final result = await service.pickFile();
        expect(result?.mimeType, entry.value, reason: entry.key);
        expect(result?.name, 'sample.${entry.key}');
      }
    });

    test('keeps in-memory bytes when a platform path is unavailable', () async {
      final bytes = Uint8List.fromList([1, 2, 3]);
      final service = FilePickerServiceImpl(
        pickFiles:
            ({
              required allowMultiple,
              required type,
              required allowedExtensions,
              required withData,
            }) async => FilePickerResult([
              PlatformFile(name: 'web.txt', bytes: bytes, size: bytes.length),
            ]),
      );

      final result = await service.pickFile();

      expect(result?.path, isNull);
      expect(result?.bytes, same(bytes));
    });

    test('rejects a platform result without path or bytes', () async {
      final service = FilePickerServiceImpl(
        pickFiles:
            ({
              required allowMultiple,
              required type,
              required allowedExtensions,
              required withData,
            }) async =>
                FilePickerResult([PlatformFile(name: 'missing.txt', size: 0)]),
      );

      expect(service.pickFile, throwsException);
    });

    test('uses platform capability to constrain picker extensions', () async {
      List<String>? captured;
      final service = FilePickerServiceImpl(
        pickFiles:
            ({
              required allowMultiple,
              required type,
              required allowedExtensions,
              required withData,
            }) async {
              captured = allowedExtensions;
              expect(allowMultiple, isFalse);
              expect(type, FileType.custom);
              expect(withData, kIsWeb);
              return null;
            },
      );

      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      await service.pickFile();
      expect(captured, ['txt', 'docx']);

      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      await service.pickFile();
      expect(captured, ['txt', 'docx', 'jpg', 'jpeg', 'png']);
      debugDefaultTargetPlatformOverride = null;
    });

    test('preserves Exceptions and wraps non-Exception failures', () async {
      final direct = FilePickerServiceImpl(
        pickFiles:
            ({
              required allowMultiple,
              required type,
              required allowedExtensions,
              required withData,
            }) => throw Exception('direct'),
      );
      final wrapped = FilePickerServiceImpl(
        pickFiles:
            ({
              required allowMultiple,
              required type,
              required allowedExtensions,
              required withData,
            }) => throw 'plugin failure',
      );

      expect(
        direct.pickFile,
        throwsA(predicate((e) => '$e'.contains('direct'))),
      );
      expect(
        wrapped.pickFile,
        throwsA(predicate((e) => '$e'.contains('Lỗi khi chọn file'))),
      );
    });
  });
}
