import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:viet_braille_core/viet_braille_core.dart';
import '../../core/platform_capabilities.dart';
import '../../data/file_exporter.dart';
import '../../data/file_picker_service.dart';
import '../../data/ocr_processor.dart';
import '../../data/text_extractor.dart';
import 'conversion_notifier.dart';
import 'conversion_state.dart';
import 'history_provider.dart';

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
