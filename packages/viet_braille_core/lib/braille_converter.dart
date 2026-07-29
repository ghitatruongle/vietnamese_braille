import 'braille_mapping.dart';
import 'src/capitalization_analysis.dart';
import 'src/text_preprocessor.dart';

/// Chế độ xuất Braille.
enum BrailleConversionMode {
  /// Unicode Braille 6 chấm theo bảng ánh xạ tiếng Việt.
  standard,

  /// Chế độ chẩn đoán có thể chuyển ngược chính xác dấu `?` và `-`.
  ///
  /// Chế độ này dùng một ô 8 chấm làm escape marker nên không được dùng để
  /// tạo BRF hoặc được quảng bá như một phần của chuẩn Braille tiếng Việt.
  lossless,
}

/// Escape marker chỉ dùng trong [BrailleConversionMode.lossless].
const String losslessBrailleEscape = '\u28ff';

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
  String convert(
    String text, {
    BrailleConversionMode mode = BrailleConversionMode.standard,
  });

  /// Convert with full result including unmapped character warnings.
  ConversionResult convertWithDetails(
    String text, {
    BrailleConversionMode mode = BrailleConversionMode.standard,
  });
}

class BrailleConverterImpl implements BrailleConverter {
  final BrailleMapping _mapping;
  static const BrailleTextPreprocessor _preprocessor =
      BrailleTextPreprocessor();
  static const CapitalizationAnalyzer _capitalizationAnalyzer =
      CapitalizationAnalyzer();

  /// Precomputed tone decomposition table for qu/gi rule.
  /// Maps each NFC toned character → (tone Braille cell, base vowel Braille cell).
  /// Khởi tạo qua constructor để dùng [_mapping] đã injected (không tạo instance mới).
  late final Map<String, ({String tone, String baseMapped})>
  _toneDecomposition = _buildToneDecomposition();

  BrailleConverterImpl(this._mapping);

  @override
  String convert(
    String text, {
    BrailleConversionMode mode = BrailleConversionMode.standard,
  }) => convertWithDetails(text, mode: mode).brailleText;

  @override
  ConversionResult convertWithDetails(
    String text, {
    BrailleConversionMode mode = BrailleConversionMode.standard,
  }) {
    if (text.isEmpty) {
      return const ConversionResult(brailleText: '', unmappedCharacters: []);
    }

    // Tiền xử lý văn bản (đơn vị đo, phép toán, chấm lửng)
    text = _preprocessor.preprocess(text);

    // Normalize + theo dõi chữ hoa (xử lý đúng cả NFD input).
    final result = _mapping.normalizeWithCapitals(text);
    final normalized = result.text;
    final capitalFlags = result.capitals;

    final capitalization = _capitalizationAnalyzer.analyze(
      normalized,
      capitalFlags,
    );

    final buffer = StringBuffer();
    final unmapped = <String>[];
    bool inNumber = false;
    bool inQuContext =
        false; // true after q+u, persists across intermediate chars
    bool inGiContext = false;
    int? rhymeStartInBuffer;
    bool hasVowelInSyllable = false;
    String prevCharLower = '';

    void writePhraseEndIfNeeded(int sourceEnd) {
      final wordAtEnd = capitalization.wordsByEnd[sourceEnd];
      if (wordAtEnd != null &&
          wordAtEnd.phraseMode != PhraseCapitalizationMode.none &&
          wordAtEnd.isPhraseEnd) {
        buffer.write(_mapping.endFormat);
      }
    }

    for (int i = 0; i < normalized.length; i++) {
      final ch = normalized[i];

      // Ghi capital indicator cho các trường hợp viết hoa cụm/từ đặc biệt
      final wordAtStart = capitalization.wordsByStart[i];
      if (wordAtStart != null) {
        final w = wordAtStart;
        if (w.isRomanNumeral) {
          buffer.write(
            _mapping.capitalIndicator,
          ); // Số La Mã: 1 dấu báo hoa ở đầu
        } else if (w.phraseMode == PhraseCapitalizationMode.allCaps) {
          if (w.isPhraseStart) {
            buffer.write(_mapping.allCapsPhrase); // Cụm viết hoa toàn bộ: ⠨⠨
          }
        } else if (w.phraseMode == PhraseCapitalizationMode.initialCaps) {
          if (w.isPhraseStart) {
            buffer.write(
              _mapping.initCapsPhrase,
            ); // Cụm viết hoa chữ cái đầu: ⠒⠨
          }
        } else if (w.phraseMode == PhraseCapitalizationMode.none && w.allCaps) {
          buffer.write(_mapping.allCapsWord); // Từ đơn viết hoa toàn bộ: ⠸
        }
      }

      // `?` và `-` dùng cùng ô với thanh hỏi/ngã trong bảng chuẩn. Chế độ
      // lossless thêm escape marker riêng để reverse converter không phải đoán
      // theo ngữ cảnh. Chuỗi này chỉ dùng cho đối chiếu nội bộ, không xuất BRF.
      if (mode == BrailleConversionMode.lossless && (ch == '?' || ch == '-')) {
        inNumber = false;
        buffer
          ..write(losslessBrailleEscape)
          ..write(_mapping.mapChar(ch)!);
        prevCharLower = ch;
        rhymeStartInBuffer = null;
        hasVowelInSyllable = false;
        inQuContext = false;
        inGiContext = false;
        continue;
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
        prevCharLower = '"';
        rhymeStartInBuffer = null;
        hasVowelInSyllable = false;
        inQuContext = false;
        inGiContext = false;
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
        prevCharLower = '.';
        continue;
      }
      if (inNumber &&
          ch == ',' &&
          i + 1 < normalized.length &&
          _isDigit(normalized[i + 1])) {
        buffer.write(_mapping.mapChar(',')!); // phẩy thập phân -> ⠂ (dot 2)
        prevCharLower = ',';
        continue;
      }

      final mapped = _mapping.mapChar(ch);
      if (mapped != null) {
        if (_isDigit(ch)) {
          rhymeStartInBuffer = null;
          hasVowelInSyllable = false;
          inQuContext = false;
          inGiContext = false;
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
          final isVowel = _isVowel(ch) || _isTonedVowel(ch);
          if (!isVowel) {
            rhymeStartInBuffer = null;
            hasVowelInSyllable = false;
          } else if (!hasVowelInSyllable) {
            // Lưu vị trí trước cả capital indicator của nguyên âm đầu. Khi
            // dấu thanh nằm trên nguyên âm sau trong vần (Việt, tuyến, oán),
            // tone được chèn tại đây: sau phụ âm đầu và trước toàn bộ phần vần.
            rhymeStartInBuffer = buffer.length;
            hasVowelInSyllable = true;
          }

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
          if (!inGiContext && ch == 'i' && prevCharLower == 'g') {
            inGiContext = true;
          }
          if (inQuContext && !_isVowel(ch) && !_isTonedVowel(ch)) {
            // Clear qu context when we hit a consonant or non-vowel
            inQuContext = false;
          }
          if (inGiContext && !_isVowel(ch) && !_isTonedVowel(ch)) {
            inGiContext = false;
          }

          // Check qu/gi rule: after q+u or g+i, tone goes AFTER u/i
          // (per Vietnamese Braille standard - Sao Mai Center)
          final isQuMatch = inQuContext && _isTonedVowel(ch);
          final isGiMatch = prevCharLower == 'g' && _isTonedI(ch);
          final isGiRhymeMatch =
              inGiContext && prevCharLower != 'g' && _isTonedVowel(ch);
          if (isQuMatch || isGiMatch || isGiRhymeMatch) {
            final decomposed = _decomposeTonedChar(ch);
            if (decomposed != null) {
              // qu/gi luôn có phụ âm đầu (q/g) → capital trước phụ âm đầu
              if (isCapital) {
                buffer.write(_mapping.capitalIndicator);
              }
              if (isGiMatch || isGiRhymeMatch) {
                // Rule (Section VI): gi + vowel starting with 'i' → g + [tone + i]
                // hoặc gi + vần khác → gi + tone + phần vần.
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
              inGiContext = false;
              prevCharLower = ch;
              writePhraseEndIfNeeded(i + 1);
              continue;
            }
          }

          // Dấu thanh nằm trên nguyên âm sau nhưng phải đứng trước toàn bộ
          // phần vần: oán, Việt, tuyến...
          if (_isTonedVowel(ch) &&
              rhymeStartInBuffer != null &&
              buffer.length > rhymeStartInBuffer) {
            final decomposed = _decomposeTonedChar(ch);
            if (decomposed != null) {
              final text = buffer.toString();
              final insertionIndex = rhymeStartInBuffer;
              buffer.clear();
              buffer.write(text.substring(0, insertionIndex));
              buffer.write(decomposed.tone);
              buffer.write(text.substring(insertionIndex));
              buffer.write(decomposed.baseMapped);
              prevCharLower = ch;
              writePhraseEndIfNeeded(i + 1);
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
              prevCharLower = ch;
              writePhraseEndIfNeeded(i + 1);
              continue;
            }
          }

          // Các trường hợp còn lại: capital trước ký tự (thường hoặc có PA đầu)
          if (isCapital) {
            buffer.write(_mapping.capitalIndicator);
          }

          buffer.write(mapped);
          if ((ch == 'u' && prevCharLower == 'q') ||
              (ch == 'i' && prevCharLower == 'g')) {
            // `u`/`i` thuộc phụ âm đầu qu/gi; dấu thanh đặt sau ô này.
            rhymeStartInBuffer = buffer.length;
          }
        }

        // Ghi ký tự kết thúc định dạng `⠱` cho cụm từ viết hoa
        writePhraseEndIfNeeded(i + 1);
      } else {
        // Track unmapped characters (skip whitespace as it's always valid)
        if (ch.trim().isNotEmpty) {
          unmapped.add(ch);
        }
      }

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
