/// Tạo ký tự Braille Unicode từ chuỗi dot numbers (1-8).
/// Ví dụ: '12' → U+2803 (dots 1,2)
String brf(String dots) {
  int bitmask = 0;
  for (final ch in dots.split('')) {
    bitmask |= (1 << (int.parse(ch) - 1));
  }
  return String.fromCharCode(0x2800 + bitmask);
}

/// Tạo chuỗi Braille Unicode từ chuỗi BRF tokens phân tách bởi '|'.
/// Mỗi token là chuỗi dot numbers (1-8) hoặc ký tự ASCII literal.
/// Ví dụ: '12|a|34' → [brf('12'), 'a', brf('34')]
List<String> brfTokens(String input) {
  return input.split('|').map((t) {
    if (RegExp(r'^[1-8]+$').hasMatch(t)) {
      return brf(t);
    }
    return t;
  }).toList();
}

/// Chuyển chuỗi BRF tokens thành chuỗi Braille Unicode liền nhau.
String brfJoin(String input) => brfTokens(input).join();

// ── Tone cells (dots → Unicode) — Vietnamese Braille standard ──
final String toneSac = brf('35'); // sắc: dots 3,5
final String toneHuyen = brf('56'); // huyền: dots 5,6
final String toneHoi = brf('26'); // hỏi: dots 2,6
final String toneNga = brf('36'); // ngã: dots 3,6
final String toneNang = brf('6'); // nặng: dot 6

// ── Common cells ──
final String numIndicator = brf('3456');
final String cellA = brf('1');
final String cellB = brf('12');
final String cellC = brf('14');
final String cellD = brf('145');
final String cellE = brf('15');
final String cellF = brf('124');
final String cellG = brf('1245');
final String cellH = brf('125');
final String cellI = brf('24');
final String cellJ = brf('245');
final String cellK = brf('13');
final String cellL = brf('123');
final String cellM = brf('134');
final String cellN = brf('1345');
final String cellO = brf('135');
final String cellP = brf('1234');
final String cellQ = brf('12345');
final String cellR = brf('1235');
final String cellS = brf('234');
final String cellT = brf('2345');
final String cellU = brf('136');
final String cellV = brf('1236');
final String cellW = brf('2456');
final String cellX = brf('1346');
final String cellY = brf('13456');
final String cellZ = brf('1356');

// ── Vietnamese special vowels (6-dot Braille standard) ──
final String cellAW = brf('345'); // ă: dots 3,4,5
final String cellAA = brf('16'); // â: dots 1,6
final String cellEE = brf('126'); // ê: dots 1,2,6
final String cellOO = brf('1456'); // ô: dots 1,4,5,6
final String cellOW = brf('246'); // ơ: dots 2,4,6
final String cellUW = brf('1256'); // ư: dots 1,2,5,6
final String cellDJ = brf('2346'); // đ: dots 2,3,4,6

// ── Prefix cells (for multi-cell symbols) ──
final String symbolPrefix = brf('4'); // dot 4 — punctuation prefix
final String mathPrefix = brf('5'); // dot 5 — math prefix
final String specialPrefix = brf('456'); // dots 4,5,6 — special prefix
final String bracketPrefix = brf('46'); // dots 4,6 — bracket/capital prefix

// ── Punctuation (single-cell) ──
final String comma = brf('2');
final String period = brf('256');
final String question = brf('26'); // dots 2,6 (⠢)
final String exclaim = brf('235');
final String colon = brf('25');
final String semicolon = brf('23');
final String squote = brf('3');
final String dquoteOpen = brf('236'); // mở ngoặc kép: dots 2,3,6
final String dquoteClose = brf('356'); // đóng ngoặc kép: dots 3,5,6
final String dash = brf('36'); // dots 3,6 (⠤)
final String backslash = symbolPrefix + brf('16'); // \: dots 4 + 1,6 (⠈⠡)

// ── Punctuation (multi-cell) ──
final String lparen = symbolPrefix + brf('126'); // ( : 4 + 1,2,6
final String rparen = symbolPrefix + brf('345'); // ) : 4 + 3,4,5
final String slash = brf('34'); // / : dots 3,4 (⠌)
final String underscore = symbolPrefix + brf('456'); // _ : 4 + 4,5,6

// ── Math symbols ──
final String plus = mathPrefix + brf('235'); // + : 5 + 2,3,5
final String equal = mathPrefix + brf('2356'); // = : 5 + 2,3,5,6
final String star = brf('236'); // * : dots 2,3,6 (⠦)
final String lt = mathPrefix + brf('246'); // < : 5 + 2,4,6
final String gt = mathPrefix + brf('135'); // > : 5 + 1,3,5
