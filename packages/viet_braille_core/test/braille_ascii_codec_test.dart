import 'package:test/test.dart';
import 'package:viet_braille_core/viet_braille_core.dart';

void main() {
  late NabccBrailleAsciiCodec codec;

  setUp(() {
    codec = NabccBrailleAsciiCodec();
  });

  group('NABCC Braille ASCII', () {
    const fixtures = <String, String>{
      '⠀': ' ',
      '⠁': 'A',
      '⠃': 'B',
      '⠉': 'C',
      '⠙': 'D',
      '⠑': 'E',
      '⠋': 'F',
      '⠛': 'G',
      '⠓': 'H',
      '⠊': 'I',
      '⠚': 'J',
      '⠅': 'K',
      '⠇': 'L',
      '⠍': 'M',
      '⠝': 'N',
      '⠕': 'O',
      '⠏': 'P',
      '⠟': 'Q',
      '⠗': 'R',
      '⠎': 'S',
      '⠞': 'T',
      '⠥': 'U',
      '⠧': 'V',
      '⠺': 'W',
      '⠭': 'X',
      '⠽': 'Y',
      '⠵': 'Z',
      '⠼': '#',
      '⠤': '-',
      '⠢': '5',
      '⠈': '@',
      '⠿': '=',
    };

    test('matches independent NABCC fixtures', () {
      for (final entry in fixtures.entries) {
        expect(codec.encode(entry.key), entry.value, reason: entry.key);
      }
    });

    test('round-trips every non-empty six-dot cell', () {
      for (var dots = 1; dots <= 0x3f; dots++) {
        final unicode = String.fromCharCode(0x2800 + dots);
        expect(codec.decode(codec.encode(unicode)), unicode);
      }
    });

    test('preserves BRF layout controls', () {
      expect(codec.encode('⠁\r\n⠃\f⠉'), 'A\r\nB\fC');
      expect(codec.decode('A\r\nB\fC'), '⠁\r\n⠃\f⠉');
    });

    test('rejects dot 7/8 patterns and print text', () {
      expect(() => codec.encode('⡁'), throwsFormatException);
      expect(() => codec.encode('abc'), throwsFormatException);
    });

    test('rejects lowercase and non-BRF ASCII', () {
      expect(codec.isValid('ABC #-\r\n\f'), isTrue);
      expect(codec.isValid('abc'), isFalse);
      expect(() => codec.decode('a'), throwsFormatException);
    });
  });

  group('BRF formatter', () {
    late BrfFormatter formatter;

    setUp(() {
      formatter = BrfFormatterImpl(codec: codec);
    });

    test('encodes Unicode Braille before wrapping', () {
      expect(formatter.format('⠓⠑⠇⠇⠕'), 'HELLO\n');
    });

    test('preserves repeated spaces when no wrap is needed', () {
      expect(formatter.format('⠁  ⠃'), 'A  B\n');
    });

    test('wraps at a word boundary and keeps trailing newline', () {
      expect(formatter.format('⠁⠃⠉ ⠙⠑⠋', lineLength: 4), 'ABC\nDEF\n');
    });

    test('preserves logical blank lines', () {
      expect(formatter.format('⠁\n\n⠃'), 'A\n\nB\n');
    });

    test('rejects non-positive line length without hanging', () {
      expect(() => formatter.format('⠁', lineLength: 0), throwsArgumentError);
      expect(() => formatter.format('⠁', lineLength: -1), throwsArgumentError);
    });
  });
}
