import 'braille_dots.dart';

/// Bảng mapping Braille tiếng Việt.
///
/// Ánh xạ từ ký tự Unicode (NFC, lowercase) sang chuỗi Braille Unicode
/// theo chuẩn U+2800 - U+28FF (8-dot Braille).
///
/// Dấu thanh là ô Braille riêng biệt đặt TRƯỚC nguyên âm.
/// Chữ số có tiền tố number-indicator (⠼).
abstract class BrailleMapping {
  /// Chuẩn hóa text: lowercase + compose NFD combining marks → NFC.
  String normalize(String text);

  /// Normalize text và theo dõi chữ hoa cho từng ký tự kết quả.
  ({String text, List<bool> capitals}) normalizeWithCapitals(String text);

  /// Tra cứu ký tự NFC → chuỗi Braille Unicode, hoặc null nếu không có.
  String? mapChar(String char);

  /// Ký tự capital indicator (đặt trước chữ cái viết hoa).
  String get capitalIndicator;

  /// Ký tự number indicator (đặt trước chuỗi chữ số).
  String get numberIndicator;

  /// Kiểm tra ký tự có phải chữ cái viết hoa không.
  bool isUpperCase(String char);

  /// Reverse map: Braille Unicode cell → ký tự text (lowercase).
  String? reverseMapChar(String brailleCell);

  /// Reverse map chữ số trong number mode: Braille cell → digit character.
  String? reverseMapDigit(String brailleCell);

  /// Reverse map cho nguyên âm tiếng Việt: Braille cell → base vowel.
  String? reverseMapVowel(String brailleCell);

  /// Prefix cell cho dấu câu đặc biệt (dot 4).
  String get symbolPrefix;

  /// Prefix cell cho ký hiệu toán học (dot 5).
  String get mathPrefix;

  /// Prefix cell cho ký hiệu đặc biệt (dots 4,5,6).
  String get specialPrefix;

  /// Prefix cell cho ngoặc vuông (dots 4,6).
  String get bracketPrefix;

  /// Braille string cho dấu đóng ngoặc kép (dots 3,5,6).
  String get dquoteClose;

  /// Dấu báo viết hoa tất cả các chữ cái trong 1 từ (dot 4,5,6)
  String get allCapsWord;

  /// Dấu báo viết hoa tất cả các chữ cái trong cụm từ/câu/đoạn (dots 4,6 + 4,6)
  String get allCapsPhrase;

  /// Dấu báo viết hoa chữ cái đầu của các chữ trong cụm từ/câu/đoạn (dots 2,5 + 4,6)
  String get initCapsPhrase;

  /// Ký hiệu kết thúc định dạng/từ/câu/đoạn (dots 1,5,6)
  String get endFormat;

  /// Compose NFD text to NFC (for reverse converter output).
  String composeNfc(String text);
}

class BrailleMappingImpl implements BrailleMapping {
  // Dot bitmasks được ủy quyền cho BrailleDots chia sẻ để tránh trùng lặp
  // giữa BrailleMappingImpl và BrailleReverseConverterImpl.
  static const int _d1 = BrailleDots.d1;
  static const int _d2 = BrailleDots.d2;
  static const int _d3 = BrailleDots.d3;
  static const int _d4 = BrailleDots.d4;
  static const int _d5 = BrailleDots.d5;
  static const int _d6 = BrailleDots.d6;

  /// Tạo ký tự Braille Unicode từ bitmask dots (ủy thác cho BrailleDots).
  static String _cell(int dots) => BrailleDots.cell(dots);

  // ──────────────────── Tone cells (đặt trước nguyên âm) ───────────────
  static final String _toneSac = _cell(_d3 | _d5); // sắc: dots 3,5 → U+2814
  static final String _toneHuyen = _cell(_d5 | _d6); // huyền: dots 5,6 → U+2830
  static final String _toneHoi = _cell(_d2 | _d6); // hỏi: dots 2,6 → U+2822
  static final String _toneNga = _cell(_d3 | _d6); // ngã: dots 3,6 → U+2824
  static final String _toneNang = _cell(_d6); // nặng: dot 6 → U+2820

  // ──────────────────── Basic Latin cells (6-dot Braille) ──────────────
  static final String _a = _cell(_d1);
  static final String _b = _cell(_d1 | _d2);
  static final String _c = _cell(_d1 | _d4);
  static final String _d = _cell(_d1 | _d4 | _d5);
  static final String _e = _cell(_d1 | _d5);
  static final String _f = _cell(_d1 | _d2 | _d4);
  static final String _g = _cell(_d1 | _d2 | _d4 | _d5);
  static final String _h = _cell(_d1 | _d2 | _d5);
  static final String _i = _cell(_d2 | _d4);
  static final String _j = _cell(_d2 | _d4 | _d5);
  static final String _k = _cell(_d1 | _d3);
  static final String _l = _cell(_d1 | _d2 | _d3);
  static final String _m = _cell(_d1 | _d3 | _d4);
  static final String _n = _cell(_d1 | _d3 | _d4 | _d5);
  static final String _o = _cell(_d1 | _d3 | _d5);
  static final String _p = _cell(_d1 | _d2 | _d3 | _d4);
  static final String _q = _cell(_d1 | _d2 | _d3 | _d4 | _d5);
  static final String _r = _cell(_d1 | _d2 | _d3 | _d5);
  static final String _s = _cell(_d2 | _d3 | _d4);
  static final String _t = _cell(_d2 | _d3 | _d4 | _d5);
  static final String _u = _cell(_d1 | _d3 | _d6);
  static final String _v = _cell(_d1 | _d2 | _d3 | _d6);
  static final String _w = _cell(_d2 | _d4 | _d5 | _d6);
  static final String _x = _cell(_d1 | _d3 | _d4 | _d6);
  static final String _y = _cell(_d1 | _d3 | _d4 | _d5 | _d6);
  static final String _z = _cell(_d1 | _d3 | _d5 | _d6);

  // ──────────────────── Vietnamese special vowels (6-dot Braille) ──────
  static final String _aw = _cell(_d3 | _d4 | _d5); // ă: dots 3,4,5 → U+281C
  static final String _aa = _cell(_d1 | _d6); // â: dots 1,6 → U+2821
  static final String _ee = _cell(_d1 | _d2 | _d6); // ê: dots 1,2,6 → U+2823
  static final String _oo = _cell(
    _d1 | _d4 | _d5 | _d6,
  ); // ô: dots 1,4,5,6 → U+2839
  static final String _ow = _cell(_d2 | _d4 | _d6); // ơ: dots 2,4,6 → U+282A
  static final String _uw = _cell(
    _d1 | _d2 | _d5 | _d6,
  ); // ư: dots 1,2,5,6 → U+2833
  static final String _dj = _cell(
    _d2 | _d3 | _d4 | _d6,
  ); // đ: dots 2,3,4,6 → U+282E

  // ──────────────────── Number indicator ───────────────────────────────
  static final String _num = _cell(_d3 | _d4 | _d5 | _d6);

  // ──────────────────── Capital indicator ─────────────────────────────
  static final String _capital = _cell(
    _d4 | _d6,
  ); // dots 4,6 → U+2828 (báo hoa ký tự)

  // ──────────────────── Punctuation ────────────────────────────────────
  static final String _comma = _cell(_d2);
  static final String _period = _cell(_d2 | _d5 | _d6);
  // Question mark: dots 2,6 (⠢) under Decree 15
  static final String _question = _cell(_d2 | _d6);
  static final String _exclaim = _cell(_d2 | _d3 | _d5);
  static final String _colon = _cell(_d2 | _d5);
  static final String _semicolon = _cell(_d2 | _d3);
  static final String _squote = _cell(_d3);
  static final String _dquoteOpen = _cell(
    _d2 | _d3 | _d6,
  ); // mở ngoặc kép: dots 2,3,6
  static final String _dquoteClose = _cell(
    _d3 | _d5 | _d6,
  ); // đóng ngoặc kép: dots 3,5,6
  // Dash: dots 3,6 (⠤) under Decree 15
  static final String _dash = _cell(_d3 | _d6);

  // ──────────────────── Prefix cells (cho multi-cell symbols) ─────────
  static final String _symbolPrefix = _cell(_d4); // dot 4 → U+2808
  static final String _mathPrefix = _cell(_d5); // dot 5 → U+2810

  // ──────────────────── Multi-cell punctuation ─────────────────────────
  static final String _lparen =
      _symbolPrefix + _cell(_d1 | _d2 | _d6); // ( : 4 + 1,2,6
  static final String _rparen =
      _symbolPrefix + _cell(_d3 | _d4 | _d5); // ) : 4 + 3,4,5
  // Slash: dots 3,4 (⠌) under Decree 15
  static final String _slash = _cell(_d3 | _d4);
  static final String _underscore =
      _symbolPrefix + _cell(_d4 | _d5 | _d6); // _ : 4 + 4,5,6
  // Backslash: dots 4 + 1,6 (⠈⠡) under Decree 15
  static final String _backslash = _symbolPrefix + _cell(_d1 | _d6);
  // Ampersand: dots 1,2,3,4,6 (⠯) under Decree 15
  static final String _ampersand = _cell(_d1 | _d2 | _d3 | _d4 | _d6);

  // ──────────────────── Math symbols (prefix dot 5 + base) ─────────────
  static final String _plus =
      _mathPrefix + _cell(_d2 | _d3 | _d5); // + : 5 + 2,3,5
  static final String _equal =
      _mathPrefix + _cell(_d2 | _d3 | _d5 | _d6); // = : 5 + 2,3,5,6
  // Star/Asterisk: dots 2,3,6 (⠦) under Decree 15
  static final String _star = _cell(_d2 | _d3 | _d6);
  static final String _lt =
      _mathPrefix + _cell(_d2 | _d4 | _d6); // < : 5 + 2,4,6
  static final String _gt =
      _mathPrefix + _cell(_d1 | _d3 | _d5); // > : 5 + 1,3,5

  // ──────────────────── Capitalization constants under Decree 15 ──────
  static final String _allCapsWord = _cell(_d4 | _d5 | _d6); // ⠸ (dots 4,5,6)
  static final String _allCapsPhrase =
      _cell(_d4 | _d6) + _cell(_d4 | _d6); // ⠨⠨ (dots 4,6 + 4,6)
  static final String _initCapsPhrase =
      _cell(_d2 | _d5) + _cell(_d4 | _d6); // ⠒⠨ (dots 2,5 + 4,6)
  static final String _endFormat = _cell(_d1 | _d5 | _d6); // ⠱ (dots 1,5,6)

  // ──────────────────── Complete character → Braille map ───────────────
  static final Map<String, String> _charMap = {
    // ── Latin ──
    'a': _a, 'b': _b, 'c': _c, 'd': _d, 'e': _e, 'f': _f,
    'g': _g, 'h': _h, 'i': _i, 'j': _j, 'k': _k, 'l': _l,
    'm': _m, 'n': _n, 'o': _o, 'p': _p, 'q': _q, 'r': _r,
    's': _s, 't': _t, 'u': _u, 'v': _v, 'w': _w, 'x': _x,
    'y': _y, 'z': _z,

    // ── Vietnamese vowels (no tone) ──
    'ă': _aw, 'â': _aa, 'ê': _ee, 'ô': _oo,
    'ơ': _ow, 'ư': _uw, 'đ': _dj,

    // ── a + tone ──
    'á': _toneSac + _a, 'à': _toneHuyen + _a, 'ả': _toneHoi + _a,
    'ã': _toneNga + _a, 'ạ': _toneNang + _a,

    // ── ă + tone ──
    'ắ': _toneSac + _aw, 'ằ': _toneHuyen + _aw, 'ẳ': _toneHoi + _aw,
    'ẵ': _toneNga + _aw, 'ặ': _toneNang + _aw,

    // ── â + tone ──
    'ấ': _toneSac + _aa, 'ầ': _toneHuyen + _aa, 'ẩ': _toneHoi + _aa,
    'ẫ': _toneNga + _aa, 'ậ': _toneNang + _aa,

    // ── e + tone ──
    'é': _toneSac + _e, 'è': _toneHuyen + _e, 'ẻ': _toneHoi + _e,
    'ẽ': _toneNga + _e, 'ẹ': _toneNang + _e,

    // ── ê + tone ──
    'ế': _toneSac + _ee, 'ề': _toneHuyen + _ee, 'ể': _toneHoi + _ee,
    'ễ': _toneNga + _ee, 'ệ': _toneNang + _ee,

    // ── i + tone ──
    'í': _toneSac + _i, 'ì': _toneHuyen + _i, 'ỉ': _toneHoi + _i,
    'ĩ': _toneNga + _i, 'ị': _toneNang + _i,

    // ── o + tone ──
    'ó': _toneSac + _o, 'ò': _toneHuyen + _o, 'ỏ': _toneHoi + _o,
    'õ': _toneNga + _o, 'ọ': _toneNang + _o,

    // ── ô + tone ──
    'ố': _toneSac + _oo, 'ồ': _toneHuyen + _oo, 'ổ': _toneHoi + _oo,
    'ỗ': _toneNga + _oo, 'ộ': _toneNang + _oo,

    // ── ơ + tone ──
    'ớ': _toneSac + _ow, 'ờ': _toneHuyen + _ow, 'ở': _toneHoi + _ow,
    'ỡ': _toneNga + _ow, 'ợ': _toneNang + _ow,

    // ── u + tone ──
    'ú': _toneSac + _u, 'ù': _toneHuyen + _u, 'ủ': _toneHoi + _u,
    'ũ': _toneNga + _u, 'ụ': _toneNang + _u,

    // ── ư + tone ──
    'ứ': _toneSac + _uw, 'ừ': _toneHuyen + _uw, 'ử': _toneHoi + _uw,
    'ữ': _toneNga + _uw, 'ự': _toneNang + _uw,

    // ── y + tone ──
    'ý': _toneSac + _y, 'ỳ': _toneHuyen + _y, 'ỷ': _toneHoi + _y,
    'ỹ': _toneNga + _y, 'ỵ': _toneNang + _y,

    // ── Digits (chỉ letter cell; number indicator do converter thêm) ──
    '1': _a, '2': _b, '3': _c, '4': _d,
    '5': _e, '6': _f, '7': _g, '8': _h,
    '9': _i, '0': _j,

    // ── Special characters ──
    '_': _underscore,
    '#':
        _cell(_d4 | _d5 | _d6) +
        _cell(_d3 | _d4 | _d5 | _d6), // #: 4,5,6 + 3,4,5,6
    // ── Punctuation ──
    ',': _comma, '.': _period, '?': _question, '!': _exclaim,
    '…':
        _cell(_d3) +
        _cell(_d3) +
        _cell(_d3), // ellipsis is three dot-3 cells (⠄⠄⠄) under Decree 15
    ':': _colon, ';': _semicolon, "'": _squote, '"': _dquoteOpen,
    '(': _lparen, ')': _rparen, '-': _dash, '/': _slash,
    '\\': _backslash,

    // ── Math symbols ──
    '+': _plus, '=': _equal, '*': _star, '<': _lt, '>': _gt,

    // ── Additional symbols ──
    '\$': _symbolPrefix + _cell(_d2 | _d3 | _d4), // $: 4 + 2,3,4
    '@': _symbolPrefix, // @: 4 (⠈) under Decree 15
    '&': _ampersand, // &: 1,2,3,4,6 (⠯) under Decree 15
    '[': _cell(_d4 | _d6) + _cell(_d1 | _d2 | _d6), // [: 4,6 + 1,2,6
    ']': _cell(_d4 | _d6) + _cell(_d3 | _d4 | _d5), // ]: 4,6 + 3,4,5
    '{': _cell(_d4 | _d5 | _d6) + _cell(_d1 | _d2 | _d6), // {: 4,5,6 + 1,2,6
    '}': _cell(_d4 | _d5 | _d6) + _cell(_d3 | _d4 | _d5), // }: 4,5,6 + 3,4,5
    '|':
        _cell(_d4 | _d5 | _d6) +
        _cell(_d1 | _d2 | _d5 | _d6), // |: 4,5,6 + 1,2,5,6
    '^': _symbolPrefix + _cell(_d2 | _d6), // ^: 4 + 2,6
    '%':
        _num +
        _cell(_d2 | _d4 | _d5) +
        _cell(_d3 | _d5 | _d6), // %: 3,4,5,6 + 2,4,5 + 3,5,6
    // ── Whitespace (giữ nguyên ASCII) ──
    ' ': ' ', '\n': '\n', '\t': '\t', '\r': '\r',
  };

  // ──────────────────── NFD → NFC composition tables ───────────────────
  //
  // Mapping: base character → {combining mark code point → NFC character}
  // Hỗ trợ multi-level: a + U+0302 → â, rồi â + U+0301 → ấ.
  static final Map<String, Map<int, String>> _nfdToNfc = {
    'a': {
      0x0301: 'á',
      0x0300: 'à',
      0x0309: 'ả',
      0x0303: 'ã',
      0x0323: 'ạ',
      0x0302: 'â',
      0x0306: 'ă',
    },
    'ă': {0x0301: 'ắ', 0x0300: 'ằ', 0x0309: 'ẳ', 0x0303: 'ẵ', 0x0323: 'ặ'},
    'â': {0x0301: 'ấ', 0x0300: 'ầ', 0x0309: 'ẩ', 0x0303: 'ẫ', 0x0323: 'ậ'},
    'e': {
      0x0301: 'é',
      0x0300: 'è',
      0x0309: 'ẻ',
      0x0303: 'ẽ',
      0x0323: 'ẹ',
      0x0302: 'ê',
    },
    'ê': {0x0301: 'ế', 0x0300: 'ề', 0x0309: 'ể', 0x0303: 'ễ', 0x0323: 'ệ'},
    'i': {0x0301: 'í', 0x0300: 'ì', 0x0309: 'ỉ', 0x0303: 'ĩ', 0x0323: 'ị'},
    'o': {
      0x0301: 'ó',
      0x0300: 'ò',
      0x0309: 'ỏ',
      0x0303: 'õ',
      0x0323: 'ọ',
      0x0302: 'ô',
      0x031B: 'ơ',
    },
    'ô': {0x0301: 'ố', 0x0300: 'ồ', 0x0309: 'ổ', 0x0303: 'ỗ', 0x0323: 'ộ'},
    'ơ': {0x0301: 'ớ', 0x0300: 'ờ', 0x0309: 'ở', 0x0303: 'ỡ', 0x0323: 'ợ'},
    'u': {
      0x0301: 'ú',
      0x0300: 'ù',
      0x0309: 'ủ',
      0x0303: 'ũ',
      0x0323: 'ụ',
      0x031B: 'ư',
    },
    'ư': {0x0301: 'ứ', 0x0300: 'ừ', 0x0309: 'ử', 0x0303: 'ữ', 0x0323: 'ự'},
    'y': {0x0301: 'ý', 0x0300: 'ỳ', 0x0309: 'ỷ', 0x0303: 'ỹ', 0x0323: 'ỵ'},
  };

  @override
  String normalize(String text) {
    text = text.toLowerCase();
    return _composeNfc(text);
  }

  @override
  ({String text, List<bool> capitals}) normalizeWithCapitals(String text) {
    final isUpper = List<bool>.generate(
      text.length,
      (i) => isUpperCase(text[i]),
    );
    final lower = text.toLowerCase();
    return _composeNfcWithCapitals(lower, isUpper);
  }

  /// Core NFD → NFC composition logic.
  /// Nếu [capitals] được truyền vào sẽ update theo composition.
  ({String text, List<bool>? capitals}) _composeNfcCore(
    String text, [
    List<bool>? capitals,
  ]) {
    String result = text;
    List<bool>? resultCapitals = capitals != null
        ? List<bool>.from(capitals)
        : null;

    for (int pass = 0; pass < 3; pass++) {
      final buf = StringBuffer();
      final newCapitals = <bool>[];
      int i = 0;
      bool changed = false;

      while (i < result.length) {
        if (i + 1 < result.length &&
            result.codeUnitAt(i + 1) >= 0x0300 &&
            result.codeUnitAt(i + 1) <= 0x036F) {
          final composed = _nfdToNfc[result[i]]?[result.codeUnitAt(i + 1)];
          if (composed != null) {
            buf.write(composed);
            if (resultCapitals != null) newCapitals.add(resultCapitals[i]);
            i += 2;
            changed = true;
            continue;
          }
        }
        buf.write(result[i]);
        if (resultCapitals != null) newCapitals.add(resultCapitals[i]);
        i++;
      }
      result = buf.toString();
      if (resultCapitals != null) resultCapitals = newCapitals;
      if (!changed) break;
    }
    return (text: result, capitals: resultCapitals);
  }

  /// Compose NFD → NFC while tracking uppercase flags through composition.
  ({String text, List<bool> capitals}) _composeNfcWithCapitals(
    String text,
    List<bool> capitals,
  ) {
    final result = _composeNfcCore(text, capitals);
    return (text: result.text, capitals: result.capitals!);
  }

  /// Compose NFD combining marks → NFC precomposed.
  /// Lặp tối đa 3 passes để xử lý multi-level (a → â → ấ).
  String _composeNfc(String text) => _composeNfcCore(text).text;

  @override
  String? mapChar(String char) => _charMap[char];

  @override
  String get capitalIndicator => _capital;

  @override
  String get numberIndicator => _num;

  @override
  String get symbolPrefix => _symbolPrefix;

  @override
  String get mathPrefix => _mathPrefix;

  @override
  String get specialPrefix => _cell(_d4 | _d5 | _d6);

  @override
  String get bracketPrefix => _cell(_d4 | _d6);

  @override
  String get dquoteClose => _dquoteClose;

  @override
  String get allCapsWord => _allCapsWord;

  @override
  String get allCapsPhrase => _allCapsPhrase;

  @override
  String get initCapsPhrase => _initCapsPhrase;

  @override
  String get endFormat => _endFormat;

  @override
  bool isUpperCase(String char) {
    if (char.length != 1) return false;
    final lower = char.toLowerCase();
    return lower != char && lower.toUpperCase() == char;
  }

  // ──────────────────── Reverse map (Braille → Text) ───────────────────
  // Only maps single-cell entries. Multi-cell symbols handled by converter.
  // Vietnamese base vowels share cells with Latin letters/punctuation,
  // so they are NOT in this map — the reverse converter must use context.
  static final Map<String, String> _reverseMap = {
    // ── Latin letters ──
    _a: 'a', _b: 'b', _c: 'c', _d: 'd', _e: 'e', _f: 'f',
    _g: 'g', _h: 'h', _i: 'i', _j: 'j', _k: 'k', _l: 'l',
    _m: 'm', _n: 'n', _o: 'o', _p: 'p', _q: 'q', _r: 'r',
    _s: 's', _t: 't', _u: 'u', _v: 'v', _w: 'w', _x: 'x',
    _y: 'y', _z: 'z',
    // ── Basic punctuation (single-cell) ──
    _comma: ',', _period: '.', _exclaim: '!',
    _colon: ':', _semicolon: ';', _squote: "'",
    _slash: '/', // slash is single-cell under Decree 15
    _ampersand: '&', // ampersand is single-cell under Decree 15
    _symbolPrefix: '@', // symbolPrefix (dot 4) falls back to @ under Decree 15
    // ── Quote open (close quote handled by converter context) ──
    _dquoteOpen: '"',
    // ── Tone marks (combining diacritics for reverse conversion) ──
    _toneSac: '\u0301', // combining acute
    _toneHuyen: '\u0300', // combining grave
    _toneHoi: '\u0309', // combining hook above
    _toneNga: '\u0303', // combining tilde
    _toneNang: '\u0323', // combining dot below
  };

  @override
  String? reverseMapChar(String brailleCell) => _reverseMap[brailleCell];

  /// Reverse map cho chữ số trong chế độ number mode: cell letter → digit.
  static final Map<String, String> _digitReverseMap = {
    _a: '1',
    _b: '2',
    _c: '3',
    _d: '4',
    _e: '5',
    _f: '6',
    _g: '7',
    _h: '8',
    _i: '9',
    _j: '0',
  };

  @override
  String? reverseMapDigit(String brailleCell) => _digitReverseMap[brailleCell];

  /// Reverse map for Vietnamese base vowels (Braille cell → vowel).
  /// Used by reverse converter for tone combination logic.
  static final Map<String, String> _vowelReverseMap = {
    _aw: 'ă', // dots 3,4,5
    _aa: 'â', // dots 1,6
    _ee: 'ê', // dots 1,2,6
    _oo: 'ô', // dots 1,4,5,6
    _ow: 'ơ', // dots 2,4,6
    _uw: 'ư', // dots 1,2,5,6
    _dj: 'đ', // dots 2,3,4,6
  };

  @override
  String? reverseMapVowel(String brailleCell) => _vowelReverseMap[brailleCell];

  @override
  String composeNfc(String text) => _composeNfc(text);
}
