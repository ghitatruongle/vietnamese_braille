import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import 'package:viet_braille_core/viet_braille_core.dart';
import '../../core/error_handler.dart';
import '../../core/platform_capabilities.dart';
import '../../data/file_exporter.dart';
import '../../data/file_picker_service.dart';
import '../../data/history_service.dart';
import '../../data/ocr_processor.dart';
import '../../data/text_extractor.dart';
import 'history_provider.dart';

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
    this.onConversionSuccess,
  }) : super(const ConversionState());

  final FilePickerServiceBase filePickerService;
  final TextExtractor textExtractor;
  final OcrProcessor ocrProcessor;
  final BrailleConverter brailleConverter;
  final BrailleReverseConverter reverseConverter;
  final BrfFormatter brfFormatter;
  final FileExporterBase fileExporter;
  final HistoryServiceBase historyService;
  final Future<void> Function()? onConversionSuccess;

  /// Chuyển đổi text trực tiếp sang Braille.
  Future<void> convertText(String text) async {
    if (text.trim().isEmpty) return;

    state = state.copyWith(
      status: AppStatus.loading,
      clearErrorMessage: true,
      clearWarningMessage: true,
    );

    try {
      final conversionResult = brailleConverter.convertWithDetails(text);
      final brailleUnicode = conversionResult.brailleText;
      final losslessBraille = brailleConverter.convert(
        text,
        mode: BrailleConversionMode.lossless,
      );
      final reverseText = reverseConverter.convert(
        losslessBraille,
        mode: BrailleConversionMode.lossless,
      );
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

      await _saveHistory(originalText: text, brailleText: brailleUnicode);
      await _provideSuccessFeedback();
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
      final isImage = result.mimeType.startsWith('image/');
      if (isImage && !PlatformCapabilities.supportsOcr) {
        throw UnsupportedError(PlatformCapabilities.ocrUnsupportedMessage);
      }
      if (isImage && result.path == null) {
        throw UnsupportedError(
          'OCR cần đường dẫn ảnh cục bộ trên Android hoặc iOS.',
        );
      }

      final rawText = isImage
          ? await ocrProcessor.recognizeImage(result.path!)
          : await textExtractor.extractText(
              result.path,
              result.mimeType,
              bytes: result.bytes,
            );

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
      final losslessBraille = brailleConverter.convert(
        originalText,
        mode: BrailleConversionMode.lossless,
      );
      final reverseText = reverseConverter.convert(
        losslessBraille,
        mode: BrailleConversionMode.lossless,
      );
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

      await _saveHistory(
        originalText: originalText,
        brailleText: brailleUnicode,
      );
      await _provideSuccessFeedback();
    } catch (e) {
      state = state.copyWith(
        status: AppStatus.error,
        errorMessage: AppErrorHandler.handleError(e),
      );
    }
  }

  /// Chuyển đổi tệp từ đường dẫn tệp cục bộ (phục vụ Drag & Drop trên Desktop).
  Future<void> convertFilePath(String filePath) async {
    final lower = filePath.toLowerCase();
    final mimeType = lower.endsWith('.docx')
        ? 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
        : 'text/plain';

    state = state.copyWith(
      status: AppStatus.loading,
      clearErrorMessage: true,
      clearWarningMessage: true,
    );

    try {
      final rawText = await textExtractor.extractText(filePath, mimeType);
      final originalText = rawText.trim();
      if (originalText.isEmpty) {
        state = state.copyWith(
          status: AppStatus.error,
          errorMessage: 'Tệp không chứa văn bản.',
        );
        return;
      }

      final conversionResult = brailleConverter.convertWithDetails(
        originalText,
      );
      final brailleUnicode = conversionResult.brailleText;
      final losslessBraille = brailleConverter.convert(
        originalText,
        mode: BrailleConversionMode.lossless,
      );
      final reverseText = reverseConverter.convert(
        losslessBraille,
        mode: BrailleConversionMode.lossless,
      );
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

      await _saveHistory(
        originalText: originalText,
        brailleText: brailleUnicode,
      );
      await _provideSuccessFeedback();
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
      await fileExporter.shareBrf(state.brfContent, 'output');

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

  /// Xuất bản Braille Unicode thành PDF có font hỗ trợ chữ nổi.
  Future<void> exportPdf() async {
    if (state.brailleUnicode.isEmpty) {
      state = state.copyWith(
        status: AppStatus.error,
        errorMessage: 'Chưa có nội dung Braille để xuất PDF.',
      );
      return;
    }

    try {
      await fileExporter.exportPdf(
        state.brailleUnicode,
        'vietnamese-braille.pdf',
      );

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

  Future<void> _saveHistory({
    required String originalText,
    required String brailleText,
  }) async {
    try {
      await historyService.saveEntry(
        ConversionHistoryEntry(
          originalText: originalText,
          brailleText: brailleText,
          timestamp: DateTime.now(),
        ),
      );
    } catch (_) {
      const historyWarning =
          'Đã chuyển đổi nhưng không thể lưu vào lịch sử trên thiết bị.';
      final currentWarning = state.warningMessage;
      state = state.copyWith(
        warningMessage: currentWarning == null
            ? historyWarning
            : '$currentWarning $historyWarning',
      );
    }
  }

  Future<void> _provideSuccessFeedback() async {
    try {
      await onConversionSuccess?.call();
    } catch (_) {
      // Haptic feedback is optional and must never turn a valid conversion
      // into an error on unsupported devices.
    }
  }
}

// ── Service providers (có thể override trong test để inject mock/fake) ──
final filePickerServiceProvider = Provider<FilePickerServiceBase>(
  (ref) => FilePickerServiceImpl(),
);
final textExtractorProvider = Provider<TextExtractor>(
  (ref) => TextExtractorImpl(),
);
final brailleMappingProvider = Provider<BrailleMapping>(
  (ref) => BrailleMappingImpl(),
);
final ocrProcessorProvider = Provider<OcrProcessor>((ref) {
  final OcrProcessor ocrProcessor = PlatformCapabilities.supportsOcr
      ? OcrProcessorImpl(ref.watch(brailleMappingProvider))
      : const UnsupportedOcrProcessor();
  ref.onDispose(ocrProcessor.dispose);
  return ocrProcessor;
});
final brailleConverterProvider = Provider<BrailleConverter>(
  (ref) => BrailleConverterImpl(ref.watch(brailleMappingProvider)),
);
final reverseConverterProvider = Provider<BrailleReverseConverter>(
  (ref) => BrailleReverseConverterImpl(ref.watch(brailleMappingProvider)),
);
final brfFormatterProvider = Provider<BrfFormatter>(
  (ref) => BrfFormatterImpl(),
);
final fileExporterProvider = Provider<FileExporterBase>(
  (ref) => FileExporterImpl(),
);
final conversionProvider =
    StateNotifierProvider<ConversionNotifier, ConversionState>((ref) {
      return ConversionNotifier(
        filePickerService: ref.watch(filePickerServiceProvider),
        textExtractor: ref.watch(textExtractorProvider),
        ocrProcessor: ref.watch(ocrProcessorProvider),
        brailleConverter: ref.watch(brailleConverterProvider),
        reverseConverter: ref.watch(reverseConverterProvider),
        brfFormatter: ref.watch(brfFormatterProvider),
        fileExporter: ref.watch(fileExporterProvider),
        historyService: ref.watch(historyServiceProvider),
        onConversionSuccess: HapticFeedback.lightImpact,
      );
    });
