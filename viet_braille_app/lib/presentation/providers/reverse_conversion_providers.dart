import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:viet_braille_core/viet_braille_core.dart';
import 'conversion_providers.dart';

// ── Reverse Conversion State ──────────────────────────────────────────────

class ReverseConversionState {
  const ReverseConversionState({
    this.brailleInput = '',
    this.result = '',
    this.warnings = const [],
    this.isConverting = false,
  });

  final String brailleInput;
  final String result;
  final List<String> warnings;
  final bool isConverting;

  ReverseConversionState copyWith({
    String? brailleInput,
    String? result,
    List<String>? warnings,
    bool? isConverting,
  }) {
    return ReverseConversionState(
      brailleInput: brailleInput ?? this.brailleInput,
      result: result ?? this.result,
      warnings: warnings ?? this.warnings,
      isConverting: isConverting ?? this.isConverting,
    );
  }
}

// ── Notifier ─────────────────────────────────────────────────────────────

class ReverseConversionNotifier extends StateNotifier<ReverseConversionState> {
  ReverseConversionNotifier({required BrailleMapping mapping})
    : _reverse = BrailleReverseConverterImpl(mapping),
      super(const ReverseConversionState());

  final BrailleReverseConverterImpl _reverse;

  void setBrailleInput(String text) {
    state = state.copyWith(brailleInput: text);
  }

  void clear() {
    state = const ReverseConversionState();
  }

  void convert({BrailleConversionMode mode = BrailleConversionMode.standard}) {
    final input = state.brailleInput.trim();
    if (input.isEmpty) {
      state = state.copyWith(
        result: '',
        warnings: const ['Vui lòng nhập hoặc dán văn bản Braille.'],
      );
      return;
    }

    state = state.copyWith(isConverting: true);

    try {
      final warnings = <String>[];
      final result = _reverse.convert(input, mode: mode);

      // Warn about characters that were not decoded
      if (result.isEmpty && input.isNotEmpty) {
        warnings.add('Không nhận diện được ký hiệu Braille nào.');
      }

      state = state.copyWith(
        result: result,
        warnings: warnings,
        isConverting: false,
      );
    } catch (e) {
      state = state.copyWith(
        result: '',
        warnings: ['Lỗi chuyển đổi: $e'],
        isConverting: false,
      );
    }
  }
}

// ── Provider ─────────────────────────────────────────────────────────────

final reverseConversionProvider =
    StateNotifierProvider<ReverseConversionNotifier, ReverseConversionState>(
      (ref) =>
          ReverseConversionNotifier(mapping: ref.watch(brailleMappingProvider)),
    );
