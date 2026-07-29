import 'braille_dots.dart';
import 'braille_converter.dart';
import 'braille_mapping.dart';
import 'src/vietnamese_letters.dart';

part 'src/reverse/reverse_types.dart';
part 'src/reverse/reverse_cell_handlers.dart';
part 'src/reverse/reverse_tone_decoder.dart';

abstract class BrailleReverseConverter {
  String convert(
    String brailleText, {
    BrailleConversionMode mode = BrailleConversionMode.standard,
  });
}

class BrailleReverseConverterImpl implements BrailleReverseConverter {
  final BrailleMapping _mapping;

  BrailleReverseConverterImpl(this._mapping);

  // ──────────────────── Precomputed multi-cell reverse maps ─────────────────
  late final Map<String, String> _symbolMap = {
    '${_mapping.symbolPrefix}${_cellOf(_d1 | _d2 | _d6)}': '(',
    '${_mapping.symbolPrefix}${_cellOf(_d3 | _d4 | _d5)}': ')',
    '${_mapping.symbolPrefix}${_cellOf(_d1 | _d6)}': '\\',
    '${_mapping.symbolPrefix}${_cellOf(_d4 | _d5 | _d6)}': '_',
    '${_mapping.symbolPrefix}${_cellOf(_d2 | _d3 | _d4)}': '\$',
    '${_mapping.symbolPrefix}${_cellOf(_d2 | _d6)}': '^',
  };

  late final Map<String, String> _mathMap = {
    '${_mapping.mathPrefix}${_cellOf(_d2 | _d3 | _d5)}': '+',
    '${_mapping.mathPrefix}${_cellOf(_d2 | _d3 | _d5 | _d6)}': '=',
    '${_mapping.mathPrefix}${_cellOf(_d2 | _d3 | _d6)}': '*',
    '${_mapping.mathPrefix}${_cellOf(_d2 | _d4 | _d6)}': '<',
    '${_mapping.mathPrefix}${_cellOf(_d1 | _d3 | _d5)}': '>',
  };

  late final Map<String, String> _specialMap = {
    '${_mapping.specialPrefix}${_cellOf(_d1 | _d2 | _d6)}': '{',
    '${_mapping.specialPrefix}${_cellOf(_d3 | _d4 | _d5)}': '}',
    '${_mapping.specialPrefix}${_cellOf(_d1 | _d2 | _d5 | _d6)}': '|',
    '${_mapping.specialPrefix}${_cellOf(_d3 | _d4 | _d5 | _d6)}': '#',
  };

  late final Map<String, String> _bracketMap = {
    '${_mapping.bracketPrefix}${_cellOf(_d1 | _d2 | _d6)}': '[',
    '${_mapping.bracketPrefix}${_cellOf(_d3 | _d4 | _d5)}': ']',
  };

  // Tone cell → combining diacritic
  late final Map<String, String> _toneCellMap = {
    _cellOf(_d3 | _d5): '\u0301', // sắc
    _cellOf(_d5 | _d6): '\u0300', // huyền
    _cellOf(_d2 | _d6): '\u0309', // hỏi
    _cellOf(_d3 | _d6): '\u0303', // ngã
    _cellOf(_d6): '\u0323', // nặng
  };

  // Tone cells that collide with punctuation — fallback when no vowel context.
  // hỏi (dots 2,6) = ?, ngã (dots 3,6) = -
  late final Map<String, String> _tonePunctuationFallback = {
    _cellOf(_d2 | _d6): '?',
    _cellOf(_d3 | _d6): '-',
  };

  // ──────────────────── Capitalization helpers ─────────────────────────────

  /// Áp dụng capitalization rules, trả về (text đã xử lý, state cập nhật).
  (String text, _CapState state) _applyCapitalization(
    String text, {
    required bool hadCapitalIndicator,
    required _CapState state,
  }) {
    if (text.isEmpty) return (text, state);
    if (state.isAllCapsPhrase || state.isAllCapsWord) {
      return (text.toUpperCase(), state);
    }
    if (state.isInitCapsPhrase && state.isWordStart) {
      return (
        text.substring(0, 1).toUpperCase() + text.substring(1),
        state.copyWith(isWordStart: false),
      );
    }
    if (hadCapitalIndicator || state.capNextLetter) {
      return (
        text.substring(0, 1).toUpperCase() + text.substring(1),
        state.copyWith(capNextLetter: false),
      );
    }
    return (text, state);
  }

  // ──────────────────── Main convert loop ──────────────────────────────────

  @override
  String convert(
    String brailleText, {
    BrailleConversionMode mode = BrailleConversionMode.standard,
  }) {
    final buffer = StringBuffer();
    int i = 0;
    bool inNumber = false;
    var capState = const _CapState();

    while (i < brailleText.length) {
      final cell = brailleText[i];

      if (mode == BrailleConversionMode.lossless &&
          cell == losslessBrailleEscape) {
        if (i + 1 >= brailleText.length) {
          throw const FormatException(
            'Escape marker lossless không có ô Braille theo sau.',
          );
        }
        final escapedCell = brailleText[i + 1];
        final punctuation = _tonePunctuationFallback[escapedCell];
        if (punctuation == null) {
          throw FormatException(
            'Ô sau escape marker không phải dấu câu lossless hợp lệ.',
            brailleText,
            i + 1,
          );
        }
        buffer.write(punctuation);
        capState = capState.copyWith(isWordStart: true, isAllCapsWord: false);
        inNumber = false;
        i += 2;
        continue;
      }

      // ── Whitespace → reset number mode & word boundary ──
      if (_isWhitespace(cell)) {
        inNumber = false;
        capState = capState.copyWith(isWordStart: true, isAllCapsWord: false);
        buffer.write(cell);
        i++;
        continue;
      }

      // ── Ellipsis (dots 3, 3, 3) ──
      if (i + 2 < brailleText.length &&
          cell == _cellOf(_d3) &&
          brailleText[i + 1] == _cellOf(_d3) &&
          brailleText[i + 2] == _cellOf(_d3)) {
        buffer.write('...');
        capState = capState.copyWith(isWordStart: true, isAllCapsWord: false);
        i += 3;
        continue;
      }

      // ── Capitalization markers (Decree 15) ──
      // 1. allCapsPhrase: ⠨⠨ (dots 4,6 + 4,6)
      if (i + 1 < brailleText.length &&
          cell == _mapping.bracketPrefix &&
          brailleText[i + 1] == _mapping.bracketPrefix) {
        capState = capState.copyWith(isAllCapsPhrase: true, isWordStart: true);
        i += 2;
        continue;
      }

      // 2. initCapsPhrase: ⠒⠨ (dots 2,5 + 4,6)
      if (i + 1 < brailleText.length &&
          cell == _cellOf(_d2 | _d5) &&
          brailleText[i + 1] == _mapping.bracketPrefix) {
        capState = capState.copyWith(isInitCapsPhrase: true, isWordStart: true);
        i += 2;
        continue;
      }

      // 3. allCapsWord: ⠸ (dots 4,5,6)
      if (cell == _cellOf(_d4 | _d5 | _d6)) {
        capState = capState.copyWith(isAllCapsWord: true);
        i++;
        continue;
      }

      // 4. endFormat: ⠱ (dots 1,5,6)
      if (cell == _cellOf(_d1 | _d5 | _d6)) {
        capState = capState.copyWith(
          isAllCapsPhrase: false,
          isInitCapsPhrase: false,
        );
        i++;
        continue;
      }

      // 5. Single capital indicator: ⠨ (dots 4,6), unless it's a bracket [ or ]
      if (cell == _mapping.bracketPrefix) {
        bool isBracket = false;
        if (i + 1 < brailleText.length) {
          final nextCell = brailleText[i + 1];
          if (nextCell == _cellOf(_d1 | _d2 | _d6) ||
              nextCell == _cellOf(_d3 | _d4 | _d5)) {
            isBracket = true;
          }
        }
        if (!isBracket) {
          capState = capState.copyWith(capNextLetter: true);
          i++;
          continue;
        }
      }

      // ── Double quote / Star disambiguation for dots 2,3,6 (⠦) ──
      if (cell == _mapping.mapChar('"')) {
        final textSoFar = buffer.toString();
        bool isOpeningQuote = false;
        if (textSoFar.isEmpty ||
            _isWhitespace(textSoFar[textSoFar.length - 1]) ||
            '([{'.contains(textSoFar[textSoFar.length - 1])) {
          if (i + 1 < brailleText.length && _isWhitespace(brailleText[i + 1])) {
            isOpeningQuote = false;
          } else if (i + 1 == brailleText.length) {
            isOpeningQuote = false;
          } else {
            isOpeningQuote = true;
          }
        }
        if (isOpeningQuote) {
          buffer.write('"');
        } else {
          buffer.write('*');
        }
        capState = capState.copyWith(isWordStart: true, isAllCapsWord: false);
        i++;
        continue;
      }

      // ── Number indicator (dots 3,4,5,6) ──
      if (cell == _mapping.numberIndicator) {
        final result = _handleNumberIndicator(brailleText, i);
        if (result.handled) {
          if (result.numberAction == _NumberAction.enter) {
            inNumber = true;
          } else {
            buffer.write(result.output);
          }
          i += result.delta;
          continue;
        }
      }

      // ── Number mode: cell → digit (or exit) ──
      if (inNumber) {
        final result = _handleNumberMode(brailleText, i);
        if (result.handled) {
          if (result.numberAction == _NumberAction.exit) {
            inNumber = false;
          } else {
            buffer.write(result.output);
            i += result.delta;
          }
          continue;
        }
        inNumber = false;
      }

      // ── Prefix cells (symbol, math, special, bracket) ──
      final prefixResult = _handlePrefixCell(brailleText, i);
      if (prefixResult.handled) {
        buffer.write(prefixResult.output);
        i += prefixResult.delta;
        continue;
      }

      // ── Close double quote (dots 3,5,6) ──
      if (cell == _mapping.dquoteClose) {
        buffer.write('"');
        capState = capState.copyWith(isWordStart: true, isAllCapsWord: false);
        i++;
        continue;
      }

      // ── Tone mark (BEFORE letter lookup) ──
      final toneHandled = _handleToneCell(brailleText, i, buffer, capState);
      if (toneHandled != null) {
        final (result, newCapState) = toneHandled;
        if (result.output.isNotEmpty) {
          buffer.write(result.output);
          if (result.output == '?' || result.output == '-') {
            capState = newCapState.copyWith(
              isWordStart: true,
              isAllCapsWord: false,
            );
          } else {
            capState = newCapState.copyWith(isWordStart: false);
          }
        } else {
          capState = newCapState.copyWith(isWordStart: false);
        }
        i += result.delta;
        continue;
      }

      // ── Single-cell fallback: letter / vowel / raw ──
      final decoded = _handleSingleCell(cell);
      if (decoded.length == 1 && _isLetter(decoded)) {
        final (text, newCapState) = _applyCapitalization(
          decoded,
          hadCapitalIndicator: false,
          state: capState,
        );
        buffer.write(text);
        capState = newCapState.copyWith(isWordStart: false);
      } else {
        buffer.write(decoded);
        if (_isWhitespace(decoded) || _isPunctuation(decoded)) {
          capState = capState.copyWith(isWordStart: true, isAllCapsWord: false);
        }
      }
      i++;
    }

    return _mapping.composeNfc(buffer.toString());
  }
}
