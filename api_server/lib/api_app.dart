import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'api_config.dart';
import 'api_middleware.dart';
import 'handlers/convert_handler.dart';

Handler createApiHandler({
  ApiConfig config = const ApiConfig(),
  void Function(String line)? logger,
  DateTime Function()? clock,
  String Function()? requestIdGenerator,
  String Function(Request request)? clientKey,
}) {
  if (config.requireApiKey && config.apiKeys.isEmpty) {
    throw StateError(
      'API keys are required when API authentication is mandatory.',
    );
  }

  final router = Router()
    ..get(
      '/health',
      (Request request) => Response.ok(
        '{"status":"ok"}',
        headers: {'Content-Type': 'application/json; charset=utf-8'},
      ),
    )
    ..post('/convert', convertHandler)
    ..post('/reverse', reverseHandler)
    ..post('/batch', batchHandler);

  final limiter = InMemoryRateLimiter(
    maxRequests: config.rateLimitRequests,
    window: config.rateLimitWindow,
    clock: clock,
  );

  return Pipeline()
      .addMiddleware(requestIdMiddleware(generateId: requestIdGenerator))
      .addMiddleware(structuredLogMiddleware(logger: logger, clock: clock))
      .addMiddleware(securityHeadersMiddleware())
      .addMiddleware(corsMiddleware(config.allowedOrigins))
      .addMiddleware(
        rateLimitMiddleware(
          limiter,
          trustProxy: config.trustProxy,
          clientKey: clientKey,
        ),
      )
      .addMiddleware(apiKeyAuthMiddleware(config.apiKeys))
      .addHandler(router.call);
}
