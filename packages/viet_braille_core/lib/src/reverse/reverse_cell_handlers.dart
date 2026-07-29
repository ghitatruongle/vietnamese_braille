part of '../../braille_reverse_converter.dart';

/// Handler cho number indicator, number mode và các prefix cell hai ô.
/// Extension private cùng library với [BrailleReverseConverterImpl].
extension _CellHandlers on BrailleReverseConverterImpl {
  _CellResult _handleNumberIndicator(String brailleText, int i) {
    if (i + 2 < brailleText.length &&
        brailleText[i + 1] == _cellOf(_d2 | _d4 | _d5) &&
        brailleText[i + 2] == _cellOf(_d3 | _d5 | _d6)) {
      return const _CellResult(handled: true, delta: 3, output: '%');
    }
    if (i + 1 < brailleText.length) {
      final nextDigit = _mapping.reverseMapDigit(brailleText[i + 1]);
      if (nextDigit != null) {
        return _CellResult.enterNumber;
      }
    }
    return const _CellResult(handled: true, delta: 1, output: '#');
  }

  _CellResult _handleNumberMode(String brailleText, int i) {
    final cell = brailleText[i];
    final digit = _mapping.reverseMapDigit(cell);
    if (digit != null) {
      return _CellResult(handled: true, delta: 1, output: digit);
    }
    if (cell == _cellOf(_d3) && i + 1 < brailleText.length) {
      final nextDigit = _mapping.reverseMapDigit(brailleText[i + 1]);
      if (nextDigit != null) {
        return const _CellResult(handled: true, delta: 1, output: '.');
      }
    }
    if (cell == _cellOf(_d2) && i + 1 < brailleText.length) {
      final nextDigit = _mapping.reverseMapDigit(brailleText[i + 1]);
      if (nextDigit != null) {
        return const _CellResult(handled: true, delta: 1, output: ',');
      }
    }
    return _CellResult.exitNumber;
  }

  _CellResult _handlePrefixCell(String brailleText, int i) {
    final cell = brailleText[i];
    if (i + 1 >= brailleText.length) return _CellResult.unhandled;

    final nextCell = brailleText[i + 1];
    final twoCells = brailleText.substring(i, i + 2);

    if (cell == _mapping.symbolPrefix) {
      final sym = _symbolMap[twoCells];
      if (sym != null) {
        return _CellResult(handled: true, delta: 2, output: sym);
      }
    }
    if (cell == _mapping.mathPrefix) {
      final sym = _mathMap[twoCells];
      if (sym != null) {
        return _CellResult(handled: true, delta: 2, output: sym);
      }
    }
    if (cell == _mapping.specialPrefix) {
      final sym = _specialMap[twoCells];
      if (sym != null) {
        return _CellResult(handled: true, delta: 2, output: sym);
      }
    }
    if (cell == _mapping.bracketPrefix) {
      final sym = _bracketMap[twoCells];
      if (sym != null) {
        return _CellResult(handled: true, delta: 2, output: sym);
      }
      final reversed = _mapping.reverseMapChar(nextCell);
      if (reversed != null) {
        return _CellResult(
          handled: true,
          delta: 2,
          output: reversed.toUpperCase(),
        );
      }
      final vowel = _mapping.reverseMapVowel(nextCell);
      if (vowel != null) {
        return _CellResult(
          handled: true,
          delta: 2,
          output: vowel.toUpperCase(),
        );
      }
      return _CellResult(handled: true, delta: 2, output: nextCell);
    }
    return _CellResult.unhandled;
  }

  String _handleSingleCell(String cell) {
    final reversed = _mapping.reverseMapChar(cell);
    if (reversed != null) return reversed;
    final vowel = _mapping.reverseMapVowel(cell);
    if (vowel != null) return vowel;
    return cell;
  }
}
