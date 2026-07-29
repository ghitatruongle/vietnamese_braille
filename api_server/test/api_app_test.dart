import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:test/test.dart';
import 'package:viet_braille_api/api_app.dart';
import 'package:viet_braille_api/api_config.dart';
import 'package:viet_braille_api/api_middleware.dart';

Request _request(
  String method,
  String path, {
  Map<String, String>? headers,
  Object? body,
}) {
  return Request(
    method,
    Uri.parse('http://localhost$path'),
    headers: headers,
    body: body,
  );
}

Future<Map<String, dynamic>> _json(Response response) async =>
    jsonDecode(await response.readAsString()) as Map<String, dynamic>;

void main() {
  test('environment configuration parses valid values and safe defaults', () {
    final configured = ApiConfig.fromEnvironment({
      'ALLOWED_ORIGINS': 'https://one.example, https://two.example',
      'API_KEYS': 'first-secret, second-secret, first-secret',
      'API_AUTH_REQUIRED': 'TRUE',
      'RATE_LIMIT_REQUESTS': '7',
      'RATE_LIMIT_WINDOW_SECONDS': '30',
      'TRUST_PROXY': 'TRUE',
    });
    final fallback = ApiConfig.fromEnvironment({
      'RATE_LIMIT_REQUESTS': '0',
      'RATE_LIMIT_WINDOW_SECONDS': 'invalid',
    });

    expect(configured.allowedOrigins, {
      'https://one.example',
      'https://two.example',
    });
    expect(configured.apiKeys, {'first-secret', 'second-secret'});
    expect(configured.requireApiKey, isTrue);
    expect(configured.rateLimitRequests, 7);
    expect(configured.rateLimitWindow, const Duration(seconds: 30));
    expect(configured.trustProxy, isTrue);
    expect(fallback.allowedOrigins, isEmpty);
    expect(fallback.apiKeys, isEmpty);
    expect(fallback.requireApiKey, isFalse);
    expect(fallback.rateLimitRequests, 120);
    expect(fallback.rateLimitWindow, const Duration(minutes: 1));
    expect(fallback.trustProxy, isFalse);
  });

  test('mandatory authentication rejects an empty key set', () {
    expect(
      () => ApiConfig.fromEnvironment({'API_AUTH_REQUIRED': 'true'}),
      throwsA(isA<FormatException>()),
    );
    expect(
      () => createApiHandler(
        config: const ApiConfig(requireApiKey: true),
        logger: (_) {},
      ),
      throwsA(isA<StateError>()),
    );
  });

  test('health response has request ID and security headers', () async {
    final handler = createApiHandler(
      logger: (_) {},
      requestIdGenerator: () => 'generated-id',
    );
    final response = await handler(_request('GET', '/health'));

    expect(response.statusCode, 200);
    expect(response.headers['x-request-id'], 'generated-id');
    expect(response.headers['x-content-type-options'], 'nosniff');
    expect(response.headers['referrer-policy'], 'no-referrer');
    expect(response.headers['cache-control'], 'no-store');
  });

  test('preserves only a valid caller request ID', () async {
    final handler = createApiHandler(
      logger: (_) {},
      requestIdGenerator: () => 'generated-id',
    );
    final accepted = await handler(
      _request('GET', '/health', headers: {'X-Request-ID': 'caller-123'}),
    );
    final replaced = await handler(
      _request(
        'GET',
        '/health',
        headers: {'X-Request-ID': 'invalid id with spaces'},
      ),
    );

    expect(accepted.headers['x-request-id'], 'caller-123');
    expect(replaced.headers['x-request-id'], 'generated-id');
  });

  test('CORS allows configured origin and rejects foreign preflight', () async {
    final handler = createApiHandler(
      config: const ApiConfig(allowedOrigins: {'https://app.example'}),
      logger: (_) {},
    );
    final allowed = await handler(
      _request(
        'OPTIONS',
        '/convert',
        headers: {'Origin': 'https://app.example'},
      ),
    );
    final rejected = await handler(
      _request(
        'OPTIONS',
        '/convert',
        headers: {'Origin': 'https://foreign.example'},
      ),
    );

    expect(allowed.statusCode, 204);
    expect(
      allowed.headers['access-control-allow-origin'],
      'https://app.example',
    );
    expect(allowed.headers['vary'], 'Origin');
    expect(rejected.statusCode, 403);
    expect((await _json(rejected))['code'], 'origin_not_allowed');
    expect(
      allowed.headers['access-control-allow-headers'],
      contains('X-API-Key'),
    );
  });

  test(
    'CORS annotates allowed requests and supports explicit wildcard',
    () async {
      final restricted = createApiHandler(
        config: const ApiConfig(allowedOrigins: {'https://app.example'}),
        logger: (_) {},
      );
      final wildcard = createApiHandler(
        config: const ApiConfig(allowedOrigins: {'*'}),
        logger: (_) {},
      );

      final allowed = await restricted(
        _request('GET', '/health', headers: {'Origin': 'https://app.example'}),
      );
      final foreign = await restricted(
        _request(
          'GET',
          '/health',
          headers: {'Origin': 'https://foreign.example'},
        ),
      );
      final public = await wildcard(
        _request('GET', '/health', headers: {'Origin': 'https://any.example'}),
      );

      expect(
        allowed.headers['access-control-allow-origin'],
        'https://app.example',
      );
      expect(foreign.headers['access-control-allow-origin'], isNull);
      expect(public.headers['access-control-allow-origin'], '*');
      expect(public.headers['vary'], isNull);
    },
  );

  test('rate limiter returns 429 with retry metadata', () async {
    final handler = createApiHandler(
      config: const ApiConfig(rateLimitRequests: 2),
      logger: (_) {},
      clientKey: (_) => 'test-client',
    );

    Future<Response> convert() async => handler(
      _request(
        'POST',
        '/convert',
        headers: {'Content-Type': 'application/json'},
        body: '{"text":"xin"}',
      ),
    );

    expect((await convert()).statusCode, 200);
    expect((await convert()).statusCode, 200);
    final limited = await convert();

    expect(limited.statusCode, 429);
    expect(limited.headers['retry-after'], isNotNull);
    expect(limited.headers['ratelimit-limit'], '2');
    expect((await _json(limited))['code'], 'rate_limit_exceeded');
  });

  test('API key authentication accepts header and bearer token', () async {
    const apiKey = 'correct-secret-value';
    final handler = createApiHandler(
      config: const ApiConfig(apiKeys: {apiKey}),
      logger: (_) {},
    );

    final direct = await handler(
      _request(
        'POST',
        '/convert',
        headers: {'Content-Type': 'application/json', 'X-API-Key': apiKey},
        body: '{"text":"xin"}',
      ),
    );
    final bearer = await handler(
      _request(
        'POST',
        '/convert',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: '{"text":"xin"}',
      ),
    );

    expect(direct.statusCode, 200);
    expect(bearer.statusCode, 200);
  });

  test('API key authentication rejects absent and invalid secrets', () async {
    final handler = createApiHandler(
      config: const ApiConfig(apiKeys: {'correct-secret-value'}),
      logger: (_) {},
    );

    final absent = await handler(
      _request(
        'POST',
        '/convert',
        headers: {'Content-Type': 'application/json'},
        body: '{"text":"private-content"}',
      ),
    );
    final invalid = await handler(
      _request(
        'POST',
        '/convert',
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': 'wrong-secret-value',
        },
        body: '{"text":"private-content"}',
      ),
    );

    expect(absent.statusCode, 401);
    expect(invalid.statusCode, 401);
    expect((await _json(absent))['code'], 'unauthorized');
    expect(absent.headers['www-authenticate'], contains('Bearer'));
    expect(await invalid.readAsString(), isNot(contains('private-content')));
  });

  test('health and CORS preflight bypass API key authentication', () async {
    final handler = createApiHandler(
      config: const ApiConfig(
        apiKeys: {'correct-secret-value'},
        allowedOrigins: {'https://app.example'},
      ),
      logger: (_) {},
    );

    final health = await handler(_request('GET', '/health'));
    final preflight = await handler(
      _request(
        'OPTIONS',
        '/convert',
        headers: {'Origin': 'https://app.example'},
      ),
    );

    expect(health.statusCode, 200);
    expect(preflight.statusCode, 204);
  });

  test('structured log records metadata without request body', () async {
    final logs = <String>[];
    final handler = createApiHandler(
      logger: logs.add,
      requestIdGenerator: () => 'log-id',
    );
    final response = await handler(
      _request(
        'POST',
        '/convert',
        headers: {'Content-Type': 'application/json'},
        body: '{"text":"private-content"}',
      ),
    );

    expect(response.statusCode, 200);
    expect(logs, hasLength(1));
    final entry = jsonDecode(logs.single) as Map<String, dynamic>;
    expect(entry['request_id'], 'log-id');
    expect(entry['method'], 'POST');
    expect(entry['path'], '/convert');
    expect(entry['status'], 200);
    expect(logs.single, isNot(contains('private-content')));
  });

  test('structured logger records exception type then rethrows', () async {
    final logs = <String>[];
    final handler = requestIdMiddleware(generateId: () => 'error-id')(
      structuredLogMiddleware(logger: logs.add)(
        (_) => throw StateError('secret failure detail'),
      ),
    );

    await expectLater(
      handler(_request('GET', '/explode')),
      throwsA(isA<StateError>()),
    );
    expect(logs, hasLength(1));
    final entry = jsonDecode(logs.single) as Map<String, dynamic>;
    expect(entry['request_id'], 'error-id');
    expect(entry['status'], 500);
    expect(entry['error_type'], 'StateError');
    expect(logs.single, isNot(contains('secret failure detail')));
  });

  test('rate limiter resets after its configured window', () async {
    var now = DateTime.utc(2026, 7, 27);
    final handler = createApiHandler(
      config: const ApiConfig(
        rateLimitRequests: 1,
        rateLimitWindow: Duration(seconds: 10),
      ),
      logger: (_) {},
      clock: () => now,
      clientKey: (_) => 'window-client',
    );

    Future<Response> convert() async => handler(
      _request(
        'POST',
        '/convert',
        headers: {'Content-Type': 'application/json'},
        body: '{"text":"xin"}',
      ),
    );

    expect((await convert()).statusCode, 200);
    expect((await convert()).statusCode, 429);
    now = now.add(const Duration(seconds: 11));
    expect((await convert()).statusCode, 200);
  });

  test('trusted proxy uses first forwarded client address', () async {
    final limiter = InMemoryRateLimiter(
      maxRequests: 1,
      window: const Duration(minutes: 1),
    );
    final handler = rateLimitMiddleware(limiter, trustProxy: true)(
      (_) => Response.ok('ok'),
    );

    final first = await handler(
      _request(
        'GET',
        '/convert',
        headers: {'X-Forwarded-For': '203.0.113.1, 10.0.0.1'},
      ),
    );
    final secondClient = await handler(
      _request('GET', '/convert', headers: {'X-Forwarded-For': '203.0.113.2'}),
    );

    expect(first.statusCode, 200);
    expect(secondClient.statusCode, 200);
  });

  test('health checks are not rate limited', () async {
    final handler = createApiHandler(
      config: const ApiConfig(rateLimitRequests: 1),
      logger: (_) {},
      clientKey: (_) => 'health-client',
    );

    for (var index = 0; index < 3; index++) {
      final response = await handler(_request('GET', '/health'));
      expect(response.statusCode, 200);
    }
  });
}
