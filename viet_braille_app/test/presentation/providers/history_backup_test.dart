import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:viet_braille_app/data/history_service.dart';
import 'package:viet_braille_app/presentation/providers/history_backup.dart';
import 'package:viet_braille_app/presentation/providers/history_provider.dart';

ConversionHistoryEntry _entry(
  String original,
  int day, {
  String braille = '⠁',
}) => ConversionHistoryEntry(
  originalText: original,
  brailleText: braille,
  timestamp: DateTime(2026, 8, 25, 8, day),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('exportHistoryJson / parseHistoryJson', () {
    test('xuất đủ schema và nhập lại khớp nguyên văn', () {
      final entries = [_entry('Xin chào', 1), _entry('Hà Nội', 2)];
      final json = exportHistoryJson(entries);

      expect(json, contains('"schema_version": 1'));
      expect(json, contains('"kind": "conversion_history"'));

      final parsed = parseHistoryJson(json);
      expect(parsed.ok, isTrue);
      expect(parsed.entries, hasLength(2));
      expect(parsed.entries[0].originalText, 'Xin chào');
      expect(parsed.entries[1].timestamp, DateTime(2026, 8, 25, 8, 2));
    });

    test('tệp rỗng / JSON hỏng / sai schema đều báo lỗi tiếng Việt', () {
      expect(parseHistoryJson('').ok, isFalse);
      expect(parseHistoryJson('{không phải json').ok, isFalse);
      expect(
        parseHistoryJson('{"schema_version": 99}').error,
        contains('Schema không hỗ trợ'),
      );
      expect(
        parseHistoryJson('{"schema_version": 1}').error,
        contains('không phải bản sao lưu'),
      );
      expect(
        parseHistoryJson(
          '{"schema_version": 1, "kind": "conversion_history",'
          ' "entries": "x"}',
        ).error,
        contains('entries'),
      );
      expect(
        parseHistoryJson(
          '{"schema_version": 1, "kind": "conversion_history",'
          ' "entries": [{"originalText": "a"}]}',
        ).ok,
        isFalse,
      );
    });
  });

  group('HistoryServiceImpl replaceAll / mergeEntries', () {
    late ProviderContainer container;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

    HistoryServiceBase service() => container.read(historyServiceProvider);

    test('replaceAll ghi đè toàn bộ', () async {
      await service().saveEntry(_entry('cũ', 1));
      final written = await service().replaceAll([_entry('mới A', 2)]);
      expect(written, 1);
      final history = await service().loadHistory();
      expect(history, hasLength(1));
      expect(history.single.originalText, 'mới A');
    });

    test('mergeEntries bỏ trùng lặp theo bản sắc bản ghi', () async {
      final dup = _entry('trùng', 3);
      await service().saveEntry(dup);

      final added = await service().mergeEntries([
        dup, // trùng → bỏ
        _entry('trùng', 4), // khác thời điểm → thêm
        _entry('khác nội dung', 3, braille: '⠃'), // khác braille → thêm
      ]);
      expect(added, 2);

      final addedAgain = await service().mergeEntries([dup]);
      expect(addedAgain, 0);

      final history = await service().loadHistory();
      expect(history, hasLength(3));
    });

    test('mergeEntries sắp xếp mới nhất đứng đầu bất kể thứ tự tệp', () async {
      await service().mergeEntries([
        _entry('cũ nhất', 1),
        _entry('mới nhất', 5),
        _entry('giữa', 3),
      ]);
      final history = await service().loadHistory();
      expect(history.map((e) => e.originalText).toList(), [
        'mới nhất',
        'giữa',
        'cũ nhất',
      ]);
    });

    test('replaceAll chặn bởi giới hạn số mục', () async {
      final many = List.generate(60, (i) => _entry('mục $i', i % 28 + 1));
      final written = await service().replaceAll(many);
      expect(written, lessThanOrEqualTo(50));
      expect(await service().loadHistory(), hasLength(written));
    });
  });
}
