part of '../../braille_reverse_converter.dart';

/// Chọn nguyên âm mang thanh trong một cụm vần đã giải mã.
int _toneTargetIndex(
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

/// Toàn bộ logic giải mã ô thanh điệu, tách khỏi main loop để mỗi file giữ
/// một trách nhiệm. Extension private cùng library nên truy cập được state
/// nội bộ của [BrailleReverseConverterImpl].
extension _ToneDecoding on BrailleReverseConverterImpl {
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

  void _retroactiveTone(StringBuffer buffer, String text, String toneMark) {
    final lastChar = text[text.length - 1];
    buffer.clear();
    buffer.write(text.substring(0, text.length - 1));
    buffer.write(lastChar + toneMark);
  }
}
