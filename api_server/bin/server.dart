import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

import 'package:viet_braille_api/handlers/convert_handler.dart';

Future<void> main() async {
  final router = Router();

  // Health check
  router.get('/health', (Request request) {
    return Response.ok(
      '{"status":"ok"}',
      headers: {'Content-Type': 'application/json; charset=utf-8'},
    );
  });

  // Convert text to Braille
  router.post('/convert', convertHandler);

  // Convert Braille to text
  router.post('/reverse', reverseHandler);

  // Batch conversion
  router.post('/batch', batchHandler);

  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(_corsMiddleware())
      .addHandler(router.call);

  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await shelf_io.serve(handler, InternetAddress.anyIPv4, port);
  stdout.writeln(
    'Vietnamese Braille API running on '
    'http://${server.address.host}:${server.port}',
  );
}

Middleware _corsMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      if (request.method == 'OPTIONS') {
        return Response.ok(
          '',
          headers: {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
            'Access-Control-Allow-Headers': 'Content-Type',
          },
        );
      }
      final response = await innerHandler(request);
      return response.change(headers: {'Access-Control-Allow-Origin': '*'});
    };
  };
}
