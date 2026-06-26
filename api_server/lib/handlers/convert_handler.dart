import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:viet_braille_core/viet_braille_core.dart';

final _mapping = BrailleMappingImpl();
final _converter = BrailleConverterImpl(_mapping);
final _reverseConverter = BrailleReverseConverterImpl(_mapping);

Future<Response> convertHandler(Request request) async {
  try {
    final body = await request.readAsString();
    final dynamic json;
    try {
      json = jsonDecode(body);
    } on FormatException {
      return Response.badRequest(
        body: jsonEncode({'error': 'Invalid JSON body'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
    final text = json['text'] as String?;

    if (text == null || text.isEmpty) {
      return Response.badRequest(
        body: jsonEncode({'error': 'Missing "text" field'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    final result = _converter.convertWithDetails(text);
    return Response.ok(
      jsonEncode({
        'braille': result.brailleText,
        'warnings': result.unmappedCharacters,
      }),
      headers: {'Content-Type': 'application/json'},
    );
  } catch (e) {
    return Response.internalServerError(
      body: jsonEncode({'error': e.toString()}),
      headers: {'Content-Type': 'application/json'},
    );
  }
}

Future<Response> reverseHandler(Request request) async {
  try {
    final body = await request.readAsString();
    final dynamic json;
    try {
      json = jsonDecode(body);
    } on FormatException {
      return Response.badRequest(
        body: jsonEncode({'error': 'Invalid JSON body'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
    final braille = json['braille'] as String?;

    if (braille == null || braille.isEmpty) {
      return Response.badRequest(
        body: jsonEncode({'error': 'Missing "braille" field'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    final text = _reverseConverter.convert(braille);
    return Response.ok(
      jsonEncode({'text': text}),
      headers: {'Content-Type': 'application/json'},
    );
  } catch (e) {
    return Response.internalServerError(
      body: jsonEncode({'error': e.toString()}),
      headers: {'Content-Type': 'application/json'},
    );
  }
}

Future<Response> batchHandler(Request request) async {
  try {
    final body = await request.readAsString();
    final dynamic json;
    try {
      json = jsonDecode(body);
    } on FormatException {
      return Response.badRequest(
        body: jsonEncode({'error': 'Invalid JSON body'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
    final texts = (json['texts'] as List?)?.cast<String>();

    if (texts == null || texts.isEmpty) {
      return Response.badRequest(
        body: jsonEncode({'error': 'Missing "texts" field'}),
        headers: {'Content-Type': 'application/json'},
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

    return Response.ok(
      jsonEncode({'results': results}),
      headers: {'Content-Type': 'application/json'},
    );
  } catch (e) {
    return Response.internalServerError(
      body: jsonEncode({'error': e.toString()}),
      headers: {'Content-Type': 'application/json'},
    );
  }
}
