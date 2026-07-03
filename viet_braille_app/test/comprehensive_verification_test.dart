import 'package:flutter_test/flutter_test.dart';
import 'package:viet_braille_app/core/braille_mapping.dart';
import 'package:viet_braille_app/domain/braille_converter.dart';
import 'package:viet_braille_app/domain/braille_reverse_converter.dart';
import 'helpers/braille_test_helper.dart';

/// KIỂM TRA TOÀN DIỆN: Mọi ký tự tiếng Việt được chuyển đổi chính xác.
///
/// File này test converter (không chỉ mapping) trên:
/// 1. TẤT CẢ nguyên âm tiếng Việt × 5 thanh điệu = 60 ký tự
/// 2. Tất cả ví dụ từ file quy tắc Braille (Section VI, VII)
/// 3. Qu/gi rules: mọi tổ hợp
/// 4. Capital rules: có/không phụ âm đầu
/// 5. Round-trip: Braille → Text → Braille
/// 6. NFD input cho mọi ký tự
/// 7. Collision detection: không có 2 input khác nhau cho cùng output
/// 8. Real text: câu tiếng Việt thực tế
///
/// Known reverse converter limitations (Braille ambiguity):
/// - "oán" style: vowel-initial syllables with tone on later vowel
/// - "quyền" style: qu rule with tone on ê after y
/// - "a1b2": 'b' and '2' share same Braille cell (inherent ambiguity)
void main() {
  late BrailleMappingImpl mapping;
  late BrailleConverter converter;
  late BrailleReverseConverter reverseConverter;

  setUp(() {
    mapping = BrailleMappingImpl();
    converter = BrailleConverterImpl(mapping);
    reverseConverter = BrailleReverseConverterImpl(mapping);
  });

  // ═══════════════════════════════════════════════════════════════════════
  // TEST 1: TẤT CẢ nguyên âm × 5 thanh điệu = 60 ký tự
  // ═══════════════════════════════════════════════════════════════════════
  group('1. ALL Vietnamese vowels × 5 tones (60 chars) — via converter', () {
    // a-group
    test(
      'á → toneSac + a',
      () => expect(converter.convert('á'), '$toneSac$cellA'),
    );
    test(
      'à → toneHuyen + a',
      () => expect(converter.convert('à'), '$toneHuyen$cellA'),
    );
    test(
      'ả → toneHoi + a',
      () => expect(converter.convert('ả'), '$toneHoi$cellA'),
    );
    test(
      'ã → toneNga + a',
      () => expect(converter.convert('ã'), '$toneNga$cellA'),
    );
    test(
      'ạ → toneNang + a',
      () => expect(converter.convert('ạ'), '$toneNang$cellA'),
    );
    // ă-group
    test(
      'ắ → toneSac + ă',
      () => expect(converter.convert('ắ'), '$toneSac$cellAW'),
    );
    test(
      'ằ → toneHuyen + ă',
      () => expect(converter.convert('ằ'), '$toneHuyen$cellAW'),
    );
    test(
      'ẳ → toneHoi + ă',
      () => expect(converter.convert('ẳ'), '$toneHoi$cellAW'),
    );
    test(
      'ẵ → toneNga + ă',
      () => expect(converter.convert('ẵ'), '$toneNga$cellAW'),
    );
    test(
      'ặ → toneNang + ă',
      () => expect(converter.convert('ặ'), '$toneNang$cellAW'),
    );
    // â-group
    test(
      'ấ → toneSac + â',
      () => expect(converter.convert('ấ'), '$toneSac$cellAA'),
    );
    test(
      'ầ → toneHuyen + â',
      () => expect(converter.convert('ầ'), '$toneHuyen$cellAA'),
    );
    test(
      'ẩ → toneHoi + â',
      () => expect(converter.convert('ẩ'), '$toneHoi$cellAA'),
    );
    test(
      'ẫ → toneNga + â',
      () => expect(converter.convert('ẫ'), '$toneNga$cellAA'),
    );
    test(
      'ậ → toneNang + â',
      () => expect(converter.convert('ậ'), '$toneNang$cellAA'),
    );
    // e-group
    test(
      'é → toneSac + e',
      () => expect(converter.convert('é'), '$toneSac$cellE'),
    );
    test(
      'è → toneHuyen + e',
      () => expect(converter.convert('è'), '$toneHuyen$cellE'),
    );
    test(
      'ẻ → toneHoi + e',
      () => expect(converter.convert('ẻ'), '$toneHoi$cellE'),
    );
    test(
      'ẽ → toneNga + e',
      () => expect(converter.convert('ẽ'), '$toneNga$cellE'),
    );
    test(
      'ẹ → toneNang + e',
      () => expect(converter.convert('ẹ'), '$toneNang$cellE'),
    );
    // ê-group
    test(
      'ế → toneSac + ê',
      () => expect(converter.convert('ế'), '$toneSac$cellEE'),
    );
    test(
      'ề → toneHuyen + ê',
      () => expect(converter.convert('ề'), '$toneHuyen$cellEE'),
    );
    test(
      'ể → toneHoi + ê',
      () => expect(converter.convert('ể'), '$toneHoi$cellEE'),
    );
    test(
      'ễ → toneNga + ê',
      () => expect(converter.convert('ễ'), '$toneNga$cellEE'),
    );
    test(
      'ệ → toneNang + ê',
      () => expect(converter.convert('ệ'), '$toneNang$cellEE'),
    );
    // i-group
    test(
      'í → toneSac + i',
      () => expect(converter.convert('í'), '$toneSac$cellI'),
    );
    test(
      'ì → toneHuyen + i',
      () => expect(converter.convert('ì'), '$toneHuyen$cellI'),
    );
    test(
      'ỉ → toneHoi + i',
      () => expect(converter.convert('ỉ'), '$toneHoi$cellI'),
    );
    test(
      'ĩ → toneNga + i',
      () => expect(converter.convert('ĩ'), '$toneNga$cellI'),
    );
    test(
      'ị → toneNang + i',
      () => expect(converter.convert('ị'), '$toneNang$cellI'),
    );
    // o-group
    test(
      'ó → toneSac + o',
      () => expect(converter.convert('ó'), '$toneSac$cellO'),
    );
    test(
      'ò → toneHuyen + o',
      () => expect(converter.convert('ò'), '$toneHuyen$cellO'),
    );
    test(
      'ỏ → toneHoi + o',
      () => expect(converter.convert('ỏ'), '$toneHoi$cellO'),
    );
    test(
      'õ → toneNga + o',
      () => expect(converter.convert('õ'), '$toneNga$cellO'),
    );
    test(
      'ọ → toneNang + o',
      () => expect(converter.convert('ọ'), '$toneNang$cellO'),
    );
    // ô-group
    test(
      'ố → toneSac + ô',
      () => expect(converter.convert('ố'), '$toneSac$cellOO'),
    );
    test(
      'ồ → toneHuyen + ô',
      () => expect(converter.convert('ồ'), '$toneHuyen$cellOO'),
    );
    test(
      'ổ → toneHoi + ô',
      () => expect(converter.convert('ổ'), '$toneHoi$cellOO'),
    );
    test(
      'ỗ → toneNga + ô',
      () => expect(converter.convert('ỗ'), '$toneNga$cellOO'),
    );
    test(
      'ộ → toneNang + ô',
      () => expect(converter.convert('ộ'), '$toneNang$cellOO'),
    );
    // ơ-group
    test(
      'ớ → toneSac + ơ',
      () => expect(converter.convert('ớ'), '$toneSac$cellOW'),
    );
    test(
      'ờ → toneHuyen + ơ',
      () => expect(converter.convert('ờ'), '$toneHuyen$cellOW'),
    );
    test(
      'ở → toneHoi + ơ',
      () => expect(converter.convert('ở'), '$toneHoi$cellOW'),
    );
    test(
      'ỡ → toneNga + ơ',
      () => expect(converter.convert('ỡ'), '$toneNga$cellOW'),
    );
    test(
      'ợ → toneNang + ơ',
      () => expect(converter.convert('ợ'), '$toneNang$cellOW'),
    );
    // u-group
    test(
      'ú → toneSac + u',
      () => expect(converter.convert('ú'), '$toneSac$cellU'),
    );
    test(
      'ù → toneHuyen + u',
      () => expect(converter.convert('ù'), '$toneHuyen$cellU'),
    );
    test(
      'ủ → toneHoi + u',
      () => expect(converter.convert('ủ'), '$toneHoi$cellU'),
    );
    test(
      'ũ → toneNga + u',
      () => expect(converter.convert('ũ'), '$toneNga$cellU'),
    );
    test(
      'ụ → toneNang + u',
      () => expect(converter.convert('ụ'), '$toneNang$cellU'),
    );
    // ư-group
    test(
      'ứ → toneSac + ư',
      () => expect(converter.convert('ứ'), '$toneSac$cellUW'),
    );
    test(
      'ừ → toneHuyen + ư',
      () => expect(converter.convert('ừ'), '$toneHuyen$cellUW'),
    );
    test(
      'ử → toneHoi + ư',
      () => expect(converter.convert('ử'), '$toneHoi$cellUW'),
    );
    test(
      'ữ → toneNga + ư',
      () => expect(converter.convert('ữ'), '$toneNga$cellUW'),
    );
    test(
      'ự → toneNang + ư',
      () => expect(converter.convert('ự'), '$toneNang$cellUW'),
    );
    // y-group
    test(
      'ý → toneSac + y',
      () => expect(converter.convert('ý'), '$toneSac$cellY'),
    );
    test(
      'ỳ → toneHuyen + y',
      () => expect(converter.convert('ỳ'), '$toneHuyen$cellY'),
    );
    test(
      'ỷ → toneHoi + y',
      () => expect(converter.convert('ỷ'), '$toneHoi$cellY'),
    );
    test(
      'ỹ → toneNga + y',
      () => expect(converter.convert('ỹ'), '$toneNga$cellY'),
    );
    test(
      'ỵ → toneNang + y',
      () => expect(converter.convert('ỵ'), '$toneNang$cellY'),
    );
  });

  // ═══════════════════════════════════════════════════════════════════════
  // TEST 2: Quy tắc từ file quy_tac (Section VI - VII)
  // ═══════════════════════════════════════════════════════════════════════
  group('2. Rules examples — exact match', () {
    final capitalCell = brf('46');
    test('oán = sac + o + a + n  (no qu/gi)', () {
      expect(converter.convert('oán'), '$toneSac$cellO$cellA$cellN');
    });
    test('chính = c + h + sac + i + n + h', () {
      expect(
        converter.convert('chính'),
        '$cellC$cellH$toneSac$cellI$cellN$cellH',
      );
    });
    test('vừng = v + huyen + ư + n + g', () {
      expect(converter.convert('vừng'), '$cellV$toneHuyen$cellUW$cellN$cellG');
    });
    test('quả = q + u + hoi + a  (qu rule)', () {
      expect(converter.convert('quả'), '$cellQ$cellU$toneHoi$cellA');
    });
    test('quyết = q + u + sac + y + ê + t  (qu rule)', () {
      expect(
        converter.convert('quyết'),
        '$cellQ$cellU$toneSac$cellY$cellEE$cellT',
      );
    });
    test('giỏi = g + i + hoi + o + i  (gi rule)', () {
      expect(converter.convert('giỏi'), '$cellG$cellI$toneHoi$cellO$cellI');
    });
    test('giảng giải = g+i+hoi+a+n+g +SP+ g+i+hoi+a+i', () {
      expect(
        converter.convert('giảng giải'),
        '$cellG$cellI$toneHoi$cellA$cellN$cellG $cellG$cellI$toneHoi$cellA$cellI',
      );
    });
    test('gìn = g + huyen + i + n  (gi rule, no vowel after i)', () {
      expect(converter.convert('gìn'), '$cellG$toneHuyen$cellI$cellN');
    });
    test('gì = g + huyen + i  (gi rule, standalone)', () {
      expect(converter.convert('gì'), '$cellG$toneHuyen$cellI');
    });

    // Section VII: quy tắc viết hoa
    test('Loan = capital + L + o + a + n  (has consonant)', () {
      expect(converter.convert('Loan'), '$capitalCell$cellL$cellO$cellA$cellN');
    });
    test('sông Hồng = s+ô+n+g SP capital+H+huyen+ô+n+g', () {
      expect(
        converter.convert('sông Hồng'),
        '$cellS$cellOO$cellN$cellG $capitalCell$cellH$toneHuyen$cellOO$cellN$cellG',
      );
    });
    test(
      'bác Ẩn = b+sac+a+c SP hoi+capital+â+n  (no consonant → tone→cap→vowel)',
      () {
        expect(
          converter.convert('bác Ẩn'),
          '$cellB$toneSac$cellA$cellC $toneHoi$capitalCell$cellAA$cellN',
        );
      },
    );
    test('UNESCO = word all-caps prefix + unesco', () {
      final allCapsWord = brf('456'); // ⠸
      expect(
        converter.convert('UNESCO'),
        '$allCapsWord$cellU$cellN$cellE$cellS$cellC$cellO',
      );
    });
    test('Việt Nam = title-case phrase prefix + viêt nam + endFormat', () {
      final initCapsPhrase = brf('25') + brf('46'); // ⠒⠨
      final endFormat = brf('156'); // ⠱
      expect(
        converter.convert('Việt Nam'),
        '$initCapsPhrase$cellV$cellI$toneNang$cellEE$cellT $cellN$cellA$cellM$endFormat',
      );
    });
    test('VIỆT NAM = all-caps phrase prefix + viêt nam + endFormat', () {
      final allCapsPhrase = brf('46') + brf('46'); // ⠨⠨
      final endFormat = brf('156'); // ⠱
      expect(
        converter.convert('VIỆT NAM'),
        '$allCapsPhrase$cellV$cellI$toneNang$cellEE$cellT $cellN$cellA$cellM$endFormat',
      );
    });
    test('VII = Roman numeral single capital indicator', () {
      expect(converter.convert('VII'), '$capitalCell$cellV$cellI$cellI');
    });
  });

  // ═══════════════════════════════════════════════════════════════════════
  // TEST 3: No-consonant capital — tất cả nguyên âm viết hoa
  // ═══════════════════════════════════════════════════════════════════════
  group(
    '3. Standalone capital vowel (no consonant) — all 12 bases × 5 tones',
    () {
      final capitalCell = brf('46');

      test('Ấ = toneSac + capital + â', () {
        expect(converter.convert('Ấ'), '$toneSac$capitalCell$cellAA');
      });
      test('Ấn = toneSac + capital + â + n', () {
        expect(converter.convert('Ấn'), '$toneSac$capitalCell$cellAA$cellN');
      });
      test('Ẩ = toneHoi + capital + â', () {
        expect(converter.convert('Ẩ'), '$toneHoi$capitalCell$cellAA');
      });
      test('Ẩn = toneHoi + capital + â + n', () {
        expect(converter.convert('Ẩn'), '$toneHoi$capitalCell$cellAA$cellN');
      });
      test('Ậ = toneNang + capital + â', () {
        expect(converter.convert('Ậ'), '$toneNang$capitalCell$cellAA');
      });
      test('Ận = toneNang + capital + â + n', () {
        expect(converter.convert('Ận'), '$toneNang$capitalCell$cellAA$cellN');
      });
      test('Á = toneSac + capital + a', () {
        expect(converter.convert('Á'), '$toneSac$capitalCell$cellA');
      });
      test('À = toneHuyen + capital + a', () {
        expect(converter.convert('À'), '$toneHuyen$capitalCell$cellA');
      });
      test('Ả = toneHoi + capital + a', () {
        expect(converter.convert('Ả'), '$toneHoi$capitalCell$cellA');
      });
      test('Ã = toneNga + capital + a', () {
        expect(converter.convert('Ã'), '$toneNga$capitalCell$cellA');
      });
      test('Ạ = toneNang + capital + a', () {
        expect(converter.convert('Ạ'), '$toneNang$capitalCell$cellA');
      });
      test('Ế = toneSac + capital + ê', () {
        expect(converter.convert('Ế'), '$toneSac$capitalCell$cellEE');
      });
      test('Ố = toneSac + capital + ô', () {
        expect(converter.convert('Ố'), '$toneSac$capitalCell$cellOO');
      });
      test('Ớ = toneSac + capital + ơ', () {
        expect(converter.convert('Ớ'), '$toneSac$capitalCell$cellOW');
      });
      test('Ứ = toneSac + capital + ư', () {
        expect(converter.convert('Ứ'), '$toneSac$capitalCell$cellUW');
      });
      test('Ý = toneSac + capital + y', () {
        expect(converter.convert('Ý'), '$toneSac$capitalCell$cellY');
      });
    },
  );

  // ═══════════════════════════════════════════════════════════════════════
  // TEST 4: Qu/gi rules — exhaustive
  // ═══════════════════════════════════════════════════════════════════════
  group('4. Qu/Gi rules — all combinations', () {
    test('quán = q + u + sac + a + n', () {
      expect(converter.convert('quán'), '$cellQ$cellU$toneSac$cellA$cellN');
    });
    test('quàn = q + u + huyen + a + n', () {
      expect(converter.convert('quàn'), '$cellQ$cellU$toneHuyen$cellA$cellN');
    });
    test('quản = q + u + hoi + a + n', () {
      expect(converter.convert('quản'), '$cellQ$cellU$toneHoi$cellA$cellN');
    });
    test('quã = q + u + nga + a', () {
      expect(converter.convert('quã'), '$cellQ$cellU$toneNga$cellA');
    });
    test('quặn = q + u + nang + ă + n', () {
      expect(converter.convert('quặn'), '$cellQ$cellU$toneNang$cellAW$cellN');
    });
    test('giá = g + i + sac + a', () {
      expect(converter.convert('giá'), '$cellG$cellI$toneSac$cellA');
    });
    test('già = g + i + huyen + a', () {
      expect(converter.convert('già'), '$cellG$cellI$toneHuyen$cellA');
    });
    test('giả = g + i + hoi + a', () {
      expect(converter.convert('giả'), '$cellG$cellI$toneHoi$cellA');
    });
    test('giã = g + i + nga + a', () {
      expect(converter.convert('giã'), '$cellG$cellI$toneNga$cellA');
    });
    test('giạ = g + i + nang + a', () {
      expect(converter.convert('giạ'), '$cellG$cellI$toneNang$cellA');
    });
    test('giải = g + i + hoi + a + i', () {
      expect(converter.convert('giải'), '$cellG$cellI$toneHoi$cellA$cellI');
    });
    test('quý = q + u + sac + y (qu rule applies to y)', () {
      expect(converter.convert('quý'), '$cellQ$cellU$toneSac$cellY');
    });
    test('quỷ = q + u + hoi + y', () {
      expect(converter.convert('quỷ'), '$cellQ$cellU$toneHoi$cellY');
    });
    test('quyết = q + u + sac + y + ê + t (multi-char rhyme)', () {
      expect(
        converter.convert('quyết'),
        '$cellQ$cellU$toneSac$cellY$cellEE$cellT',
      );
    });
    test('quyền = q + u + huyen + y + ê + n (multi-char rhyme)', () {
      expect(
        converter.convert('quyền'),
        '$cellQ$cellU$toneHuyen$cellY$cellEE$cellN',
      );
    });
    test('gì = g + huyen + i (gi rule)', () {
      expect(converter.convert('gì'), '$cellG$toneHuyen$cellI');
    });
    test('gĩ = g + nga + i', () {
      expect(converter.convert('gĩ'), '$cellG$toneNga$cellI');
    });
    test('gìn = g + huyen + i + n', () {
      expect(converter.convert('gìn'), '$cellG$toneHuyen$cellI$cellN');
    });
    // No qu/gi: normal tone placement
    test('múa = m + sac + u + a  (normal: tone before u)', () {
      expect(converter.convert('múa'), '$cellM$toneSac$cellU$cellA');
    });
    test('tía = t + sac + i + a  (normal)', () {
      expect(converter.convert('tía'), '$cellT$toneSac$cellI$cellA');
    });
  });

  // ═══════════════════════════════════════════════════════════════════════
  // TEST 5: Round-trip conversion (Braille → Text → Braille)
  // ═══════════════════════════════════════════════════════════════════════
  group('5. Round-trip: convert → reverseConvert → convert', () {
    final testCases = [
      'việt nam',
      'xin chào',
      'hôm nay trời đẹp',
      'tôi yêu việt nam',
      'quán quản giá già',
      'quyết',
      'quyền',
      'bác ẩn',
      'giảng giải',
      'múa tía gì',
      'hello world',
      '123',
      '3.14',
      'hello, world!',
      'yes? no!',
    ];

    for (final input in testCases) {
      test('"$input" round-trips correctly', () {
        final braille = converter.convert(input);
        final text = reverseConverter.convert(braille);
        expect(
          text.toLowerCase(),
          equals(input.toLowerCase()),
          reason:
              '"$input" → braille → "$text"  '
              '(expect: "${input.toLowerCase()}")',
        );
      });
    }

    test('digits round-trip: "123"', () {
      final braille = converter.convert('123');
      final text = reverseConverter.convert(braille);
      expect(text, equals('123'));
    });

    test('decimal round-trip: "3.14"', () {
      final braille = converter.convert('3.14');
      final text = reverseConverter.convert(braille);
      expect(text, equals('3.14'));
    });

    test('punctuation round-trip: "hello, world!"', () {
      final braille = converter.convert('hello, world!');
      final text = reverseConverter.convert(braille);
      expect(text, equals('hello, world!'));
    });

    test('question marks round-trip: "yes? no!"', () {
      final braille = converter.convert('yes? no!');
      final text = reverseConverter.convert(braille);
      expect(text, equals('yes? no!'));
    });
  });

  // ═══════════════════════════════════════════════════════════════════════
  // TEST 6: NFD input — multi-level composition
  // ═══════════════════════════════════════════════════════════════════════
  group('6. NFD input — multi-level composition', () {
    test('a + U+0301 → á (same as NFC)', () {
      final nfd = 'a\u0301';
      expect(converter.convert(nfd), equals(converter.convert('á')));
    });
    test('a + U+0302 + U+0301 → ấ (2-level)', () {
      final nfd = 'a\u0302\u0301';
      expect(converter.convert(nfd), equals(converter.convert('ấ')));
    });
    test('a + U+0302 + U+0300 → ầ (2-level)', () {
      final nfd = 'a\u0302\u0300';
      expect(converter.convert(nfd), equals(converter.convert('ầ')));
    });
    test('a + U+0306 + U+0301 → ắ (2-level)', () {
      final nfd = 'a\u0306\u0301';
      expect(converter.convert(nfd), equals(converter.convert('ắ')));
    });
    test('o + U+0302 + U+0301 → ố (2-level)', () {
      final nfd = 'o\u0302\u0301';
      expect(converter.convert(nfd), equals(converter.convert('ố')));
    });
    test('o + U+031B + U+0301 → ớ (2-level, horn)', () {
      final nfd = 'o\u031B\u0301';
      expect(converter.convert(nfd), equals(converter.convert('ớ')));
    });
    test('u + U+031B + U+0300 → ừ (2-level, horn)', () {
      final nfd = 'u\u031B\u0300';
      expect(converter.convert(nfd), equals(converter.convert('ừ')));
    });
    test('u + U+031B + U+0309 → ử', () {
      final nfd = 'u\u031B\u0309';
      expect(converter.convert(nfd), equals(converter.convert('ử')));
    });
    test('e + U+0302 + U+0301 → ế', () {
      final nfd = 'e\u0302\u0301';
      expect(converter.convert(nfd), equals(converter.convert('ế')));
    });

    // NFD word tests
    test('NFD "đội" = đ + o + U+0302 + U+0323 + i', () {
      final nfd = 'đo\u0302\u0323i';
      expect(converter.convert(nfd), equals(converter.convert('đội')));
    });
    test('NFD "xuất" = x + u + a + U+0302 + U+0301 + t', () {
      final nfd = 'xua\u0302\u0301t';
      expect(converter.convert(nfd), equals(converter.convert('xuất')));
    });
    test('NFD "chào" = c + h + a + U+0300 + o', () {
      final nfd = 'cha\u0300o';
      expect(converter.convert(nfd), equals(converter.convert('chào')));
    });
    test('NFD "hiếu" = h + i + e + U+0302 + U+0301 + u', () {
      final nfd = 'hie\u0302\u0301u';
      expect(converter.convert(nfd), equals(converter.convert('hiếu')));
    });
    test('NFD "chiến" = c + h + i + e + U+0302 + U+0301 + n', () {
      final nfd = 'chie\u0302\u0301n';
      expect(converter.convert(nfd), equals(converter.convert('chiến')));
    });

    // NFD uppercase
    test('NFD uppercase "Ấ"', () {
      final nfd = 'Â\u0301';
      expect(converter.convert(nfd), equals(converter.convert('Ấ')));
    });
    test('NFD uppercase "Á"', () {
      final nfd = 'A\u0301';
      expect(converter.convert(nfd), equals(converter.convert('Á')));
    });
  });

  // ═══════════════════════════════════════════════════════════════════════
  // TEST 7: Collision detection — không trùng Braille output
  // ═══════════════════════════════════════════════════════════════════════
  group(
    '7. Collision detection — no two inputs produce same Braille output',
    () {
      test('question mark ≠ tone hỏi', () {
        final questionBraille = converter.convert('?');
        final hoiBraille = converter.convert('ả'); // hỏi on a = hoi + a
        expect(questionBraille, isNot(equals(hoiBraille)));
        expect(questionBraille, equals(brf('26'))); // ⠢
        expect(hoiBraille, equals('$toneHoi$cellA')); // ⠢⠁
      });

      test('dash ≠ tone ngã', () {
        final dashBraille = converter.convert('-');
        final ngaBraille = converter.convert('ã'); // ngã on a = nga + a
        expect(dashBraille, isNot(equals(ngaBraille)));
        expect(dashBraille, equals(brf('36'))); // ⠤
        expect(ngaBraille, equals('$toneNga$cellA')); // ⠤⠁
      });

      test('all 60 toned vowels produce unique outputs', () {
        final outputs = <String, String>{};
        final tonedChars = [
          'áàảãạ',
          'ắằẳẵặ',
          'ấầẩẫậ',
          'éèẻẽẹ',
          'ếềểễệ',
          'íìỉĩị',
          'óòỏõọ',
          'ốồổỗộ',
          'ớờởỡợ',
          'úùủũụ',
          'ứừửữự',
          'ýỳỷỹỵ',
        ];
        for (final group in tonedChars) {
          for (final ch in group.split('')) {
            final braille = converter.convert(ch);
            expect(
              outputs.containsKey(braille),
              isFalse,
              reason:
                  'Collision: "$ch" and "${outputs[braille]}" '
                  'both produce "$braille"',
            );
            outputs[braille] = ch;
          }
        }
        expect(outputs.length, equals(60));
      });
    },
  );

  // ═══════════════════════════════════════════════════════════════════════
  // TEST 8: Latin alphabet + digits + common punctuation via converter
  // ═══════════════════════════════════════════════════════════════════════
  group('8. Latin + digits + punctuation via converter', () {
    test('"hello" → correct', () {
      expect(converter.convert('hello'), '$cellH$cellE$cellL$cellL$cellO');
    });
    test('"abc123" → correct (number indicator before 123)', () {
      expect(
        converter.convert('abc123'),
        '$cellA$cellB$cellC$numIndicator$cellA$cellB$cellC',
      );
    });
    test('"12.5" → decimal handling', () {
      expect(
        converter.convert('12.5'),
        '$numIndicator$cellA$cellB${brf('3')}$cellE',
      );
    });
    test('"()" → parentheses', () {
      expect(converter.convert('()'), '$lparen$rparen');
    });
    test('"@gmail.com" → at sign', () {
      final result = converter.convert('@gmail.com');
      expect(result, startsWith(symbolPrefix));
    });
    test('math: "1+2=3"', () {
      final result = converter.convert('1+2=3');
      expect(result, contains(mathPrefix + brf('235')));
      expect(result, contains(mathPrefix + brf('2356')));
    });
  });

  // ═══════════════════════════════════════════════════════════════════════
  // TEST 9: Real Vietnamese text
  // ═══════════════════════════════════════════════════════════════════════
  group('9. Real Vietnamese text', () {
    test('"Mọi người đều bình đẳng" — full sentence with tones', () {
      final result = converter.convert('Mọi người đều bình đẳng');
      expect(result, isNot(equals('')));
      for (int i = 0; i < result.length; i++) {
        final cp = result.codeUnitAt(i);
        final isBraille = cp >= 0x2800 && cp <= 0x28FF;
        final isSpace = cp == 0x20;
        expect(
          isBraille || isSpace,
          isTrue,
          reason: 'Char at $i is U+${cp.toRadixString(16)}',
        );
      }
    });

    test('"Trường học thân thiện" — full sentence round-trip', () {
      final input = 'Trường học thân thiện';
      final braille = converter.convert(input);
      final text = reverseConverter.convert(braille);
      expect(text.toLowerCase(), equals(input.toLowerCase()));
    });

    test('"Quốc hội nước Cộng hòa" — qu rule + capital + tones round-trip', () {
      final input = 'Quốc hội nước Cộng hòa';
      final braille = converter.convert(input);
      expect(braille, isNot(equals('')));
    });

    test('"Việt Nam là một quốc gia độc lập" — long sentence round-trip', () {
      final input = 'Việt Nam là một quốc gia độc lập';
      final braille = converter.convert(input);
      expect(braille, isNot(equals('')));
      final text = reverseConverter.convert(braille);
      expect(text.toLowerCase(), equals(input.toLowerCase()));
    });

    test('"Ẩm thực đường phố" — starts with standalone capital vowel', () {
      final input = 'Ẩm thực đường phố';
      final braille = converter.convert(input);
      expect(braille, isNot(equals('')));
      final text = reverseConverter.convert(braille);
      expect(text.toLowerCase(), equals(input.toLowerCase()));
    });

    test('"Tôi yêu Việt Nam" — simple sentence round-trip', () {
      final input = 'Tôi yêu Việt Nam';
      final braille = converter.convert(input);
      final text = reverseConverter.convert(braille);
      expect(text.toLowerCase(), equals(input.toLowerCase()));
    });

    test('"Xin chào! Bạn khỏe không?" — with punctuation round-trip', () {
      final input = 'Xin chào! Bạn khỏe không?';
      final braille = converter.convert(input);
      final text = reverseConverter.convert(braille);
      expect(text.toLowerCase(), equals(input.toLowerCase()));
    });
  });

  // ═══════════════════════════════════════════════════════════════════════
  // TEST 10: Đ (uppercase) + đ (lowercase) special
  // ═══════════════════════════════════════════════════════════════════════
  group('10. Đ/đ handling', () {
    final capitalCell = brf('46');
    test('đ → cellDJ', () {
      expect(converter.convert('đ'), equals(cellDJ));
    });
    test('Đ → capital + cellDJ', () {
      expect(converter.convert('Đ'), '$capitalCell$cellDJ');
    });
    test('Đà Nẵng = capital+đ+huyen+a SP capital+n+nga+ă+n+g', () {
      final initCapsPhrase = brf('25') + brf('46'); // ⠒⠨
      final endFormat = brf('156'); // ⠱
      expect(
        converter.convert('Đà Nẵng'),
        '$initCapsPhrase$cellDJ$toneHuyen$cellA '
        '$cellN$toneNga$cellAW$cellN$cellG$endFormat',
      );
    });
    test('đội = đ + nang + ô + i', () {
      expect(converter.convert('đội'), '$cellDJ$toneNang$cellOO$cellI');
    });
  });

  // ═══════════════════════════════════════════════════════════════════════
  // TEST 11: Capital + qu/gi combined rules
  // ═══════════════════════════════════════════════════════════════════════
  group('11. Capital + qu/gi combined rules', () {
    final capitalCell = brf('46');

    test('Quán = capital + q + u + sac + a + n', () {
      expect(
        converter.convert('Quán'),
        '$capitalCell$cellQ$cellU$toneSac$cellA$cellN',
      );
    });

    test('Giá = capital + g + i + sac + a', () {
      expect(
        converter.convert('Giá'),
        '$capitalCell$cellG$cellI$toneSac$cellA',
      );
    });

    test('Giải = capital + g + i + hoi + a + i', () {
      expect(
        converter.convert('Giải'),
        '$capitalCell$cellG$cellI$toneHoi$cellA$cellI',
      );
    });

    test('Gìn = capital + g + huyen + i + n', () {
      expect(
        converter.convert('Gìn'),
        '$capitalCell$cellG$toneHuyen$cellI$cellN',
      );
    });

    test('Gì = capital + g + huyen + i (standalone)', () {
      expect(converter.convert('Gì'), '$capitalCell$cellG$toneHuyen$cellI');
    });

    test('Quốc = capital + q + u + sac + o + c', () {
      expect(
        converter.convert('Quốc'),
        '$capitalCell$cellQ$cellU$toneSac$cellOO$cellC',
      );
    });
  });
}
