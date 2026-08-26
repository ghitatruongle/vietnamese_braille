import 'package:test/test.dart';
import 'package:viet_braille_core/viet_braille_core.dart';

void main() {
  late BrailleMappingImpl mapping;
  late BrailleConverterImpl forward;
  late BrailleReverseConverterImpl reverse;

  setUp(() {
    mapping = BrailleMappingImpl();
    forward = BrailleConverterImpl(mapping);
    reverse = BrailleReverseConverterImpl(mapping);
  });

  String losslessRoundTrip(String text) {
    final braille = forward.convert(text, mode: BrailleConversionMode.lossless);
    return reverse.convert(braille, mode: BrailleConversionMode.lossless);
  }

  group('mapping completeness — Latin letters', () {
    for (final letter in 'abcdefghijklmnopqrstuvwxyz'.split('')) {
      test('$letter maps to a non-empty Braille cell', () {
        final cell = mapping.mapChar(letter);
        expect(cell, isNotNull);
        expect(cell, isNotEmpty);
        // Every 6-dot cell is in U+2800–U+283F.
        for (final rune in (cell as String).runes) {
          expect(rune, inInclusiveRange(0x2800, 0x283F));
        }
      });
    }
  });

  group('mapping completeness — Vietnamese vowels', () {
    const vowels = 'aăâeêioôơuưy';
    for (final vowel in vowels.split('')) {
      test('$vowel maps to a Braille cell', () {
        expect(mapping.mapChar(vowel), isNotNull);
      });
    }

    test('đ maps to a Braille cell', () {
      expect(mapping.mapChar('đ'), isNotNull);
    });
  });

  group('mapping completeness — all 60 toned vowels', () {
    const tones = {
      'sắc': 'áéíóúýắấếốớứ',
      'huyền': 'àèìòùỳằầềồờừ',
      'hỏi': 'ảẻỉỏủỷẳẩểổởử',
      'ngã': 'ãẽĩõũỹẵẫễỗỡữ',
      'nặng': 'ạẹịọụỵặậệộợự',
    };

    tones.forEach((toneName, chars) {
      for (final ch in chars.split('')) {
        test('$toneName $ch → 2 cells: tone + base', () {
          final cell = mapping.mapChar(ch);
          expect(cell, isNotNull, reason: ch);
          expect(cell!.runes.length, 2, reason: '$ch -> $cell');
        });
      }
    });
  });

  group('mapping completeness — digits in number mode', () {
    test('each digit round-trips through number mode', () {
      for (var d = 0; d <= 9; d++) {
        final input = '$d';
        final braille = forward.convert(input);
        expect(braille, startsWith(mapping.numberIndicator), reason: input);
        expect(reverse.convert(braille), input, reason: input);
      }
    });
  });

  group('mapping completeness — punctuation', () {
    const punctuation = ',.?!"\':;()/-\\';
    for (final ch in punctuation.split('')) {
      test('$ch maps and round-trips (lossless)', () {
        expect(mapping.mapChar(ch), isNotNull, reason: ch);
        // Quote/star & dash collisions are handled by lossless escape.
        expect(losslessRoundTrip('a${ch}b'), 'a${ch}b', reason: ch);
      });
    }

    test('ellipsis … maps to three dot-3 cells', () {
      expect(mapping.mapChar('…'), '⠄⠄⠄');
    });

    test('apostrophe and slash round-trip', () {
      expect(losslessRoundTrip("a'b"), "a'b");
      expect(losslessRoundTrip('a/b'), 'a/b');
    });
  });

  group('mapping completeness — math symbols', () {
    const math = '+=<*<>';
    for (final ch in math.split('')) {
      test('$ch maps and round-trips', () {
        expect(mapping.mapChar(ch), isNotNull, reason: ch);
        expect(losslessRoundTrip('a $ch b'), 'a $ch b', reason: ch);
      });
    }

    // Extended math symbols added in v1.2.5-beta1 (≈ ≤ ≥ ≠).
    // Mapped as mathPrefix + unique base cell; prefix consumed by
    // _handlePrefixCell so bare-base collisions are not an issue.
    for (final ch in '≈≤≥≠'.split('')) {
      test('$ch maps and round-trips', () {
        expect(mapping.mapChar(ch), isNotNull, reason: ch);
        expect(losslessRoundTrip('a $ch b'), 'a $ch b', reason: ch);
      });
    }

    // B1: ± × ÷ √ (mathPrefix + unique base).
    for (final ch in '±×÷√'.split('')) {
      test('$ch maps and round-trips', () {
        expect(mapping.mapChar(ch), isNotNull, reason: ch);
        expect(losslessRoundTrip('a $ch b'), 'a $ch b', reason: ch);
      });
    }
  });

  group('mapping completeness — extended math in expressions', () {
    test('± × ÷ √ convert exactly', () {
      expect(forward.convert('5 ± 3'), '⠼⠑⠐⠇⠼⠉');
      expect(forward.convert('6 × 7'), '⠼⠋⠐⠥⠼⠛');
      expect(forward.convert('12 ÷ 4'), '⠼⠁⠃⠐⠋⠼⠙');
      expect(forward.convert('√9'), '⠐⠍⠼⠊');
    });

    test('± × ÷ √ round-trip in standard mode', () {
      for (final expr in ['5 ± 3', '6 × 7', '12 ÷ 4', '√9']) {
        final braille = forward.convert(expr);
        final back = reverse.convert(braille);
        expect(back, expr.replaceAll(' ', ''), reason: expr);
      }
    });
    test('preprocessor keeps multi-char operators intact', () {
      // ≥ in "1 >= 2" must not be split into > and =.
      // Verify through the converter: if the regex split them, the forward
      // output would contain two separate math-prefixed sequences instead
      // of the single ">=" block.
      expect(forward.convert('1 >= 2'), '⠼⠁⠐⠕⠐⠶⠼⠃');
      expect(forward.convert('1 <= 2'), '⠼⠁⠐⠪⠐⠶⠼⠃');
      expect(forward.convert('1 != 2'), '⠼⠁⠖⠐⠶⠼⠃');
    });

    test('a ≈ b round-trips exactly', () {
      final braille = forward.convert('a ≈ b');
      expect(braille, '⠁ ⠐⠝ ⠃');
      expect(reverse.convert(braille), 'a ≈ b');
    });

    test('1 ≤ 2 round-trips in number mode', () {
      final braille = forward.convert('1 ≤ 2');
      expect(braille, '⠼⠁⠐⠞⠼⠃');
      expect(reverse.convert(braille), '1≤2');
    });

    test('3 ≥ 2 round-trips in number mode', () {
      final braille = forward.convert('3 ≥ 2');
      expect(braille, '⠼⠉⠐⠛⠼⠃');
      expect(reverse.convert(braille), '3≥2');
    });

    test('x ≠ y round-trips exactly', () {
      final braille = forward.convert('x ≠ y');
      expect(braille, '⠭ ⠐⠎ ⠽');
      expect(reverse.convert(braille), 'x ≠ y');
    });
  });

  group('mapping completeness — multi-cell symbols', () {
    test('parentheses round-trip', () {
      expect(mapping.mapChar('('), isNotNull);
      expect(mapping.mapChar(')'), isNotNull);
      expect(losslessRoundTrip('a(b)c'), 'a(b)c');
    });

    test('brackets round-trip', () {
      expect(mapping.mapChar('['), isNotNull);
      expect(mapping.mapChar(']'), isNotNull);
      expect(losslessRoundTrip('a[b]c'), 'a[b]c');
    });

    test('braces round-trip', () {
      expect(mapping.mapChar('{'), isNotNull);
      expect(mapping.mapChar('}'), isNotNull);
      // A5: allCapsWord (dots 4,5,6) now defers to specialPrefix when the
      // next cell forms a valid { } | # pair — full round-trip works.
      expect(losslessRoundTrip(r'a{b}c'), r'a{b}c');
      expect(losslessRoundTrip(r'a}b}c'), r'a}b}c');
    });

    test('backslash round-trip', () {
      expect(mapping.mapChar(r'\'), isNotNull);
      expect(losslessRoundTrip(r'a\b'), r'a\b');
    });

    test('underscore round-trip', () {
      expect(mapping.mapChar('_'), isNotNull);
      expect(losslessRoundTrip('a_b'), 'a_b');
    });

    test('dollar round-trip', () {
      expect(mapping.mapChar(r'$'), isNotNull);
      expect(losslessRoundTrip(r'a$b'), r'a$b');
    });

    test('ampersand round-trip', () {
      expect(mapping.mapChar('&'), isNotNull);
      expect(losslessRoundTrip('a&b'), 'a&b');
    });

    test('at round-trip', () {
      expect(mapping.mapChar('@'), isNotNull);
      expect(losslessRoundTrip('a@b'), 'a@b');
    });

    test('caret round-trip', () {
      expect(mapping.mapChar('^'), isNotNull);
      expect(losslessRoundTrip('a^b'), 'a^b');
    });

    test('pipe round-trip', () {
      expect(mapping.mapChar('|'), isNotNull);
      // A5: dots 4,5,6 + 1,2,5,6 now resolves via specialPrefix → full
      // round-trip works.
      expect(losslessRoundTrip('a|b'), 'a|b');
    });

    test('hash round-trip', () {
      expect(mapping.mapChar('#'), isNotNull);
      // A5: dots 4,5,6 + 3,4,5,6 now resolves via specialPrefix → full
      // round-trip works.
      expect(losslessRoundTrip('a#b'), 'a#b');
    });

    test('percent round-trip', () {
      expect(mapping.mapChar('%'), isNotNull);
      expect(losslessRoundTrip('a%b'), 'a%b');
    });

    // B2: special characters (guillemets, dashes, currency, per-mille,
    // copyright/registered/trademark, degree, superscripts, arrows).
    // All mapped as symbolPrefix (dot 4) + unique base; verified round-trip.
    test('special characters round-trip', () {
      const chars = '«»–—₫‰©®™°²³←→↑↓';
      for (final ch in chars.split('')) {
        expect(mapping.mapChar(ch), isNotNull, reason: ch);
        expect(losslessRoundTrip('a$ch b'), 'a$ch b', reason: ch);
      }
    });

    test('special characters convert exactly', () {
      expect(forward.convert('«trích dẫn»'), '⠈⠦⠞⠗⠔⠊⠉⠓ ⠙⠤⠡⠝⠈⠴');
      expect(forward.convert('10₫'), '⠼⠁⠚⠈⠹');
      expect(forward.convert('25°C'), '⠼⠃⠑⠈⠳⠨⠉');
      expect(forward.convert('m²'), '⠍⠈⠇');
      expect(forward.convert('© 2026'), '⠈⠉ ⠼⠃⠚⠃⠋');
    });
  });

  group('mapping completeness — B5 formatting markers', () {
    test('marker cells are 2-cell symbolPrefix pairs', () {
      expect(mapping.boldMarker.runes.length, 2, reason: 'bold');
      expect(mapping.italicMarker.runes.length, 2, reason: 'italic');
      expect(mapping.underlineMarker.runes.length, 2, reason: 'underline');
    });

    test('bold marker via control char round-trips', () {
      final input = '\u0002đậm\u0002';
      final braille = forward.convert(input);
      expect(braille, '${mapping.boldMarker}⠮⠠⠡⠍${mapping.boldMarker}');
      expect(reverse.convert(braille), input);
    });

    test('italic marker via control char round-trips', () {
      final input = '\u000Enghiêng\u000E';
      final braille = forward.convert(input);
      expect(braille, '${mapping.italicMarker}⠝⠛⠓⠊⠣⠝⠛${mapping.italicMarker}');
      expect(reverse.convert(braille), input);
    });

    test('underline marker via control char round-trips', () {
      final input = '\u001Fgạch chân\u001F';
      final braille = forward.convert(input);
      expect(
        braille,
        '${mapping.underlineMarker}⠛⠠⠁⠉⠓ ⠉⠓⠡⠝${mapping.underlineMarker}',
      );
      expect(reverse.convert(braille), input);
    });

    test('markdown bold **text** is preprocessed to markers', () {
      final braille = forward.convert('**text**', enableMarkdown: true);
      expect(braille, startsWith(mapping.boldMarker));
      expect(braille, endsWith(mapping.boldMarker));
      final inner = braille.substring(
        mapping.boldMarker.length,
        braille.length - mapping.boldMarker.length,
      );
      expect(inner, forward.convert('text'));
    });

    test('markdown is disabled by default — asterisks stay literal', () {
      final braille = forward.convert('**text**');
      expect(braille.contains(mapping.boldMarker), isFalse);
    });
  });

  group('mapping completeness — B5 markdown regression (Vietnamese)', () {
    test('bold **Việt Nam** wraps marker cells and round-trips', () {
      final braille = forward.convert('**Việt Nam**', enableMarkdown: true);
      expect(braille, startsWith(mapping.boldMarker));
      expect(braille, endsWith(mapping.boldMarker));
      expect(reverse.convert(braille), '\u0002Việt Nam\u0002');
    });

    test('italic *nghiêng* wraps marker cells and round-trips', () {
      final braille = forward.convert('*nghiêng*', enableMarkdown: true);
      expect(braille, startsWith(mapping.italicMarker));
      expect(braille, endsWith(mapping.italicMarker));
      expect(reverse.convert(braille), '\u000Enghiêng\u000E');
    });

    test('underline _gạch chân_ wraps marker cells and round-trips', () {
      final braille = forward.convert('_gạch chân_', enableMarkdown: true);
      expect(braille, startsWith(mapping.underlineMarker));
      expect(braille, endsWith(mapping.underlineMarker));
      expect(reverse.convert(braille), '\u001Fgạch chân\u001F');
    });

    test('mixed sentence keeps bold span around **bạn**', () {
      final braille = forward.convert(
        'chào **bạn** thân mến',
        enableMarkdown: true,
      );
      final boldSpan =
          '${mapping.boldMarker}${forward.convert('bạn')}'
          '${mapping.boldMarker}';
      expect(braille.contains(boldSpan), isTrue);
    });

    test('all three markers can coexist in one text', () {
      const input = '**a** *b* _c_';
      final braille = forward.convert(input, enableMarkdown: true);
      expect(braille, contains(mapping.boldMarker));
      expect(braille, contains(mapping.italicMarker));
      expect(braille, contains(mapping.underlineMarker));
    });
  });

  group('mapping completeness — tone cells', () {
    test('tone cell after base letter is decoded as combining mark', () {
      // 'á' maps to 2 cells: toneCell + baseCell
      final tonedAcute = mapping.mapChar('á')!;
      expect(tonedAcute.runes.length, 2);
      final toneCell = String.fromCharCode(tonedAcute.runes.first);
      final baseCell = String.fromCharCode(tonedAcute.runes.last);
      // In reverse, toneCell is combining acute
      final result = reverse.convert(baseCell + toneCell);
      expect(result.toLowerCase(), 'á');
    });

    test('each toned vowel has 2-cell mapping', () {
      for (final toned in 'áàảãạéèẻẽẹ'.split('')) {
        final cell = mapping.mapChar(toned);
        expect(cell, isNotNull, reason: toned);
        expect(cell!.runes.length, 2, reason: toned);
      }
    });
  });

  group('mapping completeness — capitalization indicators', () {
    test('capital indicator is U+2828 (dots 4,6)', () {
      expect(mapping.capitalIndicator, '⠨');
    });
    test('number indicator is U+283C (dots 3,4,5,6)', () {
      expect(mapping.numberIndicator, '⠼');
    });
    test('allCapsWord is U+2838 (dots 4,5,6)', () {
      expect(mapping.allCapsWord, '⠸');
    });
    test('allCapsPhrase is ⠨⠨', () {
      expect(mapping.allCapsPhrase, '⠨⠨');
    });
    test('initCapsPhrase is ⠒⠨', () {
      expect(mapping.initCapsPhrase, '⠒⠨');
    });
    test('endFormat is ⠱ (dots 1,5,6)', () {
      expect(mapping.endFormat, '⠱');
    });
  });

  group('mapping completeness — unknown cell passthrough', () {
    test('8-dot cell is not silently decoded', () {
      // U+2840 (dot 7) is outside the 6-dot standard.
      expect(reverse.convert('\u2840'), '\u2840');
    });
  });
}
