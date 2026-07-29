import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:shelf/shelf.dart';

const _jsonHeaders = {'Content-Type': 'application/json; charset=utf-8'};

Middleware requestIdMiddleware({String Function()? generateId}) {
  final generator = generateId ?? _generateRequestId;
  final validRequestId = RegExp(r'^[A-Za-z0-9._:-]{1,64}$');

  return (innerHandler) {
    return (request) async {
      final supplied = request.headers['x-request-id'];
      final requestId = supplied != null && validRequestId.hasMatch(supplied)
          ? supplied
          : generator();
      final response = await innerHandler(
        request.change(context: {'requestId': requestId}),
      );
      return response.change(headers: {'X-Request-ID': requestId});
    };
  };
}

Middleware structuredLogMiddleware({
  void Function(String line)? logger,
  DateTime Function()? clock,
}) {
  final writeLog = logger ?? stdout.writeln;
  final now = clock ?? DateTime.now;

  return (innerHandler) {
    return (request) async {
      final startedAt = now();
      Response response;
      try {
        response = await innerHandler(request);
      } catch (error) {
        writeLog(
          jsonEncode({
            'timestamp': now().toUtc().toIso8601String(),
            'request_id': request.context['requestId'],
            'method': request.method,
            'path': request.requestedUri.path,
            'status': 500,
            'duration_ms': now().difference(startedAt).inMilliseconds,
            'error_type': error.runtimeType.toString(),
          }),
        );
        rethrow;
      }
      writeLog(
        jsonEncode({
          'timestamp': now().toUtc().toIso8601String(),
          'request_id': request.context['requestId'],
          'method': request.method,
          'path': request.requestedUri.path,
          'status': response.statusCode,
          'duration_ms': now().difference(startedAt).inMilliseconds,
        }),
      );
      return response;
    };
  };
}

Middleware securityHeadersMiddleware() {
  return (innerHandler) {
    return (request) async {
      final response = await innerHandler(request);
      return response.change(
        headers: {
          'Cache-Control': 'no-store',
          'Referrer-Policy': 'no-referrer',
          'X-Content-Type-Options': 'nosniff',
        },
      );
    };
  };
}

Middleware corsMiddleware(Set<String> allowedOrigins) {
  return (innerHandler) {
    return (request) async {
      final origin = request.headers['origin'];
      if (origin == null) return innerHandler(request);

      final wildcard = allowedOrigins.contains('*');
      final allowed = wildcard || allowedOrigins.contains(origin);
      if (!allowed) {
        if (request.method == 'OPTIONS') {
          return Response(
            403,
            body: jsonEncode({
              'error': 'Origin is not allowed',
              'code': 'origin_not_allowed',
            }),
            headers: _jsonHeaders,
          );
        }
        return innerHandler(request);
      }

      final corsHeaders = <String, String>{
        'Access-Control-Allow-Origin': wildcard ? '*' : origin,
        'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
        'Access-Control-Allow-Headers':
            'Authorization, Content-Type, X-API-Key, X-Request-ID',
        'Access-Control-Max-Age': '600',
        if (!wildcard) 'Vary': 'Origin',
      };
      if (request.method == 'OPTIONS') {
        return Response(204, headers: corsHeaders);
      }

      final response = await innerHandler(request);
      return response.change(headers: corsHeaders);
    };
  };
}

Middleware apiKeyAuthMiddleware(Set<String> apiKeys) {
  if (apiKeys.isEmpty) {
    return (innerHandler) => innerHandler;
  }

  return (innerHandler) {
    return (request) async {
      if (request.method == 'OPTIONS' || request.url.path == 'health') {
        return innerHandler(request);
      }

      final directKey = request.headers['x-api-key'];
      final authorization = request.headers['authorization'];
      final bearerKey =
          authorization != null &&
              authorization.toLowerCase().startsWith('bearer ')
          ? authorization.substring(7).trim()
          : null;
      final suppliedKey = directKey?.trim().isNotEmpty == true
          ? directKey!.trim()
          : bearerKey;
      final authorized =
          suppliedKey != null &&
          apiKeys.any((expected) => _constantTimeEqual(expected, suppliedKey));
      if (!authorized) {
        return Response(
          401,
          body: jsonEncode({
            'error': 'A valid API key is required',
            'code': 'unauthorized',
          }),
          headers: {
            ..._jsonHeaders,
            'WWW-Authenticate': 'Bearer realm="vietnamese-braille-api"',
          },
        );
      }

      return innerHandler(request);
    };
  };
}

/// Chiến lược giới hạn tần suất theo client key.
///
/// [InMemoryRateLimiter] chỉ đếm trong tiến trình hiện tại nên không chia sẻ
/// trạng thái khi scale ngang; deployment nhiều instance cần implementation
/// dùng backend chung (ví dụ Redis) và inject qua `createApiHandler`.
abstract interface class RateLimiter {
  int get maxRequests;

  RateLimitDecision check(String key);
}

class InMemoryRateLimiter implements RateLimiter {
  InMemoryRateLimiter({
    required this.maxRequests,
    required this.window,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  @override
  final int maxRequests;
  final Duration window;
  final DateTime Function() _clock;
  final Map<String, _RateBucket> _buckets = {};
  var _checks = 0;

  @override
  RateLimitDecision check(String key) {
    final now = _clock();
    final current = _buckets[key];
    final bucket =
        current == null || now.difference(current.startedAt) >= window
        ? _RateBucket(startedAt: now, count: 0)
        : current;
    bucket.count++;
    _buckets[key] = bucket;

    _checks++;
    if (_checks % 1000 == 0) {
      _buckets.removeWhere(
        (_, value) => now.difference(value.startedAt) >= window,
      );
    }

    final remaining = max(0, maxRequests - bucket.count);
    final retryAfter = max(
      1,
      window.inSeconds - now.difference(bucket.startedAt).inSeconds,
    );
    return RateLimitDecision(
      allowed: bucket.count <= maxRequests,
      remaining: remaining,
      retryAfterSeconds: retryAfter,
    );
  }
}

class RateLimitDecision {
  const RateLimitDecision({
    required this.allowed,
    required this.remaining,
    required this.retryAfterSeconds,
  });

  final bool allowed;
  final int remaining;
  final int retryAfterSeconds;
}

Middleware rateLimitMiddleware(
  RateLimiter limiter, {
  bool trustProxy = false,
  String Function(Request request)? clientKey,
}) {
  return (innerHandler) {
    return (request) async {
      if (request.method == 'OPTIONS' || request.url.path == 'health') {
        return innerHandler(request);
      }

      final key =
          clientKey?.call(request) ??
          _clientKey(request, trustProxy: trustProxy);
      final decision = limiter.check(key);
      final headers = {
        'RateLimit-Limit': '${limiter.maxRequests}',
        'RateLimit-Remaining': '${decision.remaining}',
        'RateLimit-Reset': '${decision.retryAfterSeconds}',
      };
      if (!decision.allowed) {
        return Response(
          429,
          body: jsonEncode({
            'error': 'Too many requests',
            'code': 'rate_limit_exceeded',
          }),
          headers: {
            ..._jsonHeaders,
            ...headers,
            'Retry-After': '${decision.retryAfterSeconds}',
          },
        );
      }

      final response = await innerHandler(request);
      return response.change(headers: headers);
    };
  };
}

class _RateBucket {
  _RateBucket({required this.startedAt, required this.count});

  final DateTime startedAt;
  int count;
}

String _clientKey(Request request, {required bool trustProxy}) {
  if (trustProxy) {
    final forwarded = request.headers['x-forwarded-for'];
    if (forwarded != null && forwarded.trim().isNotEmpty) {
      return forwarded.split(',').first.trim();
    }
  }
  final connection = request.context['shelf.io.connection_info'];
  if (connection is HttpConnectionInfo) {
    return connection.remoteAddress.address;
  }
  return 'unknown-client';
}

String _generateRequestId() {
  final timestamp = DateTime.now().microsecondsSinceEpoch.toRadixString(16);
  final random = Random.secure().nextInt(0x7fffffff).toRadixString(16);
  return '$timestamp-$random';
}

bool _constantTimeEqual(String expected, String actual) {
  final expectedUnits = expected.codeUnits;
  final actualUnits = actual.codeUnits;
  final length = max(expectedUnits.length, actualUnits.length);
  var difference = expectedUnits.length ^ actualUnits.length;
  for (var index = 0; index < length; index++) {
    final expectedUnit = index < expectedUnits.length
        ? expectedUnits[index]
        : 0;
    final actualUnit = index < actualUnits.length ? actualUnits[index] : 0;
    difference |= expectedUnit ^ actualUnit;
  }
  return difference == 0;
}
