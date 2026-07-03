import 'package:flutter_test/flutter_test.dart';
import 'package:viet_braille_app/core/braille_mapping.dart';
import '../helpers/braille_test_helper.dart';

void main() {
  late BrailleMappingImpl mapping;

  setUp(() {
    mapping = BrailleMappingImpl();
  });

  // ══════════════════════════════════════════════════════════════════════
  // mapChar() — 26 Latin characters
  // ══════════════════════════════════════════════════════════════════════
  group('mapChar — Latin alphabet (a-z)', () {
    final expected = {
      'a': cellA,
      'b': cellB,
      'c': cellC,
      'd': cellD,
      'e': cellE,
      'f': cellF,
      'g': cellG,
      'h': cellH,
      'i': cellI,
      'j': cellJ,
      'k': cellK,
      'l': cellL,
      'm': cellM,
      'n': cellN,
      'o': cellO,
      'p': cellP,
      'q': cellQ,
      'r': cellR,
      's': cellS,
      't': cellT,
      'u': cellU,
      'v': cellV,
      'w': cellW,
      'x': cellX,
      'y': cellY,
      'z': cellZ,
    };

    for (final entry in expected.entries) {
      test("'${entry.key}' → correct Braille cell", () {
        expect(mapping.mapChar(entry.key), equals(entry.value));
      });
    }
  });

  // ══════════════════════════════════════════════════════════════════════
  // mapChar() — 7 Vietnamese special characters (no tone)
  // ══════════════════════════════════════════════════════════════════════
  group('mapChar — Vietnamese specials (no tone)', () {
    test('ă', () => expect(mapping.mapChar('ă'), equals(cellAW)));
    test('â', () => expect(mapping.mapChar('â'), equals(cellAA)));
    test('ê', () => expect(mapping.mapChar('ê'), equals(cellEE)));
    test('ô', () => expect(mapping.mapChar('ô'), equals(cellOO)));
    test('ơ', () => expect(mapping.mapChar('ơ'), equals(cellOW)));
    test('ư', () => expect(mapping.mapChar('ư'), equals(cellUW)));
    test('đ', () => expect(mapping.mapChar('đ'), equals(cellDJ)));
  });

  // ══════════════════════════════════════════════════════════════════════
  // mapChar() — 60 toned vowels: tone cell BEFORE base cell
  // ══════════════════════════════════════════════════════════════════════
  group('mapChar — toned vowels (12 bases × 5 tones)', () {
    // a + tone
    group('a + tone', () {
      test(
        'á = toneSac + a',
        () => expect(mapping.mapChar('á'), equals('$toneSac$cellA')),
      );
      test(
        'à = toneHuyen + a',
        () => expect(mapping.mapChar('à'), equals('$toneHuyen$cellA')),
      );
      test(
        'ả = toneHoi + a',
        () => expect(mapping.mapChar('ả'), equals('$toneHoi$cellA')),
      );
      test(
        'ã = toneNga + a',
        () => expect(mapping.mapChar('ã'), equals('$toneNga$cellA')),
      );
      test(
        'ạ = toneNang + a',
        () => expect(mapping.mapChar('ạ'), equals('$toneNang$cellA')),
      );
    });

    // ă + tone
    group('ă + tone', () {
      test('ắ', () => expect(mapping.mapChar('ắ'), equals('$toneSac$cellAW')));
      test(
        'ằ',
        () => expect(mapping.mapChar('ằ'), equals('$toneHuyen$cellAW')),
      );
      test('ẳ', () => expect(mapping.mapChar('ẳ'), equals('$toneHoi$cellAW')));
      test('ẵ', () => expect(mapping.mapChar('ẵ'), equals('$toneNga$cellAW')));
      test('ặ', () => expect(mapping.mapChar('ặ'), equals('$toneNang$cellAW')));
    });

    // â + tone
    group('â + tone', () {
      test('ấ', () => expect(mapping.mapChar('ấ'), equals('$toneSac$cellAA')));
      test(
        'ầ',
        () => expect(mapping.mapChar('ầ'), equals('$toneHuyen$cellAA')),
      );
      test('ẩ', () => expect(mapping.mapChar('ẩ'), equals('$toneHoi$cellAA')));
      test('ẫ', () => expect(mapping.mapChar('ẫ'), equals('$toneNga$cellAA')));
      test('ậ', () => expect(mapping.mapChar('ậ'), equals('$toneNang$cellAA')));
    });

    // e + tone
    group('e + tone', () {
      test('é', () => expect(mapping.mapChar('é'), equals('$toneSac$cellE')));
      test('è', () => expect(mapping.mapChar('è'), equals('$toneHuyen$cellE')));
      test('ẻ', () => expect(mapping.mapChar('ẻ'), equals('$toneHoi$cellE')));
      test('ẽ', () => expect(mapping.mapChar('ẽ'), equals('$toneNga$cellE')));
      test('ẹ', () => expect(mapping.mapChar('ẹ'), equals('$toneNang$cellE')));
    });

    // ê + tone
    group('ê + tone', () {
      test('ế', () => expect(mapping.mapChar('ế'), equals('$toneSac$cellEE')));
      test(
        'ề',
        () => expect(mapping.mapChar('ề'), equals('$toneHuyen$cellEE')),
      );
      test('ể', () => expect(mapping.mapChar('ể'), equals('$toneHoi$cellEE')));
      test('ễ', () => expect(mapping.mapChar('ễ'), equals('$toneNga$cellEE')));
      test('ệ', () => expect(mapping.mapChar('ệ'), equals('$toneNang$cellEE')));
    });

    // i + tone
    group('i + tone', () {
      test('í', () => expect(mapping.mapChar('í'), equals('$toneSac$cellI')));
      test('ì', () => expect(mapping.mapChar('ì'), equals('$toneHuyen$cellI')));
      test('ỉ', () => expect(mapping.mapChar('ỉ'), equals('$toneHoi$cellI')));
      test('ĩ', () => expect(mapping.mapChar('ĩ'), equals('$toneNga$cellI')));
      test('ị', () => expect(mapping.mapChar('ị'), equals('$toneNang$cellI')));
    });

    // o + tone
    group('o + tone', () {
      test('ó', () => expect(mapping.mapChar('ó'), equals('$toneSac$cellO')));
      test('ò', () => expect(mapping.mapChar('ò'), equals('$toneHuyen$cellO')));
      test('ỏ', () => expect(mapping.mapChar('ỏ'), equals('$toneHoi$cellO')));
      test('õ', () => expect(mapping.mapChar('õ'), equals('$toneNga$cellO')));
      test('ọ', () => expect(mapping.mapChar('ọ'), equals('$toneNang$cellO')));
    });

    // ô + tone
    group('ô + tone', () {
      test('ố', () => expect(mapping.mapChar('ố'), equals('$toneSac$cellOO')));
      test(
        'ồ',
        () => expect(mapping.mapChar('ồ'), equals('$toneHuyen$cellOO')),
      );
      test('ổ', () => expect(mapping.mapChar('ổ'), equals('$toneHoi$cellOO')));
      test('ỗ', () => expect(mapping.mapChar('ỗ'), equals('$toneNga$cellOO')));
      test('ộ', () => expect(mapping.mapChar('ộ'), equals('$toneNang$cellOO')));
    });

    // ơ + tone
    group('ơ + tone', () {
      test('ớ', () => expect(mapping.mapChar('ớ'), equals('$toneSac$cellOW')));
      test(
        'ờ',
        () => expect(mapping.mapChar('ờ'), equals('$toneHuyen$cellOW')),
      );
      test('ở', () => expect(mapping.mapChar('ở'), equals('$toneHoi$cellOW')));
      test('ỡ', () => expect(mapping.mapChar('ỡ'), equals('$toneNga$cellOW')));
      test('ợ', () => expect(mapping.mapChar('ợ'), equals('$toneNang$cellOW')));
    });

    // u + tone
    group('u + tone', () {
      test('ú', () => expect(mapping.mapChar('ú'), equals('$toneSac$cellU')));
      test('ù', () => expect(mapping.mapChar('ù'), equals('$toneHuyen$cellU')));
      test('ủ', () => expect(mapping.mapChar('ủ'), equals('$toneHoi$cellU')));
      test('ũ', () => expect(mapping.mapChar('ũ'), equals('$toneNga$cellU')));
      test('ụ', () => expect(mapping.mapChar('ụ'), equals('$toneNang$cellU')));
    });

    // ư + tone
    group('ư + tone', () {
      test('ứ', () => expect(mapping.mapChar('ứ'), equals('$toneSac$cellUW')));
      test(
        'ừ',
        () => expect(mapping.mapChar('ừ'), equals('$toneHuyen$cellUW')),
      );
      test('ử', () => expect(mapping.mapChar('ử'), equals('$toneHoi$cellUW')));
      test('ữ', () => expect(mapping.mapChar('ữ'), equals('$toneNga$cellUW')));
      test('ự', () => expect(mapping.mapChar('ự'), equals('$toneNang$cellUW')));
    });

    // y + tone
    group('y + tone', () {
      test('ý', () => expect(mapping.mapChar('ý'), equals('$toneSac$cellY')));
      test('ỳ', () => expect(mapping.mapChar('ỳ'), equals('$toneHuyen$cellY')));
      test('ỷ', () => expect(mapping.mapChar('ỷ'), equals('$toneHoi$cellY')));
      test('ỹ', () => expect(mapping.mapChar('ỹ'), equals('$toneNga$cellY')));
      test('ỵ', () => expect(mapping.mapChar('ỵ'), equals('$toneNang$cellY')));
    });

    test('tone cells are separate from base cells (no dot collision)', () {
      // Verify that toned vowels have LENGTH > 1 (tone cell + base cell)
      final toned = [
        'á',
        'à',
        'ả',
        'ã',
        'ạ',
        'ắ',
        'ằ',
        'ầ',
        'ế',
        'ồ',
        'ớ',
        'ứ',
        'ự',
      ];
      for (final ch in toned) {
        final braille = mapping.mapChar(ch);
        expect(braille, isNotNull);
        expect(
          braille!.length,
          equals(2),
          reason:
              "'$ch' should be 2 cells (tone + base), got ${braille.length}",
        );
      }
    });
  });

  // ══════════════════════════════════════════════════════════════════════
  // mapChar() — digits 0-9 with number indicator
  // ══════════════════════════════════════════════════════════════════════
  group(
    'mapChar — digits (letter cell only, indicator added by converter)',
    () {
      test('1 → a', () => expect(mapping.mapChar('1'), equals(cellA)));
      test('2 → b', () => expect(mapping.mapChar('2'), equals(cellB)));
      test('3 → c', () => expect(mapping.mapChar('3'), equals(cellC)));
      test('4 → d', () => expect(mapping.mapChar('4'), equals(cellD)));
      test('5 → e', () => expect(mapping.mapChar('5'), equals(cellE)));
      test('6 → f', () => expect(mapping.mapChar('6'), equals(cellF)));
      test('7 → g', () => expect(mapping.mapChar('7'), equals(cellG)));
      test('8 → h', () => expect(mapping.mapChar('8'), equals(cellH)));
      test('9 → i', () => expect(mapping.mapChar('9'), equals(cellI)));
      test('0 → j', () => expect(mapping.mapChar('0'), equals(cellJ)));
    },
  );

  // ══════════════════════════════════════════════════════════════════════
  // mapChar() — punctuation
  // ══════════════════════════════════════════════════════════════════════
  group('mapChar — punctuation', () {
    test(',', () => expect(mapping.mapChar(','), equals(comma)));
    test('.', () => expect(mapping.mapChar('.'), equals(period)));
    test('?', () => expect(mapping.mapChar('?'), equals(question)));
    test('!', () => expect(mapping.mapChar('!'), equals(exclaim)));
    test(':', () => expect(mapping.mapChar(':'), equals(colon)));
    test(';', () => expect(mapping.mapChar(';'), equals(semicolon)));
    test("'", () => expect(mapping.mapChar("'"), equals(squote)));
    test('"', () => expect(mapping.mapChar('"'), equals(dquoteOpen)));
    test('(', () => expect(mapping.mapChar('('), equals(lparen)));
    test(')', () => expect(mapping.mapChar(')'), equals(rparen)));
    test('-', () => expect(mapping.mapChar('-'), equals(dash)));
    test('/', () => expect(mapping.mapChar('/'), isNotNull));
  });

  // ══════════════════════════════════════════════════════════════════════
  // mapChar() — math symbols
  // ══════════════════════════════════════════════════════════════════════
  group('mapChar — math symbols', () {
    test('+', () => expect(mapping.mapChar('+'), isNotNull));
    test('=', () => expect(mapping.mapChar('='), isNotNull));
    test('*', () => expect(mapping.mapChar('*'), isNotNull));
    test('<', () => expect(mapping.mapChar('<'), isNotNull));
    test('>', () => expect(mapping.mapChar('>'), isNotNull));
  });

  // ══════════════════════════════════════════════════════════════════════
  // mapChar() — whitespace preserved as-is
  // ══════════════════════════════════════════════════════════════════════
  group('mapChar — whitespace', () {
    test('space', () => expect(mapping.mapChar(' '), equals(' ')));
    test('newline', () => expect(mapping.mapChar('\n'), equals('\n')));
    test('tab', () => expect(mapping.mapChar('\t'), equals('\t')));
    test('carriage return', () => expect(mapping.mapChar('\r'), equals('\r')));
  });

  // ══════════════════════════════════════════════════════════════════════
  // mapChar() — unknown characters → null
  // ══════════════════════════════════════════════════════════════════════
  group('mapChar — special characters', () {
    test(
      '# → 2-cell: specialPrefix + numIndicator',
      () => expect(mapping.mapChar('#'), equals('$specialPrefix$numIndicator')),
    );
    test(
      '_ → 2-cell: symbolPrefix + dots 456',
      () => expect(mapping.mapChar('_'), equals(underscore)),
    );
    test(
      '\\ → dots 3,4',
      () => expect(mapping.mapChar('\\'), equals(backslash)),
    );
    test('\$ → 2-cell', () => expect(mapping.mapChar('\$'), isNotNull));
    test('@ → 2-cell', () => expect(mapping.mapChar('@'), isNotNull));
    test('% → 3-cell', () => expect(mapping.mapChar('%'), isNotNull));
    test('& → 2-cell', () => expect(mapping.mapChar('&'), isNotNull));
    test('[ → 2-cell', () => expect(mapping.mapChar('['), isNotNull));
    test('] → 2-cell', () => expect(mapping.mapChar(']'), isNotNull));
    test('{ → 2-cell', () => expect(mapping.mapChar('{'), isNotNull));
    test('} → 2-cell', () => expect(mapping.mapChar('}'), isNotNull));
    test('| → 2-cell', () => expect(mapping.mapChar('|'), isNotNull));
    test('^ → 2-cell', () => expect(mapping.mapChar('^'), isNotNull));
  });

  group('mapChar — unknown characters', () {
    test('~', () => expect(mapping.mapChar('~'), isNull));
  });

  // ══════════════════════════════════════════════════════════════════════
  // normalize() — lowercase
  // ══════════════════════════════════════════════════════════════════════
  group('normalize — lowercase', () {
    test('uppercase ASCII → lowercase', () {
      expect(mapping.normalize('HELLO'), equals('hello'));
    });
    test('mixed case Vietnamese', () {
      expect(mapping.normalize('Việt Nam'), equals('việt nam'));
    });
    test('Đ (U+0110) → đ (U+0111)', () {
      expect(mapping.normalize('Đ'), equals('đ'));
    });
    test('đỘi → đội', () {
      expect(mapping.normalize('ĐỘi'), equals('đội'));
    });
  });

  // ══════════════════════════════════════════════════════════════════════
  // normalize() — NFC composition (NFD → NFC)
  // ══════════════════════════════════════════════════════════════════════
  group('normalize — NFC composition', () {
    test('NFC input unchanged (á)', () {
      expect(mapping.normalize('á'), equals('á'));
    });

    test('NFD 1 level: a + U+0301 → á', () {
      final nfd = 'a\u0301'; // a + combining acute
      expect(mapping.normalize(nfd), equals('á'));
    });

    test('NFD 1 level: a + U+0300 → à', () {
      final nfd = 'a\u0300';
      expect(mapping.normalize(nfd), equals('à'));
    });

    test('NFD 1 level: a + U+0309 → ả', () {
      final nfd = 'a\u0309';
      expect(mapping.normalize(nfd), equals('ả'));
    });

    test('NFD 1 level: a + U+0303 → ã', () {
      final nfd = 'a\u0303';
      expect(mapping.normalize(nfd), equals('ã'));
    });

    test('NFD 1 level: a + U+0323 → ạ', () {
      final nfd = 'a\u0323';
      expect(mapping.normalize(nfd), equals('ạ'));
    });

    test('NFD 1 level: a + U+0302 → â', () {
      final nfd = 'a\u0302';
      expect(mapping.normalize(nfd), equals('â'));
    });

    test('NFD 1 level: a + U+0306 → ă', () {
      final nfd = 'a\u0306';
      expect(mapping.normalize(nfd), equals('ă'));
    });

    test('NFD 2 levels: a + U+0302 + U+0301 → ấ (pass 1: â, pass 2: ấ)', () {
      final nfd = 'a\u0302\u0301'; // a + circumflex + acute
      expect(mapping.normalize(nfd), equals('ấ'));
    });

    test('NFD 2 levels: a + U+0302 + U+0300 → ầ', () {
      final nfd = 'a\u0302\u0300';
      expect(mapping.normalize(nfd), equals('ầ'));
    });

    test('NFD 2 levels: a + U+0306 + U+0301 → ắ', () {
      final nfd = 'a\u0306\u0301'; // a + breve + acute
      expect(mapping.normalize(nfd), equals('ắ'));
    });

    test('NFD 2 levels: o + U+0302 + U+0301 → ố', () {
      final nfd = 'o\u0302\u0301';
      expect(mapping.normalize(nfd), equals('ố'));
    });

    test('NFD 2 levels: o + U+031B + U+0301 → ớ', () {
      final nfd = 'o\u031B\u0301'; // o + horn + acute
      expect(mapping.normalize(nfd), equals('ớ'));
    });

    test('NFD 2 levels: u + U+031B + U+0300 → ừ', () {
      final nfd = 'u\u031B\u0300';
      expect(mapping.normalize(nfd), equals('ừ'));
    });

    test('NFD word: "hiếu" decomposed', () {
      // h + i + e + U+0302 + U+0301 + u
      final nfd = 'hie\u0302\u0301u';
      expect(mapping.normalize(nfd), equals('hiếu'));
    });

    test('NFD word: "xuất" decomposed', () {
      // x + u + a + U+0302(circumflex) + U+0301(acute) + t
      // ấ in NFD = a + circumflex + acute
      final nfd = 'xua\u0302\u0301t';
      expect(mapping.normalize(nfd), equals('xuất'));
    });

    test('pure ASCII passes through unchanged', () {
      expect(mapping.normalize('hello world'), equals('hello world'));
    });

    test('empty string', () {
      expect(mapping.normalize(''), equals(''));
    });
  });

  // ══════════════════════════════════════════════════════════════════════
  // Full mapping completeness: _charMap has exactly 97 entries
  // ══════════════════════════════════════════════════════════════════════
  group('mapping completeness', () {
    test('every lowercase Vietnamese letter maps to non-null', () {
      final allVietnamese =
          'aăâbcdđeêghijklmnoôơpqrstuưvxy'
          'áàảãạắằẳẵặấầẩẫậéèẻẽẹếềểễệíìỉĩịóòỏõọốồổỗộớờởỡợúùủũụứừửữýỳỷỹỵ';
      for (final ch in allVietnamese.split('')) {
        expect(
          mapping.mapChar(ch),
          isNotNull,
          reason: "'$ch' should be in the map",
        );
      }
    });

    test('every digit maps to non-null', () {
      for (final ch in '0123456789'.split('')) {
        expect(
          mapping.mapChar(ch),
          isNotNull,
          reason: "digit '$ch' should be in the map",
        );
      }
    });

    test('every common punctuation maps to non-null', () {
      for (final ch in [
        ',',
        '.',
        '?',
        '!',
        ':',
        ';',
        "'",
        '"',
        '(',
        ')',
        '-',
        '/',
        '\\',
      ]) {
        expect(
          mapping.mapChar(ch),
          isNotNull,
          reason: "punctuation '$ch' should be in the map",
        );
      }
    });
  });
}
