part of '../../braille_reverse_converter.dart';

// ── Dot bitmasks & cell helper dùng chung cho toàn library ──
const int _d1 = BrailleDots.d1;
const int _d2 = BrailleDots.d2;
const int _d3 = BrailleDots.d3;
const int _d4 = BrailleDots.d4;
const int _d5 = BrailleDots.d5;
const int _d6 = BrailleDots.d6;

String _cellOf(int dots) => BrailleDots.cell(dots);

// ── Char predicates dùng chung (dựa trên hằng số nguyên âm tiếng Việt) ──
const String _latinLowerLetters = 'abcdefghijklmnopqrstuvwxyz';

bool _isLetter(String ch) {
  if (ch.length != 1) return false;
  final c = ch.toLowerCase();
  return _latinLowerLetters.contains(c) ||
      kVietnameseBaseVowels.contains(c) ||
      kVietnameseExtraLetters.contains(c);
}

bool _isPunctuation(String ch) {
  if (ch.length != 1) return false;
  return ',.?!...:;\'"()-/\\*&@[]{}|\$%^'.contains(ch);
}

bool _isWhitespace(String ch) =>
    ch == ' ' || ch == '\n' || ch == '\t' || ch == '\r';

bool _isLatinVowel(String ch) => 'aeiouy'.contains(ch);

bool _isDecodedVowel(String ch) =>
    kVietnameseTonedVowels.contains(ch.toLowerCase());

/// Hành động number-mode mà một cell yêu cầu main loop thực hiện.
///
/// Thay thế sentinel string (`_ENTER_NUMBER_`/`_EXIT_NUMBER_`) trước đây:
/// trạng thái được truyền bằng kiểu rõ ràng thay vì chuỗi ma thuật.
enum _NumberAction { none, enter, exit }

/// Kết quả xử lý một cell trong reverse converter.
class _CellResult {
  const _CellResult({
    required this.handled,
    this.delta = 1,
    this.output = '',
    this.numberAction = _NumberAction.none,
  });

  static const _CellResult unhandled = _CellResult(handled: false);
  static const _CellResult enterNumber = _CellResult(
    handled: true,
    delta: 1,
    numberAction: _NumberAction.enter,
  );
  static const _CellResult exitNumber = _CellResult(
    handled: true,
    delta: 0,
    numberAction: _NumberAction.exit,
  );

  final bool handled;
  final int delta;
  final String output;
  final _NumberAction numberAction;
}

/// Immutable state cho capitalization tracking trong một lần convert().
class _CapState {
  const _CapState({
    this.isAllCapsPhrase = false,
    this.isInitCapsPhrase = false,
    this.isAllCapsWord = false,
    this.capNextLetter = false,
    this.isWordStart = true,
  });

  final bool isAllCapsPhrase;
  final bool isInitCapsPhrase;
  final bool isAllCapsWord;
  final bool capNextLetter;
  final bool isWordStart;

  _CapState copyWith({
    bool? isAllCapsPhrase,
    bool? isInitCapsPhrase,
    bool? isAllCapsWord,
    bool? capNextLetter,
    bool? isWordStart,
  }) {
    return _CapState(
      isAllCapsPhrase: isAllCapsPhrase ?? this.isAllCapsPhrase,
      isInitCapsPhrase: isInitCapsPhrase ?? this.isInitCapsPhrase,
      isAllCapsWord: isAllCapsWord ?? this.isAllCapsWord,
      capNextLetter: capNextLetter ?? this.capNextLetter,
      isWordStart: isWordStart ?? this.isWordStart,
    );
  }
}
