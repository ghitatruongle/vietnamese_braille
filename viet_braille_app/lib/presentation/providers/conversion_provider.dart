/// Barrel giữ nguyên đường import cũ `conversion_provider.dart`.
///
/// Nội dung đã tách thành các file nhỏ theo trách nhiệm:
/// - [conversion_state.dart]: `AppStatus`, `ConversionState`
/// - [conversion_notifier.dart]: `ConversionNotifier` + pipeline dùng chung
/// - [conversion_providers.dart]: các Riverpod provider (override được trong test)
library;

export 'conversion_notifier.dart';
export 'conversion_providers.dart';
export 'conversion_state.dart';
