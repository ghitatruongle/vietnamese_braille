import 'dart:io';

import 'package:shelf/shelf_io.dart' as shelf_io;

import 'package:viet_braille_api/api_app.dart';
import 'package:viet_braille_api/api_config.dart';

Future<void> main() async {
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final handler = createApiHandler(
    config: ApiConfig.fromEnvironment(Platform.environment),
  );
  final server = await shelf_io.serve(handler, InternetAddress.anyIPv4, port);
  stdout.writeln(
    'Vietnamese Braille API running on '
    'http://${server.address.host}:${server.port}',
  );
}
