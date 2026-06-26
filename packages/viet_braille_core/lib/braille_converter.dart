import 'braille_mapping.dart';

/// Kết quả chuyển đổi Braille, bao gồm cả cảnh báo ký tự không hợp lệ.
class ConversionResult {
  const ConversionResult({
    required this.brailleText,
    required this.unmappedCharacters,
  });

  final String brailleText;
  final List<String> unmappedCharacters;

  bool get hasWarnings => unmappedCharacters.isNotEmpty;

  /// Tạo thông báo cảnh báo nếu có ký tự không ánh xạ được.
  String? get warningMessage {
    if (!hasWarnings) return null;
    final unique = unmappedCharacters.toSet().toList();
    return 'Các ký tự không có trong bảng Braille: ${unique.join(", ")}';
  }
}

abstract class BrailleConverter {
  String convert(String text);

  /// Convert with full result including unmapped character warnings.
  ConversionResult convertWithDetails(String text);
}

class BrailleConverterImpl implements BrailleConverter {
  final BrailleMapping _mapping;

  /// Precomputed tone decomposition table for qu/gi rule.
  /// Maps each NFC toned character → (tone Braille cell, base vowel Braille cell).
  /// Khởi tạo qua constructor để dùng [_mapping] đã injected (không tạo instance mới).
  late final Map<String, ({String tone, String baseMapped})>
  _toneDecomposition = _buildToneDecomposition();

  BrailleConverterImpl(this._mapping);

  @override
  String convert(String text) => convertWithDetails(text).brailleText;

  /// Bộ tiền xử lý văn bản đầu vào theo quy chuẩn định dạng và khoảng trống của Thông tư 15.
  String _preprocessText(String text) {
    // 1. Chèn khoảng trắng trước các đơn vị đo khi viết liền sau số
    final unitRegex = RegExp(
      r'(\d)(km|hm|dam|dm|cm|mm|kg|hg|dag|g|tấn|tạ|yến)(?=\b|[^a-zA-Z0-9àáảãạâầấẩẫậăằắẳẵặèéẻẽẹêềếểễệìíỉĩịòóỏõọôồốổỗộơờớởỡợùúủũụưừứửữựỳýỷỹỵđÀÁẢÃẠÂẦẤẨẪẬĂẰẮẲẴẶÈÉẺẼẸÊỀẾỂỄỆÌÍỈĩỊÒÓỎÕỌÔỒỐỔỖỘƠỜỚỞỠỢÙÚỦŨỤƯỪỨỬỮỰỲÝỶỸỸĐ])',
    );
    text = text.replaceAllMapped(
      unitRegex,
      (match) => '${match.group(1)} ${match.group(2)}',
    );

    // 2. Xóa khoảng trắng xung quanh các ký hiệu phép toán và quan hệ khi đi kèm số
    final opRegex = RegExp(r'(\d)\s*([\+\-\*\/x\:=\<\>≈≤≥])\s*(\d)');
    String prev = '';
    while (text != prev) {
      prev = text;
      text = text.replaceAllMapped(
        opRegex,
        (match) => '${match.group(1)}${match.group(2)}${match.group(3)}',
      );
    }

    // 3. Thay thế dấu chấm lửng "..." thành ký tự "…" để ánh xạ ra "⠄⠄⠄" (3 ô chấm 3)
    text = text.replaceAll('...', '…');
    return text;
  }

  @override
  ConversionResult convertWithDetails(String text) {
    if (text.isEmpty) {
      return const ConversionResult(brailleText: '', unmappedCharacters: []);
    }

    // Tiền xử lý văn bản (đơn vị đo, phép toán, chấm lửng)
    text = _preprocessText(text);

    // Normalize + theo dõi chữ hoa (xử lý đúng cả NFD input).
    final result = _mapping.normalizeWithCapitals(text);
    final normalized = result.text;
    final capitalFlags = result.capitals;

    // Phân tích các từ để xử lý quy tắc viết hoa cụm từ/chữ và số La Mã
    final wordRegex = RegExp(
      r'[a-zàáảãạâầấẩẫậăằắẳẵặèéẻẽẹêềếểễệìíỉĩịòóỏõọôồốổỗộơờớởỡợùúủũụưừứửữựỳýỷỹỵđ]+',
    );
    final words = <_WordInfo>[];
    for (final match in wordRegex.allMatches(normalized)) {
      final start = match.start;
      final end = match.end;
      final wordText = normalized.substring(start, end);

      bool allCaps = (end - start > 1);
      bool initCaps = false;
      if (end > start) {
        initCaps = capitalFlags[start];
        for (int j = start; j < end; j++) {
          if (!capitalFlags[j]) {
            allCaps = false;
          }
          if (j > start && capitalFlags[j]) {
            initCaps = false;
          }
        }
      } else {
        allCaps = false;
      }

      // Số La Mã viết hoa trong text gốc
      final isRoman = allCaps && RegExp(r'^[ivxlcdm]+$').hasMatch(wordText);

      words.add(
        _WordInfo(
          start: start,
          end: end,
          text: wordText,
          allCaps: allCaps,
          initCaps: initCaps,
          isRoman: isRoman,
        ),
      );
    }

    // Nhóm các từ viết hoa thành cụm từ (All-caps phrases và Init-caps phrases)
    int idxWord = 0;
    while (idxWord < words.length) {
      if (words[idxWord].isRoman) {
        idxWord++;
        continue;
      }
      if (words[idxWord].allCaps) {
        int j = idxWord + 1;
        while (j < words.length) {
          if (words[j].isRoman || !words[j].allCaps) break;
          final sep = normalized.substring(words[j - 1].end, words[j].start);
          if (sep.trim().isNotEmpty || sep.isEmpty) {
            break; // chỉ cho phép ngăn cách bằng khoảng trắng
          }
          j++;
        }
        if (j > idxWord + 1) {
          for (int k = idxWord; k < j; k++) {
            words[k].phraseMode = _PhraseMode.allCaps;
            words[k].isPhraseStart = (k == idxWord);
            words[k].isPhraseEnd = (k == j - 1);
          }
          idxWord = j;
          continue;
        }
      }
      idxWord++;
    }

    idxWord = 0;
    while (idxWord < words.length) {
      if (words[idxWord].phraseMode != _PhraseMode.none) {
        idxWord++;
        continue;
      }
      if (words[idxWord].initCaps) {
        int j = idxWord + 1;
        while (j < words.length) {
          if (words[j].phraseMode != _PhraseMode.none || !words[j].initCaps) {
            break;
          }
          final sep = normalized.substring(words[j - 1].end, words[j].start);
          if (sep.trim().isNotEmpty || sep.isEmpty) break;
          j++;
        }
        if (j > idxWord + 1) {
          for (int k = idxWord; k < j; k++) {
            words[k].phraseMode = _PhraseMode.initCaps;
            words[k].isPhraseStart = (k == idxWord);
            words[k].isPhraseEnd = (k == j - 1);
          }
          idxWord = j;
          continue;
        }
      }
      idxWord++;
    }

    // Xóa cờ viết hoa của các ký tự nằm trong các từ đã được xử lý viết hoa theo cụm/từ/La Mã
    // để tránh in ra capital indicator ở từng chữ cái lẻ.
    for (final w in words) {
      if (w.isRoman || w.allCaps || w.phraseMode != _PhraseMode.none) {
        for (int j = w.start; j < w.end; j++) {
          capitalFlags[j] = false;
        }
      }
    }

    final buffer = StringBuffer();
    final unmapped = <String>[];
    bool inNumber = false;
    bool inQuContext =
        false; // true after q+u, persists across intermediate chars
    String prevCharLower = '';
    String prevPrevCharLower = '';

    for (int i = 0; i < normalized.length; i++) {
      final ch = normalized[i];

      // Ghi capital indicator cho các trường hợp viết hoa cụm/từ đặc biệt
      final wordStartIdx = words.indexWhere((w) => w.start == i);
      if (wordStartIdx >= 0) {
        final w = words[wordStartIdx];
        if (w.isRoman) {
          buffer.write(
            _mapping.capitalIndicator,
          ); // Số La Mã: 1 dấu báo hoa ở đầu
        } else if (w.phraseMode == _PhraseMode.allCaps) {
          if (w.isPhraseStart) {
            buffer.write(_mapping.allCapsPhrase); // Cụm viết hoa toàn bộ: ⠨⠨
          }
        } else if (w.phraseMode == _PhraseMode.initCaps) {
          if (w.isPhraseStart) {
            buffer.write(
              _mapping.initCapsPhrase,
            ); // Cụm viết hoa chữ cái đầu: ⠒⠨
          }
        } else if (w.phraseMode == _PhraseMode.none && w.allCaps) {
          buffer.write(_mapping.allCapsWord); // Từ đơn viết hoa toàn bộ: ⠸
        }
      }

      // Handle double-quote: open vs close based on context
      if (ch == '"') {
        inNumber = false;
        final isAfterSpace =
            i == 0 ||
            normalized[i - 1] == ' ' ||
            normalized[i - 1] == '\n' ||
            normalized[i - 1] == '\t' ||
            normalized[i - 1] == '\r';
        if (isAfterSpace) {
          buffer.write(_mapping.mapChar('"')!); // open quote
        } else {
          buffer.write(_mapping.dquoteClose); // close quote
        }
        prevPrevCharLower = prevCharLower;
        prevCharLower = '"';
        continue;
      }

      // Handle combining diacritical marks (NFD tone marks U+0300-U+036F)
      // In Vietnamese Braille, tone cell goes BEFORE the vowel.
      // NFD puts combining mark AFTER base char, so we insert the tone
      // cell before the already-written base character cell.
      if (ch.codeUnitAt(0) >= 0x0300 && ch.codeUnitAt(0) <= 0x036F) {
        final toneCell = _nfdToneMap[ch.codeUnitAt(0)];
        if (toneCell != null && buffer.isNotEmpty) {
          final text = buffer.toString();
          // gi-context: buffer ends with g+i, tone goes AFTER i
          if (text.length >= 2 &&
              text[text.length - 1] == _mapping.mapChar('i') &&
              text[text.length - 2] == _mapping.mapChar('g')) {
            buffer.write(toneCell);
          } else {
            buffer.clear();
            // Last cell is always a single BMP Braille character (1 code unit)
            buffer.write(text.substring(0, text.length - 1));
            buffer.write(toneCell);
            buffer.write(text[text.length - 1]);
          }
        }
        // Skip unknown combining marks
        continue;
      }

      // Dấu phân cách hàng nghìn (chấm `.`) và thập phân (phẩy `,`) trong Number Mode
      if (inNumber &&
          ch == '.' &&
          i + 1 < normalized.length &&
          _isDigit(normalized[i + 1])) {
        buffer.write(_mapping.mapChar("'")!); // chấm hàng nghìn -> ⠄ (dot 3)
        prevPrevCharLower = prevCharLower;
        prevCharLower = '.';
        continue;
      }
      if (inNumber &&
          ch == ',' &&
          i + 1 < normalized.length &&
          _isDigit(normalized[i + 1])) {
        buffer.write(_mapping.mapChar(',')!); // phẩy thập phân -> ⠂ (dot 2)
        prevPrevCharLower = prevCharLower;
        prevCharLower = ',';
        continue;
      }

      final mapped = _mapping.mapChar(ch);
      if (mapped != null) {
        if (_isDigit(ch)) {
          if (!inNumber) {
            buffer.write(_mapping.numberIndicator);
            inNumber = true;
          }
          // Chữ số viết hoa: capital trước số
          if (capitalFlags[i]) {
            buffer.write(_mapping.capitalIndicator);
          }
          buffer.write(mapped);
        } else {
          inNumber = false;

          // ── Xử lý capital indicator theo chuẩn Braille Việt Nam ──
          // Quy tắc (theo ảnh 7 / file txt mục VII):
          //   Có phụ âm đầu: capital → consonant → tone → vowel
          //   KHÔNG phụ âm đầu (VD: Ấ, Ẩn): tone → capital → vowel
          final isCapital = capitalFlags[i];
          final hasConsonantBefore =
              prevCharLower.isNotEmpty && _isConsonant(prevCharLower);

          // ── Track qu context: after q+u, set flag for multi-char rhymes ──
          // Handles cases like "quyết" = q + u + sac + y + ê + t
          // where the toned vowel 'ế' is not immediately after 'u'.
          if (!inQuContext && ch == 'u' && prevCharLower == 'q') {
            inQuContext = true;
          }
          if (inQuContext && !_isVowel(ch) && !_isTonedVowel(ch)) {
            // Clear qu context when we hit a consonant or non-vowel
            inQuContext = false;
          }

          // Check qu/gi rule: after q+u or g+i, tone goes AFTER u/i
          // (per Vietnamese Braille standard - Sao Mai Center)
          final isQuMatch = inQuContext && _isTonedVowel(ch);
          final isGiMatch = prevCharLower == 'g' && _isTonedI(ch);
          if (isQuMatch || isGiMatch) {
            final decomposed = _decomposeTonedChar(ch);
            if (decomposed != null) {
              // qu/gi luôn có phụ âm đầu (q/g) → capital trước phụ âm đầu
              if (isCapital) {
                buffer.write(_mapping.capitalIndicator);
              }
              if (isGiMatch) {
                // Rule (Section VI): gi + vowel starting with 'i' → g + [tone + i]
                // "g trước, sau đó đến dấu thanh, cuối cùng là phần vần"
                buffer.write(decomposed.tone + decomposed.baseMapped);
              } else {
                // qu: q + u + [tone + nextVowel(s)] — tone before all
                // intermediate vowels (handles "quyết" = q+u+sac+y+ê+t)
                final uCell = _mapping.mapChar('u')!;
                final buf = buffer.toString();
                final uIdx = buf.lastIndexOf(uCell);
                if (uIdx >= 0 && uIdx < buf.length - 1) {
                  // There are chars after 'u' already written.
                  // Insert tone between 'u' and those chars.
                  final before = buf.substring(0, uIdx + 1);
                  final after = buf.substring(uIdx + 1);
                  buffer.clear();
                  buffer.write(before);
                  buffer.write(decomposed.tone);
                  buffer.write(after);
                  buffer.write(decomposed.baseMapped);
                } else {
                  // No intermediate chars — standard qu rule
                  buffer.write(decomposed.tone + decomposed.baseMapped);
                }
              }
              inQuContext = false; // tone placed, reset qu context
              prevPrevCharLower = prevCharLower;
              prevCharLower = ch;
              continue;
            }
          }

          // ── Initial vowel with tone (no consonant) ──
          // Rule (Section VI): "Một chữ chỉ có phần vần và dấu thanh
          // thì kí hiệu dấu thanh được đặt trước phần vần."
          // If current char is a toned vowel and previous char is a plain
          // vowel from the same syllable, move tone before the first vowel.
          // But NOT if previous vowel is part of gi/qu cluster (giải, quả).
          if (!isCapital &&
              _isTonedVowel(ch) &&
              !hasConsonantBefore &&
              prevCharLower.isNotEmpty &&
              _isVowel(prevCharLower) &&
              !_isConsonant(prevCharLower) &&
              !(prevPrevCharLower.isNotEmpty &&
                  _isConsonant(prevPrevCharLower))) {
            final decomposed = _decomposeTonedChar(ch);
            if (decomposed != null && buffer.isNotEmpty) {
              // Previous char was a vowel written to buffer; the tone from
              // current char should go before it.
              // Rewrite: ... + tone + prevVowel + baseMapped + rest
              // Instead of: ... + prevVowel + tone + baseMapped
              final text = buffer.toString();
              final prevCell = text[text.length - 1]; // last Braille cell
              buffer.clear();
              buffer.write(text.substring(0, text.length - 1));
              buffer.write(decomposed.tone + prevCell + decomposed.baseMapped);
              prevPrevCharLower = prevCharLower;
              prevCharLower = ch;
              continue;
            }
          }

          // Nguyên âm có dấu, KHÔNG có phụ âm đầu → tone → capital → base
          // Theo chuẩn: bác Ẩn = b-á-c [space] hỏi-capital-â-n
          if (isCapital && !hasConsonantBefore && _isTonedVowel(ch)) {
            final decomposed = _decomposeTonedChar(ch);
            if (decomposed != null) {
              // tone → capital → base vowel (không có phụ âm đầu)
              buffer.write(decomposed.tone);
              buffer.write(_mapping.capitalIndicator);
              buffer.write(decomposed.baseMapped);
              prevPrevCharLower = prevCharLower;
              prevCharLower = ch;
              continue;
            }
          }

          // Các trường hợp còn lại: capital trước ký tự (thường hoặc có PA đầu)
          if (isCapital) {
            buffer.write(_mapping.capitalIndicator);
          }

          buffer.write(mapped);
        }

        // Ghi ký tự kết thúc định dạng `⠱` cho cụm từ viết hoa
        final wordEndIdx = words.indexWhere((w) => w.end == i + 1);
        if (wordEndIdx >= 0) {
          final w = words[wordEndIdx];
          if (w.phraseMode != _PhraseMode.none && w.isPhraseEnd) {
            buffer.write(_mapping.endFormat); // Ghi dấu kết thúc: ⠱
          }
        }
      } else {
        // Track unmapped characters (skip whitespace as it's always valid)
        if (ch.trim().isNotEmpty) {
          unmapped.add(ch);
        }
      }

      prevPrevCharLower = prevCharLower;
      prevCharLower = ch.toLowerCase();
    }

    return ConversionResult(
      brailleText: buffer.toString(),
      unmappedCharacters: unmapped,
    );
  }

  /// Check if a character is a toned 'i' (í, ì, ỉ, ĩ, ị).
  static bool _isTonedI(String ch) => 'íìỉĩị'.contains(ch);

  /// Check if a character is a Vietnamese toned vowel (not a plain letter).
  bool _isTonedVowel(String ch) {
    return _toneDecomposition.containsKey(ch);
  }

  /// Kiểm tra ký tự có phải phụ âm đầu (consonant) trong tiếng Việt.
  /// Bao gồm cả Latin consonants và 'đ'.
  /// Dùng để xác định thứ tự capital indicator theo chuẩn Braille Việt Nam:
  /// - Có phụ âm đầu → capital trước consonant
  /// - Không có phụ âm đầu (standalone vowel) → tone → capital → vowel
  static bool _isConsonant(String ch) {
    return 'bcdfghjklmnpqrstvxđ'.contains(ch);
  }

  /// Kiểm tra ký tự có phải nguyên âm tiếng Việt (không dấu).
  static bool _isVowel(String ch) {
    return 'aeiouyăâêôơư'.contains(ch);
  }

  /// Decompose a toned vowel into its tone cell and base vowel mapping.
  /// Returns null if the character is not a toned vowel.
  ({String tone, String baseMapped})? _decomposeTonedChar(String ch) {
    return _toneDecomposition[ch];
  }

  static bool _isDigit(String ch) =>
      ch.length == 1 && ch.codeUnitAt(0) >= 0x30 && ch.codeUnitAt(0) <= 0x39;

  /// NFD combining diacritical marks → Braille tone cells
  static const Map<int, String> _nfdToneMap = {
    0x0301: '\u2814', // sắc (dots 3,5)
    0x0300: '\u2830', // huyền (dots 5,6)
    0x0309: '\u2822', // hỏi (dots 2,6)
    0x0303: '\u2824', // ngã (dots 3,6)
    0x0323: '\u2820', // nặng (dot 6)
  };

  /// Xây dựng bảng phân tách tone cho quy tắc qu/gi, dùng [_mapping] đã injected.
  /// Trước đây method này tạo `BrailleMappingImpl()` mới — vi phạm dependency injection.
  Map<String, ({String tone, String baseMapped})> _buildToneDecomposition() {
    final map = <String, ({String tone, String baseMapped})>{};
    // Tone Braille cells — lấy từ _mapping thay vì hardcode
    final toneSac = _mapping.mapChar('á');
    final toneHuyen = _mapping.mapChar('à');
    final toneHoi = _mapping.mapChar('ả');
    final toneNga = _mapping.mapChar('ã');
    final toneNang = _mapping.mapChar('ạ');

    if (toneSac == null ||
        toneHuyen == null ||
        toneHoi == null ||
        toneNga == null ||
        toneNang == null) {
      return map; // Fallback: không xây được nếu mapping thiếu tone
    }

    // Lấy tone cell prefix (ký tự đầu tiên của mapped tone — single cell)
    // Vì tone cells được mapping dưới dạng "toneCell + baseVowelCell",
    // ta cần extract chỉ phần tone cell.
    // Các tone cells luôn là 1 ô Braille (1 code unit) ở trước base vowel.
    // Từ _nfdToneMap ta đã biết chính xác Unicode của mỗi tone cell.
    final toneCells = [
      (
        _nfdToneMap[0x0301]!, // sắc dots 3,5
        {
          'a': 'á',
          'e': 'é',
          'i': 'í',
          'o': 'ó',
          'u': 'ú',
          'y': 'ý',
          'ă': 'ắ',
          'â': 'ấ',
          'ê': 'ế',
          'ô': 'ố',
          'ơ': 'ớ',
          'ư': 'ứ',
        },
      ),
      (
        _nfdToneMap[0x0300]!, // huyền dots 5,6
        {
          'a': 'à',
          'e': 'è',
          'i': 'ì',
          'o': 'ò',
          'u': 'ù',
          'y': 'ỳ',
          'ă': 'ằ',
          'â': 'ầ',
          'ê': 'ề',
          'ô': 'ồ',
          'ơ': 'ờ',
          'ư': 'ừ',
        },
      ),
      (
        _nfdToneMap[0x0309]!, // hỏi dots 2,6
        {
          'a': 'ả',
          'e': 'ẻ',
          'i': 'ỉ',
          'o': 'ỏ',
          'u': 'ủ',
          'y': 'ỷ',
          'ă': 'ẳ',
          'â': 'ẩ',
          'ê': 'ể',
          'ô': 'ổ',
          'ơ': 'ở',
          'ư': 'ử',
        },
      ),
      (
        _nfdToneMap[0x0303]!, // ngã dots 3,6
        {
          'a': 'ã',
          'e': 'ẽ',
          'i': 'ĩ',
          'o': 'õ',
          'u': 'ũ',
          'y': 'ỹ',
          'ă': 'ẵ',
          'â': 'ẫ',
          'ê': 'ễ',
          'ô': 'ỗ',
          'ơ': 'ỡ',
          'ư': 'ữ',
        },
      ),
      (
        _nfdToneMap[0x0323]!, // nặng dot 6
        {
          'a': 'ạ',
          'e': 'ẹ',
          'i': 'ị',
          'o': 'ọ',
          'u': 'ụ',
          'y': 'ỵ',
          'ă': 'ặ',
          'â': 'ậ',
          'ê': 'ệ',
          'ô': 'ộ',
          'ơ': 'ợ',
          'ư': 'ự',
        },
      ),
    ];
    for (final (toneCell, charMap) in toneCells) {
      for (final entry in charMap.entries) {
        final baseBraille = _mapping.mapChar(entry.key);
        if (baseBraille != null) {
          map[entry.value] = (tone: toneCell, baseMapped: baseBraille);
        }
      }
    }
    return map;
  }
}

enum _PhraseMode { none, allCaps, initCaps }

class _WordInfo {
  final int start;
  final int end;
  final String text;
  final bool allCaps;
  final bool initCaps;
  final bool isRoman;
  _PhraseMode phraseMode = _PhraseMode.none;
  bool isPhraseStart = false;
  bool isPhraseEnd = false;

  _WordInfo({
    required this.start,
    required this.end,
    required this.text,
    required this.allCaps,
    required this.initCaps,
    required this.isRoman,
  });
}
