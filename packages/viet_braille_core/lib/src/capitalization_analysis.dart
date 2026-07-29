/// Kiểu chỉ báo viết hoa áp dụng cho một cụm nhiều từ.
enum PhraseCapitalizationMode { none, allCaps, initialCaps }

/// Thông tin viết hoa đã phân tích cho một từ trong chuỗi chuẩn hóa.
final class WordCapitalizationInfo {
  WordCapitalizationInfo({
    required this.start,
    required this.end,
    required this.text,
    required this.allCaps,
    required this.initialCaps,
    required this.isRomanNumeral,
  });

  final int start;
  final int end;
  final String text;
  final bool allCaps;
  final bool initialCaps;
  final bool isRomanNumeral;

  PhraseCapitalizationMode phraseMode = PhraseCapitalizationMode.none;
  bool isPhraseStart = false;
  bool isPhraseEnd = false;
}

/// Kết quả phân tích được lập chỉ mục để converter tra cứu O(1).
final class CapitalizationAnalysis {
  CapitalizationAnalysis(List<WordCapitalizationInfo> words)
    : wordsByStart = {for (final word in words) word.start: word},
      wordsByEnd = {for (final word in words) word.end: word};

  final Map<int, WordCapitalizationInfo> wordsByStart;
  final Map<int, WordCapitalizationInfo> wordsByEnd;
}

/// Phân tích từ, số La Mã và phạm vi cụm viết hoa theo TT15.
final class CapitalizationAnalyzer {
  const CapitalizationAnalyzer();

  static final RegExp _wordPattern = RegExp(
    r'[a-zàáảãạâầấẩẫậăằắẳẵặèéẻẽẹêềếểễệìíỉĩịòóỏõọ'
    r'ôồốổỗộơờớởỡợùúủũụưừứửữựỳýỷỹỵđ]+',
  );
  static final RegExp _romanNumeralPattern = RegExp(r'^[ivxlcdm]+$');

  CapitalizationAnalysis analyze(String normalized, List<bool> capitalFlags) {
    final words = _collectWords(normalized, capitalFlags);
    _markAllCapsPhrases(normalized, words);
    _markInitialCapsPhrases(normalized, words);
    _consumeHandledCapitalFlags(words, capitalFlags);
    return CapitalizationAnalysis(words);
  }

  static List<WordCapitalizationInfo> _collectWords(
    String normalized,
    List<bool> capitalFlags,
  ) {
    final words = <WordCapitalizationInfo>[];
    for (final match in _wordPattern.allMatches(normalized)) {
      final start = match.start;
      final end = match.end;
      final wordText = normalized.substring(start, end);

      var allCaps = end - start > 1;
      var initialCaps = end > start && capitalFlags[start];
      for (var index = start; index < end; index++) {
        if (!capitalFlags[index]) {
          allCaps = false;
        }
        if (index > start && capitalFlags[index]) {
          initialCaps = false;
        }
      }

      words.add(
        WordCapitalizationInfo(
          start: start,
          end: end,
          text: wordText,
          allCaps: allCaps,
          initialCaps: initialCaps,
          isRomanNumeral: allCaps && _romanNumeralPattern.hasMatch(wordText),
        ),
      );
    }
    return words;
  }

  static void _markAllCapsPhrases(
    String normalized,
    List<WordCapitalizationInfo> words,
  ) {
    var index = 0;
    while (index < words.length) {
      if (words[index].isRomanNumeral || !words[index].allCaps) {
        index++;
        continue;
      }

      var end = index + 1;
      while (end < words.length) {
        if (words[end].isRomanNumeral || !words[end].allCaps) {
          break;
        }
        if (!_hasOnlyWhitespaceBetween(
          normalized,
          words[end - 1],
          words[end],
        )) {
          break;
        }
        end++;
      }

      if (end > index + 1) {
        _markPhrase(words, index, end, PhraseCapitalizationMode.allCaps);
        index = end;
      } else {
        index++;
      }
    }
  }

  static void _markInitialCapsPhrases(
    String normalized,
    List<WordCapitalizationInfo> words,
  ) {
    var index = 0;
    while (index < words.length) {
      final word = words[index];
      if (word.phraseMode != PhraseCapitalizationMode.none ||
          !word.initialCaps) {
        index++;
        continue;
      }

      var end = index + 1;
      while (end < words.length) {
        final candidate = words[end];
        if (candidate.phraseMode != PhraseCapitalizationMode.none ||
            !candidate.initialCaps) {
          break;
        }
        if (!_hasOnlyWhitespaceBetween(normalized, words[end - 1], candidate)) {
          break;
        }
        end++;
      }

      if (end > index + 1) {
        _markPhrase(words, index, end, PhraseCapitalizationMode.initialCaps);
        index = end;
      } else {
        index++;
      }
    }
  }

  static bool _hasOnlyWhitespaceBetween(
    String normalized,
    WordCapitalizationInfo left,
    WordCapitalizationInfo right,
  ) => normalized.substring(left.end, right.start).trim().isEmpty;

  static void _markPhrase(
    List<WordCapitalizationInfo> words,
    int start,
    int end,
    PhraseCapitalizationMode mode,
  ) {
    for (var index = start; index < end; index++) {
      final word = words[index];
      word.phraseMode = mode;
      word.isPhraseStart = index == start;
      word.isPhraseEnd = index == end - 1;
    }
  }

  static void _consumeHandledCapitalFlags(
    List<WordCapitalizationInfo> words,
    List<bool> capitalFlags,
  ) {
    for (final word in words) {
      if (word.isRomanNumeral ||
          word.allCaps ||
          word.phraseMode != PhraseCapitalizationMode.none) {
        for (var index = word.start; index < word.end; index++) {
          capitalFlags[index] = false;
        }
      }
    }
  }
}
