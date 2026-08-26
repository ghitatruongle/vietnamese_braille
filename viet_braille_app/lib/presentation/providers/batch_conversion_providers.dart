import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:viet_braille_core/viet_braille_core.dart';

import '../../data/file_picker_service.dart';
import '../../data/text_extractor.dart';
import 'conversion_providers.dart';
import 'theme_provider.dart';

/// Kết quả chuyển đổi cho một file.
class BatchFileResult {
  const BatchFileResult({
    required this.fileName,
    required this.status,
    this.brailleUnicode = '',
    this.brfContent = '',
    this.errorMessage,
    this.warningMessage,
  });

  final String fileName;
  final BatchFileStatus status;
  final String brailleUnicode;
  final String brfContent;
  final String? errorMessage;
  final String? warningMessage;

  BatchFileResult copyWith({
    String? fileName,
    BatchFileStatus? status,
    String? brailleUnicode,
    String? brfContent,
    String? errorMessage,
    bool clearErrorMessage = false,
    String? warningMessage,
    bool clearWarningMessage = false,
  }) {
    return BatchFileResult(
      fileName: fileName ?? this.fileName,
      status: status ?? this.status,
      brailleUnicode: brailleUnicode ?? this.brailleUnicode,
      brfContent: brfContent ?? this.brfContent,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      warningMessage: clearWarningMessage
          ? null
          : warningMessage ?? this.warningMessage,
    );
  }
}

enum BatchFileStatus { pending, converting, success, error }

class BatchState {
  const BatchState({this.items = const [], this.isConverting = false});

  final List<BatchFileResult> items;
  final bool isConverting;

  BatchState copyWith({List<BatchFileResult>? items, bool? isConverting}) {
    return BatchState(
      items: items ?? this.items,
      isConverting: isConverting ?? this.isConverting,
    );
  }

  int get successCount =>
      items.where((i) => i.status == BatchFileStatus.success).length;
  int get errorCount =>
      items.where((i) => i.status == BatchFileStatus.error).length;
}

class BatchConversionNotifier extends StateNotifier<BatchState> {
  BatchConversionNotifier({
    required FilePickerServiceBase filePickerService,
    required TextExtractor textExtractor,
    required BrailleConverter brailleConverter,
    required BrfFormatter brfFormatter,
    this.getMarkdownEnabled,
  }) : _filePickerService = filePickerService,
       _textExtractor = textExtractor,
       _brailleConverter = brailleConverter,
       _brfFormatter = brfFormatter,
       super(const BatchState());

  final FilePickerServiceBase _filePickerService;
  final TextExtractor _textExtractor;
  final BrailleConverter _brailleConverter;
  final BrfFormatter _brfFormatter;

  /// Đọc trạng thái toggle "Hỗ trợ định dạng" (markdown B5) tại thời điểm
  /// chuyển đổi; null nghĩa là luôn tắt.
  final bool Function()? getMarkdownEnabled;

  bool get _enableMarkdown => getMarkdownEnabled?.call() ?? false;
  List<FilePickResult> _pickedFiles = [];

  Future<void> pickFiles() async {
    final picked = await _filePickerService.pickMultipleFiles();
    if (picked.isEmpty) return;

    _pickedFiles = picked;
    final items = picked
        .map(
          (f) => BatchFileResult(
            fileName: f.name,
            status: BatchFileStatus.pending,
          ),
        )
        .toList();
    state = state.copyWith(items: items);
  }

  Future<void> convertAll() async {
    if (_pickedFiles.isEmpty || state.isConverting) return;

    state = state.copyWith(isConverting: true);

    // Chốt phần chưa xử lý ngay từ đầu: state.items bị thay bởi `results`
    // sau mỗi vòng nên không được đọc lại để lấy phần đuôi.
    final pendingTail = List<BatchFileResult>.from(state.items);

    final results = <BatchFileResult>[];
    for (var i = 0; i < _pickedFiles.length; i++) {
      final file = _pickedFiles[i];
      results.add(
        BatchFileResult(
          fileName: file.name,
          status: BatchFileStatus.converting,
        ),
      );
      state = state.copyWith(
        items: [...results, ...pendingTail.sublist(results.length)],
      );

      String? errorMessage;
      try {
        if (file.mimeType.startsWith('image/')) {
          errorMessage = 'OCR chưa hỗ trợ trong chuyển đổi batch.';
        } else {
          final rawText = await _textExtractor.extractText(
            file.path,
            file.mimeType,
            bytes: file.bytes,
          );
          if (rawText.trim().isEmpty) {
            errorMessage = 'File rỗng.';
          } else {
            final conversion = _brailleConverter.convertWithDetails(
              rawText.trim(),
              enableMarkdown: _enableMarkdown,
            );
            final brf = _brfFormatter.format(conversion.brailleText);
            results[results.length - 1] = results.last.copyWith(
              status: BatchFileStatus.success,
              brailleUnicode: conversion.brailleText,
              brfContent: brf,
              warningMessage: conversion.warningMessage,
              clearWarningMessage: !conversion.hasWarnings,
            );
          }
        }
      } catch (e) {
        errorMessage = e.toString();
      }

      if (errorMessage != null) {
        results[results.length - 1] = results.last.copyWith(
          status: BatchFileStatus.error,
          errorMessage: errorMessage,
        );
      }
      // Cập nhật sau MỌI nhánh (kể cả lỗi) để item cuối không kẹt ở
      // trạng thái converting.
      state = state.copyWith(items: [...results]);
    }

    state = state.copyWith(isConverting: false);
  }

  void clear() {
    _pickedFiles = [];
    state = const BatchState();
  }

  /// Xuất các file BRF thành công ra thư mục. Trả về số file đã ghi.
  Future<int> exportBrfFiles(String directory) async {
    var written = 0;
    for (final item in state.items) {
      if (item.status != BatchFileStatus.success) continue;
      final baseName = item.fileName.replaceAll(RegExp(r'\.[^.]+$'), '');
      final outPath = '$directory${Platform.pathSeparator}$baseName.brf';
      await File(outPath).writeAsString(item.brfContent, flush: true);
      written++;
    }
    return written;
  }
}

final batchConversionProvider =
    StateNotifierProvider<BatchConversionNotifier, BatchState>(
      (ref) => BatchConversionNotifier(
        filePickerService: ref.watch(filePickerServiceProvider),
        textExtractor: ref.watch(textExtractorProvider),
        brailleConverter: ref.watch(brailleConverterProvider),
        brfFormatter: ref.watch(brfFormatterProvider),
        getMarkdownEnabled: () => ref.read(markdownFormatProvider),
      ),
    );
