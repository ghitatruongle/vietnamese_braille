import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:viet_braille_core/viet_braille_core.dart';

import 'api_config.dart';
import 'api_middleware.dart';
import 'handlers/convert_handler.dart';

Handler createApiHandler({
  ApiConfig config = const ApiConfig(),
  void Function(String line)? logger,
  DateTime Function()? clock,
  String Function()? requestIdGenerator,
  String Function(Request request)? clientKey,
  RateLimiter? rateLimiter,
  BrailleConverter? converter,
  BrailleReverseConverter? reverseConverter,
}) {
  if (config.requireApiKey && config.apiKeys.isEmpty) {
    throw StateError(
      'API keys are required when API authentication is mandatory.',
    );
  }

  final handlers = converter == null && reverseConverter == null
      ? BrailleHandlers.withDefaults()
      : () {
          final mapping = BrailleMappingImpl();
          return BrailleHandlers(
            converter: converter ?? BrailleConverterImpl(mapping),
            reverseConverter:
                reverseConverter ?? BrailleReverseConverterImpl(mapping),
          );
        }();

  final router = Router()
    ..get(
      '/health',
      (Request request) => Response.ok(
        '{"status":"ok"}',
        headers: {'Content-Type': 'application/json; charset=utf-8'},
      ),
    )
    ..post('/convert', handlers.convert)
    ..post('/reverse', handlers.reverse)
    ..post('/batch', handlers.batch);

  final limiter =
      rateLimiter ??
      InMemoryRateLimiter(
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
