import 'package:flutter_test/flutter_test.dart';
import 'package:viet_braille_app/domain/brf_formatter.dart';

void main() {
  late BrfFormatterImpl formatter;

  setUp(() {
    formatter = BrfFormatterImpl();
  });

  // ══════════════════════════════════════════════════════════════════════
  // Empty / whitespace input
  // ══════════════════════════════════════════════════════════════════════
  group('empty and whitespace', () {
    test('empty string → newline', () {
      expect(formatter.format(''), equals('\n'));
    });

    test('only spaces → newline', () {
      expect(formatter.format('   '), equals('\n'));
    });

    test('only newlines → preserves structure + trailing newline', () {
      // '\n' splits to ['', ''] → 1 inter-line \n, already ends with \n so no extra
      expect(formatter.format('\n'), equals('\n'));
      // '\n\n' splits to ['', '', ''] → 2 inter-line \n, already ends with \n so no extra
      expect(formatter.format('\n\n'), equals('\n\n'));
    });
  });

  // ══════════════════════════════════════════════════════════════════════
  // Short text (< lineLength) — no wrapping needed
  // ══════════════════════════════════════════════════════════════════════
  group('short text — no wrapping', () {
    test('single word under 40 chars', () {
      expect(formatter.format('hello'), equals('hello\n'));
    });

    test('multiple words under 40 chars total', () {
      expect(formatter.format('hello world'), equals('hello world\n'));
    });

    test('exactly 40 chars (single word)', () {
      final text = 'a' * 40;
      expect(formatter.format(text), equals('$text\n'));
    });

    test('two words that sum to 40 with space → fit on one line', () {
      // 20 a's + space + 19 b's = 40 chars → fits
      final text = '${'a' * 20} ${'b' * 19}';
      expect(formatter.format(text), equals('$text\n'));
    });

    test('two words that exceed 40 with space → wrap', () {
      // "abcde fghij" = 5+1+5 = 11 > 10 → wraps
      final text = '${'a' * 20} ${'b' * 20}';
      final result = formatter.format(text);
      expect(result, equals('${'a' * 20}\n${'b' * 20}\n'));
    });
  });

  // ══════════════════════════════════════════════════════════════════════
  // Line wrapping — doesn't cut words
  // ══════════════════════════════════════════════════════════════════════
  group('line wrapping', () {
    test('wraps between words, not inside', () {
      // "abcdef ghijklm nopqrst" with lineLength=10
      // "abcdef" (6) + " " + "ghijklm" (7) = 14 > 10 → wrap after "abcdef"
      final result = formatter.format('abcdef ghijklm nopqrst', lineLength: 10);
      expect(result, equals('abcdef\nghijklm\nnopqrst\n'));
    });

    test('word exactly fits on line', () {
      // "abcd fghij" with lineLength=10: 4+1+5 = 10 ≤ 10 → same line
      final result = formatter.format('abcd fghij', lineLength: 10);
      expect(result, equals('abcd fghij\n'));
    });

    test('word barely doesn\'t fit → wrap', () {
      // "abcde fghijk" with lineLength=10
      // "abcde" (5) + " " + "fghijk" (6) = 12 > 10 → wrap
      final result = formatter.format('abcde fghijk', lineLength: 10);
      expect(result, equals('abcde\nfghijk\n'));
    });

    test('single word longer than lineLength → split into chunks', () {
      final result = formatter.format('abcdefghijklmnop', lineLength: 5);
      expect(result, equals('abcde\nfghij\nklmno\np\n'));
    });

    test('default lineLength is 40', () {
      final words = List.generate(10, (i) => 'word${i + 1}').join(' ');
      final result = formatter.format(words);
      final lines = result.split('\n').where((l) => l.isNotEmpty).toList();
      for (final line in lines) {
        expect(
          line.length,
          lessThanOrEqualTo(40),
          reason: 'Line "$line" exceeds 40 chars',
        );
      }
    });
  });

  // ══════════════════════════════════════════════════════════════════════
  // Multiple logical lines (separated by \n)
  // ══════════════════════════════════════════════════════════════════════
  group('multiple logical lines', () {
    test('two short lines preserved', () {
      final result = formatter.format('hello\nworld');
      expect(result, equals('hello\nworld\n'));
    });

    test('each logical line wraps independently', () {
      // "abcdefghij klmnopqrst" + \n + "uvwx yz"
      // With lineLength=10: first line wraps, second doesn't
      final result = formatter.format(
        'abcdefghij klmnopqrst\nuvwx yz',
        lineLength: 10,
      );
      expect(result, equals('abcdefghij\nklmnopqrst\nuvwx yz\n'));
    });

    test('empty logical lines preserved', () {
      final result = formatter.format('hello\n\nworld');
      expect(result, equals('hello\n\nworld\n'));
    });
  });

  // ══════════════════════════════════════════════════════════════════════
  // Multiple spaces → collapsed
  // ══════════════════════════════════════════════════════════════════════
  group('multiple spaces', () {
    test('double space collapsed to single', () {
      final result = formatter.format('hello  world');
      expect(result, equals('hello world\n'));
    });

    test('triple space collapsed to single', () {
      final result = formatter.format('a   b');
      expect(result, equals('a b\n'));
    });
  });

  // ══════════════════════════════════════════════════════════════════════
  // Output always ends with newline (BRF convention)
  // ══════════════════════════════════════════════════════════════════════
  group('trailing newline (BRF convention)', () {
    test('single word ends with newline', () {
      expect(formatter.format('abc').endsWith('\n'), isTrue);
    });

    test('multi-line output ends with newline', () {
      expect(formatter.format('a\nb').endsWith('\n'), isTrue);
    });

    test('long text ends with newline', () {
      final longText = List.generate(20, (i) => 'word$i').join(' ');
      expect(formatter.format(longText).endsWith('\n'), isTrue);
    });
  });

  // ══════════════════════════════════════════════════════════════════════
  // Custom lineLength
  // ══════════════════════════════════════════════════════════════════════
  group('custom lineLength', () {
    test('lineLength=20 wraps at 20', () {
      // "abcdefghij klmnopqrst uvwxyz1234" (32 chars total)
      // With lineLength=20:
      // "abcdefghij" (10) + " " + "klmnopqrst" (10) = 20 → same line
      // "uvwxyz1234" doesn't fit (20 + 1 + 10 = 31 > 20) → new line
      final result = formatter.format(
        'abcdefghij klmnopqrst uvwxyz1234',
        lineLength: 20,
      );
      final lines = result.split('\n').where((l) => l.isNotEmpty).toList();
      for (final line in lines) {
        expect(
          line.length,
          lessThanOrEqualTo(20),
          reason: 'Line "$line" exceeds 20 chars',
        );
      }
    });

    test('lineLength=1', () {
      // Each word on its own line
      final result = formatter.format('a b c', lineLength: 1);
      expect(result, equals('a\nb\nc\n'));
    });
  });

  // ══════════════════════════════════════════════════════════════════════
  // Vietnamese text formatting
  // ══════════════════════════════════════════════════════════════════════
  group('Vietnamese text', () {
    test('short Vietnamese sentence', () {
      final result = formatter.format('xin chào');
      expect(result, equals('xin chào\n'));
    });

    test('long Vietnamese paragraph wraps correctly', () {
      final text =
          'đây là một đoạn văn bản tiếng việt '
          'được dùng để kiểm tra việc ngắt dòng trong trình định dạng brf';
      final result = formatter.format(text, lineLength: 40);
      final lines = result.split('\n').where((l) => l.isNotEmpty).toList();
      for (final line in lines) {
        expect(
          line.length,
          lessThanOrEqualTo(40),
          reason: 'Line "$line" exceeds 40 chars',
        );
      }
      // Words should not be cut
      final rejoined = lines.join(' ');
      expect(rejoined, equals(text));
    });
  });
}
