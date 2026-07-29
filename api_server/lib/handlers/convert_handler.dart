import 'dart:convert';
import 'dart:typed_data';

import 'package:shelf/shelf.dart';
import 'package:viet_braille_core/viet_braille_core.dart';

final _mapping = BrailleMappingImpl();
final _converter = BrailleConverterImpl(_mapping);
final _reverseConverter = BrailleReverseConverterImpl(_mapping);

const _maxTextLength = 100000;
const _maxBatchSize = 100;
const _maxBatchTextLength = 500000;
const maxRequestBodyBytes = 1024 * 1024;
const _jsonHeaders = {'Content-Type': 'application/json; charset=utf-8'};

Future<Response> convertHandler(Request request) async {
  try {
    final json = await _readJsonObject(request);
    final text = json['text'];

    if (text is! String || text.isEmpty) {
      return _badRequest('Field "text" must be a non-empty string');
    }
    if (text.length > _maxTextLength) {
      return _payloadTooLarge(
        'Field "text" exceeds $_maxTextLength characters',
      );
    }

    final result = _converter.convertWithDetails(text);
    return _jsonResponse(200, {
      'braille': result.brailleText,
      'warnings': result.unmappedCharacters,
    });
  } on RequestBodyTooLarge catch (error) {
    return _payloadTooLarge(error.message);
  } on UnsupportedRequestMediaType catch (error) {
    return _unsupportedMediaType(error.message);
  } on FormatException catch (error) {
    return _badRequest(error.message);
  } catch (_) {
    return _internalError();
  }
}

Future<Response> reverseHandler(Request request) async {
  try {
    final json = await _readJsonObject(request);
    final braille = json['braille'];

    if (braille is! String || braille.isEmpty) {
      return _badRequest('Field "braille" must be a non-empty string');
    }
    if (braille.length > _maxTextLength) {
      return _payloadTooLarge(
        'Field "braille" exceeds $_maxTextLength characters',
      );
    }

    final text = _reverseConverter.convert(braille);
    return _jsonResponse(200, {'text': text});
  } on RequestBodyTooLarge catch (error) {
    return _payloadTooLarge(error.message);
  } on UnsupportedRequestMediaType catch (error) {
    return _unsupportedMediaType(error.message);
  } on FormatException catch (error) {
    return _badRequest(error.message);
  } catch (_) {
    return _internalError();
  }
}

Future<Response> batchHandler(Request request) async {
  try {
    final json = await _readJsonObject(request);
    final rawTexts = json['texts'];

    if (rawTexts is! List || rawTexts.isEmpty) {
      return _badRequest('Field "texts" must be a non-empty array');
    }
    if (rawTexts.length > _maxBatchSize) {
      return _payloadTooLarge('Field "texts" exceeds $_maxBatchSize items');
    }
    if (rawTexts.any((item) => item is! String || item.isEmpty)) {
      return _badRequest('Every item in "texts" must be a non-empty string');
    }
    if (rawTexts.any((item) => (item as String).length > _maxTextLength)) {
      return _payloadTooLarge(
        'A "texts" item exceeds $_maxTextLength characters',
      );
    }
    final texts = rawTexts.cast<String>();
    final totalTextLength = texts.fold<int>(
      0,
      (total, text) => total + text.length,
    );
    if (totalTextLength > _maxBatchTextLength) {
      return _payloadTooLarge(
        'Combined "texts" length exceeds $_maxBatchTextLength characters',
      );
    }

    final results = texts.map((text) {
      final result = _converter.convertWithDetails(text);
      return {
        'input': text,
        'braille': result.brailleText,
        'warnings': result.unmappedCharacters,
      };
    }).toList();

    return _jsonResponse(200, {'results': results});
  } on RequestBodyTooLarge catch (error) {
    return _payloadTooLarge(error.message);
  } on UnsupportedRequestMediaType catch (error) {
    return _unsupportedMediaType(error.message);
  } on FormatException catch (error) {
    return _badRequest(error.message);
  } catch (_) {
    return _internalError();
  }
}

Future<Map<String, dynamic>> _readJsonObject(Request request) async {
  final contentType = request.headers['content-type'];
  final mediaType = contentType?.split(';').first.trim().toLowerCase();
  if (mediaType != 'application/json') {
    throw const UnsupportedRequestMediaType(
      'Content-Type must be application/json',
    );
  }

  final declaredLength = int.tryParse(request.headers['content-length'] ?? '');
  if (declaredLength != null && declaredLength > maxRequestBodyBytes) {
    throw const RequestBodyTooLarge('Request body exceeds 1048576 bytes');
  }

  final bytes = BytesBuilder(copy: false);
  var receivedBytes = 0;
  await for (final chunk in request.read()) {
    receivedBytes += chunk.length;
    if (receivedBytes > maxRequestBodyBytes) {
      throw const RequestBodyTooLarge('Request body exceeds 1048576 bytes');
    }
    bytes.add(chunk);
  }

  final body = utf8.decode(bytes.takeBytes());
  if (body.trim().isEmpty) {
    throw const FormatException('JSON body must not be empty');
  }
  final value = jsonDecode(body);
  if (value is! Map<String, dynamic>) {
    throw const FormatException('JSON body must be an object');
  }
  return value;
}

Response _jsonResponse(int statusCode, Object body) =>
    Response(statusCode, body: jsonEncode(body), headers: _jsonHeaders);

Response _badRequest(String message) => _jsonResponse(400, {'error': message});

Response _payloadTooLarge(String message) =>
    _jsonResponse(413, {'error': message, 'code': 'payload_too_large'});

Response _unsupportedMediaType(String message) =>
    _jsonResponse(415, {'error': message, 'code': 'unsupported_media_type'});

Response _internalError() =>
    _jsonResponse(500, {'error': 'Internal server error'});

class RequestBodyTooLarge implements Exception {
  const RequestBodyTooLarge(this.message);

  final String message;
}

class UnsupportedRequestMediaType implements Exception {
  const UnsupportedRequestMediaType(this.message);

  final String message;
}
