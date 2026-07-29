import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:test/test.dart';
import 'package:viet_braille_api/api_app.dart';
import 'package:viet_braille_api/api_config.dart';

void main() {
  test('serves authenticated conversion over a real HTTP socket', () async {
    const apiKey = 'integration-test-secret';
    final handler = createApiHandler(
      config: const ApiConfig(apiKeys: {apiKey}, requireApiKey: true),
      logger: (_) {},
    );
    final server = await shelf_io.serve(
      handler,
      InternetAddress.loopbackIPv4,
      0,
    );
    addTearDown(() => server.close(force: true));
    final client = HttpClient();
    addTearDown(() => client.close(force: true));

    final request = await client.post(
      server.address.host,
      server.port,
      '/convert',
    );
    request.headers.contentType = ContentType.json;
    request.headers.set('X-API-Key', apiKey);
    request.write(jsonEncode({'text': 'Việt Nam'}));
    final response = await request.close();
    final payload =
        jsonDecode(await utf8.decoder.bind(response).join())
            as Map<String, dynamic>;

    expect(response.statusCode, HttpStatus.ok);
    expect(payload['braille'], isA<String>());
    expect((payload['braille'] as String), isNotEmpty);
    expect(response.headers.value('x-request-id'), isNotEmpty);
    expect(response.headers.value('x-content-type-options'), 'nosniff');
  });
}
