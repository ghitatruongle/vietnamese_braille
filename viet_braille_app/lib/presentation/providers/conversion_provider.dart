import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/braille_mapping.dart';
import '../../core/error_handler.dart';
import '../../data/file_exporter.dart';
import '../../data/file_picker_service.dart';
import '../../data/history_service.dart';
import '../../data/ocr_processor.dart';
import '../../data/text_extractor.dart';
import '../../domain/braille_converter.dart';
import '../../domain/braille_reverse_converter.dart';
import '../../domain/brf_formatter.dart';

enum AppStatus { idle, loading, success, error }

class ConversionState {
  const ConversionState({
    this.originalText = '',
    this.brailleUnicode = '',
    this.reverseText = '',
    this.brfContent = '',
    this.status = AppStatus.idle,
    this.errorMessage,
    this.warningMessage,
  });

  final String originalText;
  final String brailleUnicode;
  final String reverseText;
  final String brfContent;
  final AppStatus status;
  final String? errorMessage;
  final String? warningMessage;

  ConversionState copyWith({
    String? originalText,
    String? brailleUnicode,
    String? reverseText,
    String? brfContent,
    AppStatus? status,
    String? errorMessage,
    bool clearErrorMessage = false,
    String? warningMessage,
    bool clearWarningMessage = false,
  }) {
    return ConversionState(
      originalText: originalText ?? this.originalText,
      brailleUnicode: brailleUnicode ?? this.brailleUnicode,
      reverseText: reverseText ?? this.reverseText,
      brfContent: brfContent ?? this.brfContent,
      status: status ?? this.status,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      warningMessage: clearWarningMessage
          ? null
          : warningMessage ?? this.warningMessage,
    );
  }
}

class ConversionNotifier extends StateNotifier<ConversionState> {
  ConversionNotifier({
    required this.filePickerService,
    required this.textExtractor,
    required this.ocrProcessor,
    required this.brailleConverter,
    required this.reverseConverter,
    required this.brfFormatter,
    required this.fileExporter,
    required this.historyService,
  }) : super(const ConversionState());

  final FilePickerServiceBase filePickerService;
  final TextExtractor textExtractor;
  final OcrProcessor ocrProcessor;
  final BrailleConverter brailleConverter;
  final BrailleReverseConverter reverseConverter;
  final BrfFormatter brfFormatter;
  final FileExporterBase fileExporter;
  final HistoryServiceBase historyService;

  /// Chuyển đổi text trực tiếp sang Braille.
  void convertText(String text) {
    if (text.trim().isEmpty) return;

    state = state.copyWith(
      status: AppStatus.loading,
      clearErrorMessage: true,
      clearWarningMessage: true,
    );

    try {
      final conversionResult = brailleConverter.convertWithDetails(text);
      final brailleUnicode = conversionResult.brailleText;
      final reverseText = reverseConverter.convert(brailleUnicode);
      final brfContent = brfFormatter.format(brailleUnicode);

      state = state.copyWith(
        originalText: text,
        brailleUnicode: brailleUnicode,
        reverseText: reverseText,
        brfContent: brfContent,
        status: AppStatus.success,
        clearErrorMessage: true,
        warningMessage: conversionResult.warningMessage,
        clearWarningMessage: !conversionResult.hasWarnings,
      );

      // Lưu vào lịch sử
      historyService.saveEntry(
        ConversionHistoryEntry(
          originalText: text,
          brailleText: brailleUnicode,
          timestamp: DateTime.now(),
        ),
      );
    } catch (e) {
      state = state.copyWith(
        status: AppStatus.error,
        errorMessage: AppErrorHandler.handleError(e),
      );
    }
  }

  /// Chọn file và chuyển đổi sang Braille.
  Future<void> pickAndConvert() async {
    final result = await filePickerService.pickFile();

    if (result == null) {
      return;
    }

    state = state.copyWith(
      status: AppStatus.loading,
      clearErrorMessage: true,
      clearWarningMessage: true,
    );

    try {
      final rawText = result.mimeType.startsWith('image/')
          ? await ocrProcessor.recognizeImage(result.path)
          : await textExtractor.extractText(result.path, result.mimeType);

      final originalText = rawText.trim();
      if (originalText.isEmpty) {
        state = state.copyWith(
          status: AppStatus.error,
          errorMessage: 'File không chứa văn bản.',
        );
        return;
      }

      final conversionResult = brailleConverter.convertWithDetails(
        originalText,
      );
      final brailleUnicode = conversionResult.brailleText;
      final reverseText = reverseConverter.convert(brailleUnicode);
      final brfContent = brfFormatter.format(brailleUnicode);

      state = state.copyWith(
        originalText: originalText,
        brailleUnicode: brailleUnicode,
        reverseText: reverseText,
        brfContent: brfContent,
        status: AppStatus.success,
        clearErrorMessage: true,
        warningMessage: conversionResult.warningMessage,
        clearWarningMessage: !conversionResult.hasWarnings,
      );

      // Lưu vào lịch sử
      historyService.saveEntry(
        ConversionHistoryEntry(
          originalText: originalText,
          brailleText: brailleUnicode,
          timestamp: DateTime.now(),
        ),
      );
    } catch (e) {
      state = state.copyWith(
        status: AppStatus.error,
        errorMessage: AppErrorHandler.handleError(e),
      );
    }
  }

  /// Xuất file BRF và chia sẻ.
  Future<void> exportBrf() async {
    if (state.brfContent.isEmpty) {
      state = state.copyWith(
        status: AppStatus.error,
        errorMessage: 'Chưa có nội dung BRF để xuất.',
      );
      return;
    }

    try {
      final path = await fileExporter.saveTemp(state.brfContent, 'output');
      await fileExporter.share(path);

      state = state.copyWith(
        status: AppStatus.success,
        clearErrorMessage: true,
      );
    } catch (e) {
      state = state.copyWith(
        status: AppStatus.error,
        errorMessage: AppErrorHandler.handleError(e),
      );
    }
  }
}

final conversionProvider =
    StateNotifierProvider<ConversionNotifier, ConversionState>((ref) {
      final filePickerService = FilePickerServiceImpl();
      final textExtractor = TextExtractorImpl();
      final brailleMapping = BrailleMappingImpl();
      final ocrProcessor = OcrProcessorImpl(brailleMapping);
      final brailleConverter = BrailleConverterImpl(brailleMapping);
      final reverseConverter = BrailleReverseConverterImpl(brailleMapping);
      final brfFormatter = BrfFormatterImpl();
      final fileExporter = FileExporterImpl();
      final historyService = HistoryServiceImpl();

      ref.onDispose(() => ocrProcessor.dispose());

      return ConversionNotifier(
        filePickerService: filePickerService,
        textExtractor: textExtractor,
        ocrProcessor: ocrProcessor,
        brailleConverter: brailleConverter,
        reverseConverter: reverseConverter,
        brfFormatter: brfFormatter,
        fileExporter: fileExporter,
        historyService: historyService,
      );
    });
