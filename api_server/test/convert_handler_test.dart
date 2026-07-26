import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:test/test.dart';
import 'package:viet_braille_api/handlers/convert_handler.dart';

Request _request(String body) => Request(
  'POST',
  Uri.parse('http://localhost/'),
  body: body,
  headers: {'Content-Type': 'application/json'},
);

Future<Map<String, dynamic>> _json(Response response) async =>
    jsonDecode(await response.readAsString()) as Map<String, dynamic>;

void main() {
  group('convertHandler', () {
    test('converts Vietnamese text', () async {
      final response = await convertHandler(
        _request(jsonEncode({'text': 'Xin chào'})),
      );
      final body = await _json(response);

      expect(response.statusCode, 200);
      expect(body['braille'], isA<String>());
      expect((body['braille'] as String), isNotEmpty);
      expect(body['warnings'], isEmpty);
      expect(response.headers['content-type'], contains('application/json'));
    });

    test('rejects malformed JSON and non-object JSON', () async {
      final malformed = await convertHandler(_request('{'));
      final array = await convertHandler(_request('[]'));

      expect(malformed.statusCode, 400);
      expect(array.statusCode, 400);
    });

    test('rejects missing, empty and non-string text', () async {
      for (final body in [
        <String, Object?>{},
        {'text': ''},
        {'text': 42},
      ]) {
        final response = await convertHandler(_request(jsonEncode(body)));
        expect(response.statusCode, 400);
      }
    });

    test('rejects oversized text', () async {
      final response = await convertHandler(
        _request(jsonEncode({'text': List.filled(100001, 'a').join()})),
      );

      expect(response.statusCode, 413);
    });
  });

  group('reverseHandler', () {
    test('reverses converted text', () async {
      final converted = await convertHandler(
        _request(jsonEncode({'text': 'việt nam'})),
      );
      final braille = (await _json(converted))['braille'] as String;
      final response = await reverseHandler(
        _request(jsonEncode({'braille': braille})),
      );

      expect(response.statusCode, 200);
      expect((await _json(response))['text'], 'việt nam');
    });

    test('rejects invalid braille field types', () async {
      for (final body in [
        <String, Object?>{},
        {'braille': ''},
        {'braille': 42},
      ]) {
        final response = await reverseHandler(_request(jsonEncode(body)));
        expect(response.statusCode, 400);
      }
    });

    test('rejects oversized Braille input', () async {
      final response = await reverseHandler(
        _request(jsonEncode({'braille': List.filled(100001, '⠁').join()})),
      );

      expect(response.statusCode, 413);
    });
  });

  group('batchHandler', () {
    test('converts a batch and preserves input order', () async {
      final response = await batchHandler(
        _request(
          jsonEncode({
            'texts': ['xin', 'chào'],
          }),
        ),
      );
      final results = (await _json(response))['results'] as List<dynamic>;

      expect(response.statusCode, 200);
      expect(results, hasLength(2));
      expect((results.first as Map<String, dynamic>)['input'], 'xin');
      expect((results.last as Map<String, dynamic>)['input'], 'chào');
    });

    test('rejects invalid collections and items', () async {
      for (final body in [
        <String, Object?>{},
        {'texts': <Object?>[]},
        {'texts': 'not-an-array'},
        {
          'texts': ['valid', 42],
        },
        {
          'texts': [''],
        },
      ]) {
        final response = await batchHandler(_request(jsonEncode(body)));
        expect(response.statusCode, 400);
      }
    });

    test('rejects oversized batch and oversized item', () async {
      final tooMany = await batchHandler(
        _request(jsonEncode({'texts': List.filled(101, 'a')})),
      );
      final tooLong = await batchHandler(
        _request(
          jsonEncode({
            'texts': [List.filled(100001, 'a').join()],
          }),
        ),
      );

      expect(tooMany.statusCode, 413);
      expect(tooLong.statusCode, 413);
    });
  });
}
