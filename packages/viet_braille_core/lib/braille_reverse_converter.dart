import 'braille_dots.dart';
import 'braille_converter.dart';
import 'braille_mapping.dart';

abstract class BrailleReverseConverter {
  String convert(
    String brailleText, {
    BrailleConversionMode mode = BrailleConversionMode.standard,
  });
}

/// Kết quả xử lý một cell trong reverse converter.
class _CellResult {
  const _CellResult({required this.handled, this.delta = 1, this.output = ''});
  static const _CellResult unhandled = _CellResult(handled: false);
  final bool handled;
  final int delta;
  final String output;
}

// Sentinel outputs truyền trạng thái number-mode giữa helper và main loop.
const String _kEnterNumber = '_ENTER_NUMBER_';
const String _kExitNumber = '_EXIT_NUMBER_';

/// Immutable state cho capitalization tracking trong một lần convert().
class _CapState {
  const _CapState({
    this.isAllCapsPhrase = false,
    this.isInitCapsPhrase = false,
    this.isAllCapsWord = false,
    this.capNextLetter = false,
    this.isWordStart = true,
  });

  final bool isAllCapsPhrase;
  final bool isInitCapsPhrase;
  final bool isAllCapsWord;
  final bool capNextLetter;
  final bool isWordStart;

  _CapState copyWith({
    bool? isAllCapsPhrase,
    bool? isInitCapsPhrase,
    bool? isAllCapsWord,
    bool? capNextLetter,
    bool? isWordStart,
  }) {
    return _CapState(
      isAllCapsPhrase: isAllCapsPhrase ?? this.isAllCapsPhrase,
      isInitCapsPhrase: isInitCapsPhrase ?? this.isInitCapsPhrase,
      isAllCapsWord: isAllCapsWord ?? this.isAllCapsWord,
      capNextLetter: capNextLetter ?? this.capNextLetter,
      isWordStart: isWordStart ?? this.isWordStart,
    );
  }
}

class BrailleReverseConverterImpl implements BrailleReverseConverter {
  final BrailleMapping _mapping;

  BrailleReverseConverterImpl(this._mapping);

  // ──────────────────── Precomputed multi-cell reverse maps ─────────────────
  late final Map<String, String> _symbolMap = {
    '${_mapping.symbolPrefix}${_cell(_d1 | _d2 | _d6)}': '(',
    '${_mapping.symbolPrefix}${_cell(_d3 | _d4 | _d5)}': ')',
    '${_mapping.symbolPrefix}${_cell(_d1 | _d6)}': '\\',
    '${_mapping.symbolPrefix}${_cell(_d4 | _d5 | _d6)}': '_',
    '${_mapping.symbolPrefix}${_cell(_d2 | _d3 | _d4)}': '\$',
    '${_mapping.symbolPrefix}${_cell(_d2 | _d6)}': '^',
  };

  late final Map<String, String> _mathMap = {
    '${_mapping.mathPrefix}${_cell(_d2 | _d3 | _d5)}': '+',
    '${_mapping.mathPrefix}${_cell(_d2 | _d3 | _d5 | _d6)}': '=',
    '${_mapping.mathPrefix}${_cell(_d2 | _d3 | _d6)}': '*',
    '${_mapping.mathPrefix}${_cell(_d2 | _d4 | _d6)}': '<',
    '${_mapping.mathPrefix}${_cell(_d1 | _d3 | _d5)}': '>',
  };

  late final Map<String, String> _specialMap = {
    '${_mapping.specialPrefix}${_cell(_d1 | _d2 | _d6)}': '{',
    '${_mapping.specialPrefix}${_cell(_d3 | _d4 | _d5)}': '}',
    '${_mapping.specialPrefix}${_cell(_d1 | _d2 | _d5 | _d6)}': '|',
    '${_mapping.specialPrefix}${_cell(_d3 | _d4 | _d5 | _d6)}': '#',
  };

  late final Map<String, String> _bracketMap = {
    '${_mapping.bracketPrefix}${_cell(_d1 | _d2 | _d6)}': '[',
    '${_mapping.bracketPrefix}${_cell(_d3 | _d4 | _d5)}': ']',
  };

  // Tone cell → combining diacritic
  late final Map<String, String> _toneCellMap = {
    _cell(_d3 | _d5): '\u0301', // sắc
    _cell(_d5 | _d6): '\u0300', // huyền
    _cell(_d2 | _d6): '\u0309', // hỏi
    _cell(_d3 | _d6): '\u0303', // ngã
    _cell(_d6): '\u0323', // nặng
  };

  // Tone cells that collide with punctuation — fallback when no vowel context.
  // hỏi (dots 2,6) = ?, ngã (dots 3,6) = -
  late final Map<String, String> _tonePunctuationFallback = {
    _cell(_d2 | _d6): '?',
    _cell(_d3 | _d6): '-',
  };

  // Dot bitmasks ủy quyền cho BrailleDots chia sẻ.
  static const int _d1 = BrailleDots.d1;
  static const int _d2 = BrailleDots.d2;
  static const int _d3 = BrailleDots.d3;
  static const int _d4 = BrailleDots.d4;
  static const int _d5 = BrailleDots.d5;
  static const int _d6 = BrailleDots.d6;

  static String _cell(int dots) => BrailleDots.cell(dots);

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

  static bool _isLetter(String ch) {
    if (ch.length != 1) return false;
    final c = ch.toLowerCase();
    return 'abcdefghijklmnopqrstuvwxyzđâăêôơư'.contains(c);
  }

  static bool _isPunctuation(String ch) {
    if (ch.length != 1) return false;
    return ',.?!...:;\'"()-/\\*&@[]{}|\$%^'.contains(ch);
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
          cell == _cell(_d3) &&
          brailleText[i + 1] == _cell(_d3) &&
          brailleText[i + 2] == _cell(_d3)) {
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
          cell == _cell(_d2 | _d5) &&
          brailleText[i + 1] == _mapping.bracketPrefix) {
        capState = capState.copyWith(isInitCapsPhrase: true, isWordStart: true);
        i += 2;
        continue;
      }

      // 3. allCapsWord: ⠸ (dots 4,5,6)
      if (cell == _cell(_d4 | _d5 | _d6)) {
        capState = capState.copyWith(isAllCapsWord: true);
        i++;
        continue;
      }

      // 4. endFormat: ⠱ (dots 1,5,6)
      if (cell == _cell(_d1 | _d5 | _d6)) {
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
          if (nextCell == _cell(_d1 | _d2 | _d6) ||
              nextCell == _cell(_d3 | _d4 | _d5)) {
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
          if (result.output == _kEnterNumber) {
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
          if (result.output == _kExitNumber) {
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

  // ──────────────────── Private helper methods ─────────────────────────────

  _CellResult _handleNumberIndicator(String brailleText, int i) {
    if (i + 2 < brailleText.length &&
        brailleText[i + 1] == _cell(_d2 | _d4 | _d5) &&
        brailleText[i + 2] == _cell(_d3 | _d5 | _d6)) {
      return const _CellResult(handled: true, delta: 3, output: '%');
    }
    if (i + 1 < brailleText.length) {
      final nextDigit = _mapping.reverseMapDigit(brailleText[i + 1]);
      if (nextDigit != null) {
        return const _CellResult(
          handled: true,
          delta: 1,
          output: _kEnterNumber,
        );
      }
    }
    return const _CellResult(handled: true, delta: 1, output: '#');
  }

  _CellResult _handleNumberMode(String brailleText, int i) {
    final cell = brailleText[i];
    final digit = _mapping.reverseMapDigit(cell);
    if (digit != null) {
      return _CellResult(handled: true, delta: 1, output: digit);
    }
    if (cell == _cell(_d3) && i + 1 < brailleText.length) {
      final nextDigit = _mapping.reverseMapDigit(brailleText[i + 1]);
      if (nextDigit != null) {
        return const _CellResult(handled: true, delta: 1, output: '.');
      }
    }
    if (cell == _cell(_d2) && i + 1 < brailleText.length) {
      final nextDigit = _mapping.reverseMapDigit(brailleText[i + 1]);
      if (nextDigit != null) {
        return const _CellResult(handled: true, delta: 1, output: ',');
      }
    }
    return const _CellResult(handled: true, delta: 0, output: _kExitNumber);
  }

  _CellResult _handlePrefixCell(String brailleText, int i) {
    final cell = brailleText[i];
    if (i + 1 >= brailleText.length) return _CellResult.unhandled;

    final nextCell = brailleText[i + 1];
    final twoCells = brailleText.substring(i, i + 2);

    if (cell == _mapping.symbolPrefix) {
      final sym = _symbolMap[twoCells];
      if (sym != null) {
        return _CellResult(handled: true, delta: 2, output: sym);
      }
    }
    if (cell == _mapping.mathPrefix) {
      final sym = _mathMap[twoCells];
      if (sym != null) {
        return _CellResult(handled: true, delta: 2, output: sym);
      }
    }
    if (cell == _mapping.specialPrefix) {
      final sym = _specialMap[twoCells];
      if (sym != null) {
        return _CellResult(handled: true, delta: 2, output: sym);
      }
    }
    if (cell == _mapping.bracketPrefix) {
      final sym = _bracketMap[twoCells];
      if (sym != null) {
        return _CellResult(handled: true, delta: 2, output: sym);
      }
      final reversed = _mapping.reverseMapChar(nextCell);
      if (reversed != null) {
        return _CellResult(
          handled: true,
          delta: 2,
          output: reversed.toUpperCase(),
        );
      }
      final vowel = _mapping.reverseMapVowel(nextCell);
      if (vowel != null) {
        return _CellResult(
          handled: true,
          delta: 2,
          output: vowel.toUpperCase(),
        );
      }
      return _CellResult(handled: true, delta: 2, output: nextCell);
    }
    return _CellResult.unhandled;
  }

  /// Xử lý tone cell — trả về (_CellResult, updated _CapState) hoặc null nếu không match.
  (_CellResult, _CapState)? _handleToneCell(
    String brailleText,
    int i,
    StringBuffer buffer,
    _CapState capState,
  ) {
    final cell = brailleText[i];
    final toneMark = _toneCellMap[cell];
    if (toneMark == null) return null;

    final text = buffer.toString();
    final isQuContext =
        text.length >= 2 &&
        text[text.length - 1].toLowerCase() == 'u' &&
        text[text.length - 2].toLowerCase() == 'q';
    final isGiContext =
        text.length >= 2 &&
        text[text.length - 1].toLowerCase() == 'i' &&
        text[text.length - 2].toLowerCase() == 'g';

    // Sau một nguyên âm đã giải mã, ô hỏi/ngã nằm giữa các từ/ký tự gần như
    // chắc chắn là dấu câu. Quy tắc này xử lý đúng các chuỗi như `a?a`,
    // `a-a`, `Có?Ai` và `Á-Âu`, thay vì gắn thanh vào nguyên âm kế tiếp.
    final collidingPunctuation = _tonePunctuationFallback[cell];
    if (collidingPunctuation != null &&
        !isQuContext &&
        !isGiContext &&
        text.isNotEmpty &&
        _isDecodedVowel(text[text.length - 1])) {
      return (
        _CellResult(handled: true, output: collidingPunctuation),
        capState,
      );
    }

    // ── qu context: tone applies to next vowel ──
    if (isQuContext && i + 1 < brailleText.length) {
      int lookAhead = i + 1;
      bool hadCapital = false;
      while (lookAhead < brailleText.length &&
          brailleText[lookAhead] == _mapping.capitalIndicator) {
        hadCapital = true;
        lookAhead++;
      }
      if (lookAhead < brailleText.length) {
        final result = _tryToneOnNextVowel(brailleText, lookAhead, toneMark);
        if (result != null) {
          final firstChar = result.substring(0, 1);
          if (firstChar == 'y' || firstChar == 'Y') {
            int nextVowelIdx = lookAhead + 1;
            bool hadCapitalVowel = false;
            while (nextVowelIdx < brailleText.length &&
                brailleText[nextVowelIdx] == _mapping.capitalIndicator) {
              hadCapitalVowel = true;
              nextVowelIdx++;
            }
            if (nextVowelIdx < brailleText.length) {
              final nextVowelResult = _tryToneOnNextVowel(
                brailleText,
                nextVowelIdx,
                toneMark,
              );
              if (nextVowelResult != null) {
                final yStr = hadCapital ? 'Y' : 'y';
                final vowelStr = hadCapitalVowel
                    ? nextVowelResult.toUpperCase()
                    : nextVowelResult;
                final composed = _mapping.composeNfc(yStr + vowelStr);
                final (capitalized, newCapState) = _applyCapitalization(
                  composed,
                  hadCapitalIndicator: false,
                  state: capState,
                );
                buffer.write(capitalized);
                return (
                  _CellResult(handled: true, delta: nextVowelIdx - i + 1),
                  newCapState,
                );
              }
            }
          }
          final composed = _mapping.composeNfc(result);
          final (capitalized, newCapState) = _applyCapitalization(
            composed,
            hadCapitalIndicator: hadCapital,
            state: capState,
          );
          buffer.write(capitalized);
          return (
            _CellResult(handled: true, delta: lookAhead - i + 1),
            newCapState,
          );
        }
      }
    }

    // ── gi context: check if tone belongs to next vowel ──
    if (isGiContext && i + 1 < brailleText.length) {
      int lookAhead = i + 1;
      bool hadCapital = false;
      while (lookAhead < brailleText.length &&
          brailleText[lookAhead] == _mapping.capitalIndicator) {
        hadCapital = true;
        lookAhead++;
      }
      if (lookAhead < brailleText.length) {
        final result = _tryToneOnNextVowel(brailleText, lookAhead, toneMark);
        if (result != null) {
          final composed = _mapping.composeNfc(result);
          final (capitalized, newCapState) = _applyCapitalization(
            composed,
            hadCapitalIndicator: hadCapital,
            state: capState,
          );
          buffer.write(capitalized);
          return (
            _CellResult(handled: true, delta: lookAhead - i + 1),
            newCapState,
          );
        }
      }
      _retroactiveTone(buffer, text, toneMark);
      return (const _CellResult(handled: true, delta: 1), capState);
    }

    if (isGiContext) {
      _retroactiveTone(buffer, text, toneMark);
      return (const _CellResult(handled: true, delta: 1), capState);
    }

    // ── Normal: đọc toàn bộ phần vần sau tone ──
    //
    // TT15 đặt tone trước toàn bộ phần vần, không nhất thiết ngay trước
    // nguyên âm mang thanh trong chính tả Latin. Ví dụ:
    //   Việt  = v + nặng + i + ê + t
    //   đường = đ + huyền + ư + ơ + n + g
    // Vì vậy reverse phải chọn đúng nguyên âm trong cụm thay vì gắn tone vào
    // ô nguyên âm đầu tiên.
    if (i + 1 < brailleText.length) {
      final sequence = _decodeTonedVowelSequence(brailleText, i + 1, toneMark);
      if (sequence != null) {
        final (capitalized, newCapState) = _applyCapitalization(
          sequence.text,
          hadCapitalIndicator: sequence.hadCapitalIndicator,
          state: capState,
        );
        buffer.write(capitalized);
        return (
          _CellResult(handled: true, delta: sequence.endIndex - i),
          newCapState,
        );
      }
    }

    // ── No vowel follows → disambiguate tone vs punctuation ──
    final isCollidingTone = _tonePunctuationFallback.containsKey(cell);

    if (!isCollidingTone && text.isNotEmpty) {
      final lastChar = text[text.length - 1];
      if (_isLatinVowel(lastChar)) {
        _retroactiveTone(buffer, text, toneMark);
        return (const _CellResult(handled: true, delta: 1), capState);
      }
    }

    final punctuation = _tonePunctuationFallback[cell];
    final output = punctuation ?? toneMark;
    return (_CellResult(handled: true, delta: 1, output: output), capState);
  }

  String? _tryToneOnNextVowel(
    String brailleText,
    int nextIdx,
    String toneMark,
  ) {
    final nextCell = brailleText[nextIdx];
    final nextVowel = _mapping.reverseMapVowel(nextCell);
    if (nextVowel != null) return nextVowel + toneMark;
    final nextReversed = _mapping.reverseMapChar(nextCell);
    if (nextReversed != null && _isLatinVowel(nextReversed)) {
      return nextReversed + toneMark;
    }
    return null;
  }

  ({String text, int endIndex, bool hadCapitalIndicator})?
  _decodeTonedVowelSequence(
    String brailleText,
    int startIndex,
    String toneMark,
  ) {
    var cursor = startIndex;
    var hadCapitalIndicator = false;
    final vowels = <String>[];

    while (cursor < brailleText.length) {
      if (brailleText[cursor] == _mapping.capitalIndicator) {
        if (vowels.isNotEmpty) break;
        hadCapitalIndicator = true;
        cursor++;
        continue;
      }

      final vowel = _decodeVowelCell(brailleText[cursor]);
      if (vowel == null) break;
      vowels.add(vowel);
      cursor++;
    }

    if (vowels.isEmpty) return null;

    final following = cursor < brailleText.length
        ? _handleSingleCell(brailleText[cursor])
        : '';
    final hasFollowingConsonant =
        following.length == 1 &&
        _isLetter(following) &&
        !_isDecodedVowel(following);
    final targetIndex = _toneTargetIndex(
      vowels,
      hasFollowingConsonant: hasFollowingConsonant,
    );
    final toned = <String>[
      for (var index = 0; index < vowels.length; index++)
        index == targetIndex ? vowels[index] + toneMark : vowels[index],
    ].join();

    return (
      text: _mapping.composeNfc(toned),
      endIndex: cursor,
      hadCapitalIndicator: hadCapitalIndicator,
    );
  }

  String? _decodeVowelCell(String cell) {
    final vietnameseVowel = _mapping.reverseMapVowel(cell);
    if (vietnameseVowel != null) return vietnameseVowel;
    final latin = _mapping.reverseMapChar(cell);
    if (latin != null && _isLatinVowel(latin)) return latin;
    return null;
  }

  static int _toneTargetIndex(
    List<String> vowels, {
    required bool hasFollowingConsonant,
  }) {
    // Vowel mang dấu phụ là trung tâm của các vần iê/yê, uô, ươ, uâ...
    const preferredNuclei = {'ê', 'ơ', 'ô', 'â', 'ă'};
    for (var index = vowels.length - 1; index >= 0; index--) {
      if (preferredNuclei.contains(vowels[index])) return index;
    }

    final cluster = vowels.join();
    if (hasFollowingConsonant &&
        (cluster == 'oa' || cluster == 'oe' || cluster == 'uy')) {
      return vowels.length - 1;
    }

    // Các vần mở hòa, khỏe, thủy và ia, ua, ưa, ai, ao, oi... mang thanh
    // ở nguyên âm đầu theo chính tả phổ biến hiện hành.
    return 0;
  }

  void _retroactiveTone(StringBuffer buffer, String text, String toneMark) {
    final lastChar = text[text.length - 1];
    buffer.clear();
    buffer.write(text.substring(0, text.length - 1));
    buffer.write(lastChar + toneMark);
  }

  String _handleSingleCell(String cell) {
    final reversed = _mapping.reverseMapChar(cell);
    if (reversed != null) return reversed;
    final vowel = _mapping.reverseMapVowel(cell);
    if (vowel != null) return vowel;
    return cell;
  }

  static bool _isWhitespace(String ch) =>
      ch == ' ' || ch == '\n' || ch == '\t' || ch == '\r';

  static bool _isLatinVowel(String ch) => 'aeiouy'.contains(ch);

  static bool _isDecodedVowel(String ch) {
    return 'aàáảãạăằắẳẵặâầấẩẫậ'
            'eèéẻẽẹêềếểễệ'
            'iìíỉĩị'
            'oòóỏõọôồốổỗộơờớởỡợ'
            'uùúủũụưừứửữự'
            'yỳýỷỹỵ'
        .contains(ch.toLowerCase());
  }
}
