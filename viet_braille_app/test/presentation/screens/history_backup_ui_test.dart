import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:viet_braille_app/data/file_picker_service.dart';
import 'package:viet_braille_app/data/file_exporter.dart';
import 'package:viet_braille_app/data/history_service.dart';
import 'package:viet_braille_app/data/tts_service.dart';
import 'package:viet_braille_app/presentation/providers/conversion_providers.dart';
import 'package:viet_braille_app/presentation/providers/history_provider.dart';
import 'package:viet_braille_app/presentation/screens/history_screen.dart';

class _ScriptedPicker implements FilePickerServiceBase {
  _ScriptedPicker(this.result);
  final FilePickResult? result;

  @override
  Future<FilePickResult?> pickFile() async => result;

  @override
  Future<List<FilePickResult>> pickMultipleFiles() async => [];
}

class _RecordingExporter implements FileExporterBase {
  String? savedContent;
  String? savedBaseName;
  var shareCalls = 0;

  @override
  Future<String> saveTemp(String content, [String baseName = 'output']) async {
    savedContent = content;
    savedBaseName = baseName;
    return 'C:/tmp/$baseName.json';
  }

  @override
  Future<void> share(String filePath) async => shareCalls++;

  @override
  Future<void> shareBrf(String content, [String baseName = 'output']) async {}

  @override
  Future<void> exportPdf(String brailleText, String fileName) async {}
}

Future<ConversionHistoryEntry> _seedEntry(
  ProviderContainer container,
  String text,
) async {
  final entry = ConversionHistoryEntry(
    originalText: text,
    brailleText: '⠭',
    timestamp: DateTime(2026, 8, 25, 9),
  );
  await container.read(historyServiceProvider).saveEntry(entry);
  return entry;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HistoryScreen sao lưu/khôi phục (UI)', () {
    testWidgets('xuất lịch sử ra JSON qua exporter', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await _seedEntry(container, 'Xin chào lịch sử');

      final exporter = _RecordingExporter();
      final scoped = ProviderContainer(
        overrides: [fileExporterProvider.overrideWithValue(exporter)],
      );
      addTearDown(scoped.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: scoped,
          child: const MaterialApp(home: HistoryScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byTooltip('Xuất bản sao lưu (JSON)'));
      await tester.tap(find.byTooltip('Xuất bản sao lưu (JSON)'));
      await tester.pumpAndSettle();

      expect(exporter.savedBaseName, 'lich_su_bien_doi');
      expect(exporter.savedContent!, contains('"kind": "conversion_history"'));
      expect(exporter.savedContent!, contains('Xin chào lịch sử'));
      expect(exporter.shareCalls, 1);
    });

    testWidgets('nhập JSON ở chế độ Gộp bỏ trùng và thêm bản ghi mới', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final existing = await _seedEntry(container, 'đã có sẵn');

      final backup = jsonEncode({
        'schema_version': 1,
        'kind': 'conversion_history',
        'entries': [
          {
            'originalText': 'đã có sẵn',
            'brailleText': '⠭',
            'timestamp': existing.timestamp.toIso8601String(),
          },
          {
            'originalText': 'bản ghi từ tệp',
            'brailleText': '⠃',
            'timestamp': DateTime(2026, 8, 24, 10).toIso8601String(),
          },
        ],
      });
      final picker = _ScriptedPicker(
        FilePickResult(
          bytes: Uint8List.fromList(utf8.encode(backup)),
          mimeType: 'application/json',
          name: 'backup.json',
        ),
      );

      final scoped = ProviderContainer(
        overrides: [filePickerServiceProvider.overrideWithValue(picker)],
      );
      addTearDown(scoped.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: scoped,
          child: const MaterialApp(home: HistoryScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byTooltip('Nhập bản sao lưu (JSON)'));
      await tester.tap(find.byTooltip('Nhập bản sao lưu (JSON)'));
      await tester.pumpAndSettle();

      expect(find.text('Nhập bản sao lưu'), findsOneWidget);
      await tester.tap(find.text('Gộp'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Đã gộp thêm 1 bản ghi mới.'), findsOneWidget);
      expect(find.textContaining('bản ghi từ tệp'), findsOneWidget);
      expect(find.textContaining('đã có sẵn'), findsOneWidget);
    });

    testWidgets('nhập tệp sai schema hiển thị lỗi, không hỏi gộp/thay', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final picker = _ScriptedPicker(
        FilePickResult(
          bytes: Uint8List.fromList(utf8.encode('{"schema_version": 9}')),
          mimeType: 'application/json',
          name: 'bad.json',
        ),
      );

      final scoped = ProviderContainer(
        overrides: [filePickerServiceProvider.overrideWithValue(picker)],
      );
      addTearDown(scoped.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: scoped,
          child: const MaterialApp(home: HistoryScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byTooltip('Nhập bản sao lưu (JSON)'));
      await tester.tap(find.byTooltip('Nhập bản sao lưu (JSON)'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Schema không hỗ trợ'), findsOneWidget);
      expect(find.text('Thay thế'), findsNothing);
    });
  });

  group('TtsServiceImpl trong môi trường test', () {
    test('speak bắt lỗi platform channel và trả về false', () async {
      final tts = TtsServiceImpl();
      expect(await tts.speak('xin chào'), isFalse);
      expect(await tts.speak('   '), isFalse);
      await tts.setRate(0.7);
      await tts.setPitch(1.4);
    });
  });
}
