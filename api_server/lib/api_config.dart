/// Cấu hình API.
///
/// Đường deploy qua [ApiConfig.fromEnvironment] là secure-by-default:
/// bắt buộc API key trừ khi đặt tường minh `ALLOW_ANONYMOUS=true`.
/// Constructor trực tiếp giữ mặc định mở cho test và nhúng có chủ đích.
class ApiConfig {
  const ApiConfig({
    this.allowedOrigins = const <String>{},
    this.apiKeys = const <String>{},
    this.requireApiKey = false,
    this.rateLimitRequests = 120,
    this.rateLimitWindow = const Duration(minutes: 1),
    this.trustProxy = false,
  });

  final Set<String> allowedOrigins;
  final Set<String> apiKeys;
  final bool requireApiKey;
  final int rateLimitRequests;
  final Duration rateLimitWindow;
  final bool trustProxy;

  factory ApiConfig.fromEnvironment(Map<String, String> environment) {
    final origins = (environment['ALLOWED_ORIGINS'] ?? '')
        .split(',')
        .map((origin) => origin.trim())
        .where((origin) => origin.isNotEmpty)
        .toSet();
    final apiKeys = (environment['API_KEYS'] ?? '')
        .split(',')
        .map((key) => key.trim())
        .where((key) => key.isNotEmpty)
        .toSet();
    final requests = int.tryParse(environment['RATE_LIMIT_REQUESTS'] ?? '');
    final seconds = int.tryParse(
      environment['RATE_LIMIT_WINDOW_SECONDS'] ?? '',
    );
    final allowAnonymous =
        (environment['ALLOW_ANONYMOUS'] ?? '').trim().toLowerCase() == 'true';
    final requireApiKey = !allowAnonymous;
    if (requireApiKey && apiKeys.isEmpty) {
      throw const FormatException(
        'API_KEYS must not be empty; set ALLOW_ANONYMOUS=true to explicitly '
        'run the API without authentication',
      );
    }

    return ApiConfig(
      allowedOrigins: origins,
      apiKeys: apiKeys,
      requireApiKey: requireApiKey,
      rateLimitRequests: requests != null && requests > 0 ? requests : 120,
      rateLimitWindow: Duration(
        seconds: seconds != null && seconds > 0 ? seconds : 60,
      ),
      trustProxy:
          (environment['TRUST_PROXY'] ?? '').trim().toLowerCase() == 'true',
    );
  }
}
