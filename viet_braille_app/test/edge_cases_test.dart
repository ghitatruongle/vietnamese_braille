import 'package:flutter_test/flutter_test.dart';
import 'package:viet_braille_app/core/braille_mapping.dart';
import 'package:viet_braille_app/data/ocr_processor.dart';
import 'package:viet_braille_app/domain/braille_converter.dart';
import 'package:viet_braille_app/domain/braille_reverse_converter.dart';

void main() {
  late BrailleMappingImpl mapping;
  late BrailleConverter converter;
  late BrailleReverseConverter reverseConverter;

  setUp(() {
    mapping = BrailleMappingImpl();
    converter = BrailleConverterImpl(mapping);
    reverseConverter = BrailleReverseConverterImpl(mapping);
  });

  group('state isolation stress test', () {
    test('reuse same converter instance 100 times without state leak', () {
      for (int i = 0; i < 100; i++) {
        final result = reverseConverter.convert(
          String.fromCharCode(0x2800 + 1),
        );
        expect(result, equals('a'), reason: 'Iteration $i failed');
      }
    });

    test('allCaps then lowercase then allCaps again', () {
      final allCaps =
          '${String.fromCharCode(0x2800 + 56)}' // ⠸ dots 4,5,6
          '${String.fromCharCode(0x2800 + 19)}' // H dots 1,2,5
          '${String.fromCharCode(0x2800 + 17)}' // E dots 1,5
          '${String.fromCharCode(0x2800 + 7)}' // L dots 1,2,3
          '${String.fromCharCode(0x2800 + 7)}' // L dots 1,2,3
          '${String.fromCharCode(0x2800 + 21)}'; // O dots 1,3,5
      final r1 = reverseConverter.convert(allCaps);
      expect(r1, equals('HELLO'));

      final lower =
          '${String.fromCharCode(0x2800 + 1)}' // a
          '${String.fromCharCode(0x2800 + 3)}'; // b
      final r2 = reverseConverter.convert(lower);
      expect(r2, equals('ab'));

      final r3 = reverseConverter.convert(allCaps);
      expect(r3, equals('HELLO'));
    });

    test('number mode then letter mode then number mode', () {
      final numIndicator = String.fromCharCode(0x2800 + 60);
      final cellA = String.fromCharCode(0x2800 + 1);
      final cellB = String.fromCharCode(0x2800 + 3);

      final num1 = reverseConverter.convert('$numIndicator$cellA$cellB');
      expect(num1, equals('12'));

      final letter = reverseConverter.convert('$cellA$cellB');
      expect(letter, equals('ab'));

      final num2 = reverseConverter.convert('$numIndicator$cellA$cellB');
      expect(num2, equals('12'));
    });

    test('empty string does not corrupt state', () {
      reverseConverter.convert('');
      final result = reverseConverter.convert(String.fromCharCode(0x2800 + 1));
      expect(result, equals('a'));
    });

    test('capital indicator then tone mark sequence', () {
      final forward = converter.convert('Ấ');
      expect(forward, isNotEmpty);
      final reversed = reverseConverter.convert(forward);
      expect(reversed.toLowerCase(), equals('ấ'));
    });
  });

  group('composeNfc refactored edge cases', () {
    test('NFD input composes correctly', () {
      final nfd = 'a\u0301';
      final result = converter.convert(nfd);
      final nfc = converter.convert('á');
      expect(result, equals(nfc));
    });

    test('multi-level compose: a + circumflex + acute → ấ', () {
      final nfd = 'a\u0302\u0301';
      final result = converter.convert(nfd);
      final nfc = converter.convert('ấ');
      expect(result, equals(nfc));
    });

    test('already NFC input stays unchanged', () {
      final nfc = 'ấ';
      final result = converter.convert(nfc);
      expect(result, isNotEmpty);
    });
  });

  group('OCR retry constructor edge cases', () {
    test('default constructor works', () {
      final processor = OcrProcessorImpl(mapping);
      expect(processor, isA<OcrProcessor>());
    });

    test('maxRetries=1 means no retry', () {
      final processor = OcrProcessorImpl(mapping, maxRetries: 1);
      expect(processor, isA<OcrProcessor>());
    });

    test('maxRetries=0 should not throw', () {
      final processor = OcrProcessorImpl(mapping, maxRetries: 0);
      expect(processor, isA<OcrProcessor>());
    });
  });
}
