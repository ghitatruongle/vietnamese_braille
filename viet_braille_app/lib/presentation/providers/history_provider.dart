import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/history_service.dart';

/// Provider cho HistoryService (sử dụng interface).
final historyServiceProvider = Provider<HistoryServiceBase>((ref) {
  return HistoryServiceImpl();
});
