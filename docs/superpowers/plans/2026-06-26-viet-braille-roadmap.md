# Vietnamese Braille — Full Roadmap Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Nâng cấp dự án Vietnamese Braille thành nền tảng toàn diện phục vụ người khiếm thị, giáo viên, và developer trong 5 tháng (10 sprints × 2 tuần).

**Architecture:** 4 parallel tracks — Foundation (code quality), Features (accessibility, web, API, teaching), Integration (Python tools), Documentation. Track A là nền tảng, các track khác depend vào.

**Tech Stack:** Flutter 3.29.x, Dart, Riverpod, GoRouter, Google ML Kit, Dart Shelf, Python 3.11+, pytest, GitHub Actions, MkDocs

**Design Spec:** `docs/superpowers/specs/2026-06-26-viet-braille-roadmap-design.md`

---

## File Map

| Track | Files Created | Files Modified |
|-------|--------------|----------------|
| A | `README.md`, `.github/workflows/ci.yml`, `test/integration/`, `test/edge_cases/`, `test/performance/`, `analysis_options.yaml` | `lib/domain/braille_reverse_converter.dart`, `lib/core/braille_mapping.dart` |
| B | `lib/accessibility/`, `packages/viet_braille_core/`, `lib/teaching/`, `api_server/`, `lib/data/speech_service.dart` | `lib/main.dart`, `lib/presentation/widgets/`, `pubspec.yaml` |
| C | `tools/verify/`, `tools/analysis/`, `tools/comparison/`, `tools/requirements.txt`, `tools/verify.py` | `.github/workflows/ci.yml` |
| D | `CONTRIBUTING.md`, `LICENSE`, `CHANGELOG.md`, `docs/user-guide.md`, `docs/architecture.md`, `.github/ISSUE_TEMPLATE/` | `README.md` |

---
---

# TRACK A: FOUNDATION

## Task A1: Viết README.md chính thức

**Goal:** Tạo README.md chuyên nghiệp với badges, features, quick start.

**Files:**
- Create: `README.md`

- [ ] **Step 1: Tạo README.md**

Nội dung README bao gồm: badges (CI, codecov, license), feature list, quick start, cách sử dụng, kiến trúc, contributing, license.

- [ ] **Step 2: Verify markdown renders**

Mở trên GitHub hoặc preview editor.

- [ ] **Step 3: Commit**

```bash
git add README.md
git commit -m "docs: add official README with badges, features, quick start"
```

---

## Task A2: Fix Reverse Converter State Leak

**Goal:** `BrailleReverseConverterImpl` dùng instance variables có thể leak state giữa các lần gọi `convert()`. Dùng immutable state object.

**Files:**
- Modify: `viet_braille_app/lib/domain/braille_reverse_converter.dart`
- Modify: `viet_braille_app/test/domain/braille_reverse_converter_test.dart`

- [ ] **Step 1: Viết test chứng minh state leak**

Thêm group mới vào `test/domain/braille_reverse_converter_test.dart`:

```dart
group('state isolation between convert() calls', () {
  test('consecutive calls do not leak capitalization state', () {
    // First call: all-caps
    final allCapsBraille = '${brf('46')}${brf('46')}$cellH$cellE$cellL$cellL$cellO${brf('156')}';
    final result1 = converter.convert(allCapsBraille);
    expect(result1, equals('HELLO'));

    // Second call: should NOT inherit allCaps state
    final result2 = converter.convert('$cellA$cellB$cellC');
    expect(result2, equals('abc'));
  });

  test('consecutive calls do not leak number mode state', () {
    final numBraille = '$numIndicator$cellA$cellB$cellC';
    final result1 = converter.convert(numBraille);
    expect(result1, equals('123'));

    final result2 = converter.convert('$cellA$cellB$cellC');
    expect(result2, equals('abc'));
  });
});
```

- [ ] **Step 2: Chạy test — ghi nhận baseline**

```bash
cd viet_braille_app && flutter test test/domain/braille_reverse_converter_test.dart
```

Expected: Tất cả PASS (setUp tạo instance mới mỗi lần).

- [ ] **Step 3: Tạo `_ConvertState` class**

Thêm sau class `_CellResult` trong `lib/domain/braille_reverse_converter.dart`:

```dart
class _ConvertState {
  const _ConvertState({
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

  _ConvertState copyWith({
    bool? isAllCapsPhrase,
    bool? isInitCapsPhrase,
    bool? isAllCapsWord,
    bool? capNextLetter,
    bool? isWordStart,
  }) {
    return _ConvertState(
      isAllCapsPhrase: isAllCapsPhrase ?? this.isAllCapsPhrase,
      isInitCapsPhrase: isInitCapsPhrase ?? this.isInitCapsPhrase,
      isAllCapsWord: isAllCapsWord ?? this.isAllCapsWord,
      capNextLetter: capNextLetter ?? this.capNextLetter,
      isWordStart: isWordStart ?? this.isWordStart,
    );
  }
}
```

- [ ] **Step 4: Xóa instance variables cũ**

Xóa `bool isAllCapsPhrase`, `isInitCapsPhrase`, `isAllCapsWord`, `capNextLetter`, `isWordStart` trong class chính.

- [ ] **Step 5: Refactor `convert()` — dùng `var state = const _ConvertState()`**

Thay thế tất cả `isAllCapsPhrase = true` thành `state = state.copyWith(isAllCapsPhrase: true)`, tương tự cho các biến khác.

- [ ] **Step 6: Refactor `_applyCapitalization` nhận `_ConvertState`**

```dart
String _applyCapitalization(String text, {
  required bool hadCapitalIndicator,
  required _ConvertState state,
}) {
  if (text.isEmpty) return text;
  if (state.isAllCapsPhrase || state.isAllCapsWord) return text.toUpperCase();
  if (state.isInitCapsPhrase && state.isWordStart) {
    return text.substring(0, 1).toUpperCase() + text.substring(1);
  }
  if (hadCapitalIndicator || state.capNextLetter) {
    return text.substring(0, 1).toUpperCase() + text.substring(1);
  }
  return text;
}
```

- [ ] **Step 7: Chạy toàn bộ tests**

```bash
cd viet_braille_app && flutter test
```

Expected: Tất cả PASS.

- [ ] **Step 8: Commit**

```bash
git add viet_braille_app/lib/domain/braille_reverse_converter.dart viet_braille_app/test/domain/braille_reverse_converter_test.dart
git commit -m "refactor: use immutable state in reverse converter

- Replace instance variables with _ConvertState value object
- Each convert() call starts with fresh state
- Eliminates state leak between consecutive calls"
```

---

## Task A3: Refactor `_composeNfc` — Extract Shared Logic

**Goal:** Loại bỏ code trùng lặp giữa `_composeNfc` và `_composeNfcWithCapitals`.

**Files:**
- Modify: `viet_braille_app/lib/core/braille_mapping.dart`

- [ ] **Step 1: Chạy tests baseline**

```bash
cd viet_braille_app && flutter test test/core/braille_mapping_test.dart test/domain/braille_converter_test.dart
```

- [ ] **Step 2: Thêm `_composeNfcCore` method**

```dart
({String text, List<bool>? capitals}) _composeNfcCore(String text, [List<bool>? capitals]) {
  String result = text;
  List<bool>? resultCapitals = capitals != null ? List<bool>.from(capitals) : null;

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
          resultCapitals != null ? newCapitals.add(resultCapitals[i]) : null;
          i += 2;
          changed = true;
          continue;
        }
      }
      buf.write(result[i]);
      resultCapitals != null ? newCapitals.add(resultCapitals[i]) : null;
      i++;
    }
    result = buf.toString();
    if (resultCapitals != null) resultCapitals = newCapitals;
    if (!changed) break;
  }
  return (text: result, capitals: resultCapitals);
}
```

- [ ] **Step 3: Thay thế `_composeNfc`**

```dart
String _composeNfc(String text) => _composeNfcCore(text).text;
```

- [ ] **Step 4: Thay thế `_composeNfcWithCapitals`**

```dart
({String text, List<bool> capitals}) _composeNfcWithCapitals(String text, List<bool> capitals) {
  final result = _composeNfcCore(text, capitals);
  return (text: result.text, capitals: result.capitals!);
}
```

- [ ] **Step 5: Chạy toàn bộ tests**

```bash
cd viet_braille_app && flutter test
```

- [ ] **Step 6: Commit**

```bash
git add viet_braille_app/lib/core/braille_mapping.dart
git commit -m "refactor: extract shared NFD→NFC compose logic

- Extract _composeNfcCore() as shared implementation
- Eliminates code duplication, single source of truth"
```

---

## Task A4: Add Integration Tests

**Goal:** Verify end-to-end flow: text → BrailleConverter → BRF format.

**Files:**
- Create: `viet_braille_app/test/integration/full_flow_test.dart`

- [ ] **Step 1: Tạo thư mục**

```bash
mkdir -p viet_braille_app/test/integration
```

- [ ] **Step 2: Viết integration test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:viet_braille_app/core/braille_mapping.dart';
import 'package:viet_braille_app/domain/braille_converter.dart';
import 'package:viet_braille_app/domain/braille_reverse_converter.dart';
import 'package:viet_braille_app/domain/brf_formatter.dart';

void main() {
  late BrailleMappingImpl mapping;
  late BrailleConverter converter;
  late BrailleReverseConverter reverseConverter;
  late BrfFormatter formatter;

  setUp(() {
    mapping = BrailleMappingImpl();
    converter = BrailleConverterImpl(mapping);
    reverseConverter = BrailleReverseConverterImpl(mapping);
    formatter = BrfFormatterImpl();
  });

  group('full pipeline: text → Braille → BRF', () {
    test('simple Vietnamese sentence', () {
      const input = 'Xin chào Việt Nam';
      final result = converter.convertWithDetails(input);
      expect(result.hasWarnings, isFalse);
      expect(result.brailleText, isNotEmpty);
      final brf = formatter.format(result.brailleText, lineLength: 40);
      expect(brf, isNotEmpty);
      expect(brf, endsWith('\n'));
    });

    test('all Vietnamese special vowels', () {
      const input = 'ăâêôơưđ';
      final result = converter.convertWithDetails(input);
      expect(result.brailleText, isNotEmpty);
      expect(result.hasWarnings, isFalse);
    });

    test('mixed case with numbers', () {
      const input = 'Học sinh lớp 10A';
      final result = converter.convertWithDetails(input);
      expect(result.brailleText, isNotEmpty);
      final reversed = reverseConverter.convert(result.brailleText);
      expect(reversed.toLowerCase(), contains('học'));
      expect(reversed, contains('10'));
    });

    test('empty input returns empty result', () {
      final result = converter.convertWithDetails('');
      expect(result.brailleText, isEmpty);
    });
  });

  group('round-trip: text → Braille → text', () {
    test('plain ASCII round-trips', () {
      const input = 'hello world';
      final braille = converter.convert(input);
      final reversed = reverseConverter.convert(braille);
      expect(reversed, equals(input));
    });

    test('Vietnamese without tone round-trips', () {
      const input = 'đây là tiếng việt';
      final braille = converter.convert(input);
      final reversed = reverseConverter.convert(braille);
      expect(reversed, equals(input));
    });

    test('numbers round-trip', () {
      const input = '123';
      final braille = converter.convert(input);
      final reversed = reverseConverter.convert(braille);
      expect(reversed, equals(input));
    });
  });

  group('BRF formatting', () {
    test('long text wraps at lineLength', () {
      const input = 'Đây là một đoạn văn bản tiếng Việt đủ dài để kiểm tra việc ngắt dòng trong định dạng BRF';
      final result = converter.convertWithDetails(input);
      final brf = formatter.format(result.brailleText, lineLength: 20);
      final lines = brf.split('\n').where((l) => l.isNotEmpty).toList();
      for (int i = 0; i < lines.length - 1; i++) {
        expect(lines[i].length, lessThanOrEqualTo(20));
      }
    });
  });
}
```

- [ ] **Step 3: Chạy integration tests**

```bash
cd viet_braille_app && flutter test test/integration/full_flow_test.dart
```

- [ ] **Step 4: Chạy toàn bộ test suite**

```bash
cd viet_braille_app && flutter test
```

- [ ] **Step 5: Commit**

```bash
git add viet_braille_app/test/integration/full_flow_test.dart
git commit -m "test: add integration tests for full conversion pipeline

- Text → Braille → BRF full flow tests
- Round-trip: text → Braille → text verification
- BRF formatting integration with line wrapping"
```

---

## Task A5: Setup CI Pipeline

**Goal:** Thiết lập GitHub Actions CI với dart format, dart analyze, flutter test.

**Files:**
- Create: `.github/workflows/ci.yml`

- [ ] **Step 1: Tạo workflow**

```yaml
name: Flutter CI

on:
  push:
    branches: [master, main, develop]
  pull_request:
    branches: [master, main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.29.x'
          channel: stable
      - name: Install dependencies
        run: flutter pub get
      - name: Check formatting
        run: dart format --set-exit-if-changed lib/ test/
      - name: Analyze Dart code
        run: dart analyze
      - name: Run tests
        run: flutter test --coverage
      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v4
        with:
          token: ${{ secrets.CODECOV_TOKEN }}
          file: coverage/lcov.info
          fail_ci_if_error: false

  python-verify:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'
      - name: Run verification scripts
        run: |
          python verify_braille.py
          python deep_analysis.py
```

- [ ] **Step 2: Format code**

```bash
cd viet_braille_app && dart format lib/ test/
```

- [ ] **Step 3: Commit**

```bash
mkdir -p .github/workflows
git add .github/workflows/ci.yml
git commit -m "ci: add Flutter CI with format, analyze, test, coverage"
```

---

## Task A6: Add Edge Case Tests

**Goal:** Thêm tests cho tone stacking, qu/gi rules, special characters.

**Files:**
- Create: `viet_braille_app/test/edge_cases/tone_stacking_test.dart`
- Create: `viet_braille_app/test/edge_cases/qu_gi_rules_test.dart`
- Create: `viet_braille_app/test/edge_cases/special_chars_test.dart`

- [ ] **Step 1: Tạo thư mục**

```bash
mkdir -p viet_braille_app/test/edge_cases
```

- [ ] **Step 2: Viết tone stacking tests**

```dart
// test/edge_cases/tone_stacking_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:viet_braille_app/core/braille_mapping.dart';
import 'package:viet_braille_app/domain/braille_converter.dart';

void main() {
  late BrailleMapping mapping;
  late BrailleConverter converter;

  setUp(() {
    mapping = BrailleMappingImpl();
    converter = BrailleConverterImpl(mapping);
  });

  group('tone stacking', () {
    test('ấ (a + circumflex + acute)', () {
      final result = converter.convertWithDetails('ấ');
      expect(result.brailleText, isNotEmpty);
      expect(result.hasWarnings, isFalse);
    });

    test('ầ (a + circumflex + grave)', () {
      final result = converter.convertWithDetails('ầ');
      expect(result.brailleText, isNotEmpty);
    });

    test('ẩ (a + circumflex + hook)', () {
      final result = converter.convertWithDetails('ẩ');
      expect(result.brailleText, isNotEmpty);
    });

    test('ẫ (a + circumflex + tilde)', () {
      final result = converter.convertWithDetails('ẫ');
      expect(result.brailleText, isNotEmpty);
    });

    test('ậ (a + circumflex + dot)', () {
      final result = converter.convertWithDetails('ậ');
      expect(result.brailleText, isNotEmpty);
    });

    test('all double toned vowels in sentence', () {
      const input = 'ấ ầ ẩ ẫ ậ';
      final result = converter.convertWithDetails(input);
      expect(result.brailleText, isNotEmpty);
      expect(result.hasWarnings, isFalse);
    });
  });
}
```

- [ ] **Step 3: Viết qu/gi rule tests**

```dart
// test/edge_cases/qu_gi_rules_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:viet_braille_app/core/braille_mapping.dart';
import 'package:viet_braille_app/domain/braille_converter.dart';

void main() {
  late BrailleMapping mapping;
  late BrailleConverter converter;

  setUp(() {
    mapping = BrailleMappingImpl();
    converter = BrailleConverterImpl(mapping);
  });

  group('qu rule', () {
    test('quyết', () {
      final result = converter.convertWithDetails('quyết');
      expect(result.brailleText, isNotEmpty);
      expect(result.hasWarnings, isFalse);
    });
    test('quả', () {
      final result = converter.convertWithDetails('quả');
      expect(result.brailleText, isNotEmpty);
    });
    test('qui', () {
      final result = converter.convertWithDetails('qui');
      expect(result.brailleText, isNotEmpty);
    });
    test('quốc', () {
      final result = converter.convertWithDetails('quốc');
      expect(result.brailleText, isNotEmpty);
    });
  });

  group('gi rule', () {
    test('giải', () {
      final result = converter.convertWithDetails('giải');
      expect(result.brailleText, isNotEmpty);
      expect(result.hasWarnings, isFalse);
    });
    test('gạo', () {
      final result = converter.convertWithDetails('gạo');
      expect(result.brailleText, isNotEmpty);
    });
    test('giếng', () {
      final result = converter.convertWithDetails('giếng');
      expect(result.brailleText, isNotEmpty);
    });
  });
}
```

- [ ] **Step 4: Viết special characters tests**

```dart
// test/edge_cases/special_chars_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:viet_braille_app/core/braille_mapping.dart';
import 'package:viet_braille_app/domain/braille_converter.dart';

void main() {
  late BrailleMapping mapping;
  late BrailleConverter converter;

  setUp(() {
    mapping = BrailleMappingImpl();
    converter = BrailleConverterImpl(mapping);
  });

  group('special characters', () {
    test('punctuation: comma, period, question, exclaim', () {
      const input = 'Xin chào, Việt Nam! Bạn khỏe không?';
      final result = converter.convertWithDetails(input);
      expect(result.brailleText, isNotEmpty);
      expect(result.hasWarnings, isFalse);
    });

    test('numbers with separators', () {
      const input = '1.234.567,89';
      final result = converter.convertWithDetails(input);
      expect(result.brailleText, isNotEmpty);
    });

    test('very long text (performance)', () {
      final input = 'Xin chào Việt Nam. ' * 100;
      final result = converter.convertWithDetails(input);
      expect(result.brailleText, isNotEmpty);
    });

    test('whitespace-only input', () {
      final result = converter.convertWithDetails('   ');
      expect(result.brailleText, isEmpty);
    });
  });
}
```

- [ ] **Step 5: Chạy tests**

```bash
cd viet_braille_app && flutter test test/edge_cases/
```

- [ ] **Step 6: Commit**

```bash
git add viet_braille_app/test/edge_cases/
git commit -m "test: add edge case tests for tones, qu/gi rules, special chars"
```

---

## Task A7: Dart Analyze Strict Mode

**Goal:** Bật strict mode trong analysis_options.yaml.

**Files:**
- Create: `viet_braille_app/analysis_options.yaml`

- [ ] **Step 1: Tạo analysis_options.yaml**

```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    - prefer_const_constructors
    - prefer_final_locals
    - avoid_print
    - require_trailing_commas
    - prefer_single_quotes

analyzer:
  errors:
    missing_return: error
    dead_code: warning
    unused_import: warning
```

- [ ] **Step 2: Chạy dart analyze, sửa warnings**

```bash
cd viet_braille_app && dart analyze
```

- [ ] **Step 3: Commit**

```bash
git add viet_braille_app/analysis_options.yaml
git commit -m "chore: enable strict dart analysis mode"
```

---

## Task A8: Performance Benchmarks

**Goal:** Profile large text conversion, ghi nhận baseline.

**Files:**
- Create: `viet_braille_app/test/performance/conversion_benchmark.dart`

- [ ] **Step 1: Tạo benchmark test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:viet_braille_app/core/braille_mapping.dart';
import 'package:viet_braille_app/domain/braille_converter.dart';

void main() {
  late BrailleMapping mapping;
  late BrailleConverter converter;

  setUp(() {
    mapping = BrailleMappingImpl();
    converter = BrailleConverterImpl(mapping);
  });

  group('performance benchmarks', () {
    test('convert 1000 words under 1 second', () {
      final input = 'Xin chào Việt Nam. ' * 200;
      final stopwatch = Stopwatch()..start();
      final result = converter.convertWithDetails(input);
      stopwatch.stop();
      expect(result.brailleText, isNotEmpty);
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      print('1000 words: ${stopwatch.elapsedMilliseconds}ms');
    });

    test('convert 10000 words under 5 seconds', () {
      final input = 'Xin chào Việt Nam. ' * 2000;
      final stopwatch = Stopwatch()..start();
      final result = converter.convertWithDetails(input);
      stopwatch.stop();
      expect(result.brailleText, isNotEmpty);
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));
      print('10000 words: ${stopwatch.elapsedMilliseconds}ms');
    });
  });
}
```

- [ ] **Step 2: Chạy benchmark**

```bash
cd viet_braille_app && flutter test test/performance/conversion_benchmark.dart
```

- [ ] **Step 3: Commit**

```bash
git add viet_braille_app/test/performance/
git commit -m "test: add performance benchmarks for text conversion"
```

---

## Task A9: Memory Leak Audit

**Goal:** Kiểm tra OCR processor dispose đúng cách.

**Files:**
- Modify: `viet_braille_app/lib/data/ocr_processor.dart`

- [ ] **Step 1: Verify OcrProcessor có dispose method**

Đọc `lib/data/ocr_processor.dart`, đảm bảo `dispose()` gọi `_textRecognizer.close()`.

- [ ] **Step 2: Verify callers gọi dispose**

```bash
cd viet_braille_app && grep -r "OcrProcessorImpl" lib/
```

Đảm bảo mọi nơi tạo OcrProcessorImpl đều gọi dispose() khi xong.

- [ ] **Step 3: Commit nếu có thay đổi**

```bash
git add viet_braille_app/lib/data/ocr_processor.dart
git commit -m "fix: ensure OCR processor disposes text recognizer properly"
```

---
---

# TRACK B: FEATURES

## Task B1: Screen Reader Support (Semantics)

**Goal:** Thêm Semantics labels cho tất cả widgets.

**Files:**
- Modify: `viet_braille_app/lib/presentation/widgets/text_input_section.dart`
- Modify: `viet_braille_app/lib/presentation/widgets/braille_display_section.dart`
- Modify: `viet_braille_app/lib/presentation/screens/home_screen.dart`
- Modify: `viet_braille_app/lib/presentation/widgets/app_drawer.dart`

- [ ] **Step 1: Đọc widget files**

- [ ] **Step 2: Thêm Semantics cho TextField**

```dart
Semantics(
  label: 'Nhập văn bản tiếng Việt để chuyển đổi sang Braille',
  textField: true,
  child: TextField(...),
)
```

- [ ] **Step 3: Thêm Semantics cho display sections**

```dart
Semantics(
  label: 'Kết quả chữ Braille. Nhấn để sao chép.',
  button: true,
  child: GestureDetector(...),
)
```

- [ ] **Step 4: Thêm Semantics cho action buttons**

```dart
Semantics(
  label: 'Chuyển đổi văn bản sang Braille',
  button: true,
  child: ElevatedButton(...),
)
```

- [ ] **Step 5: Thêm Semantics cho drawer items**

```dart
Semantics(
  label: 'Trang chủ - Chuyển đổi Braille',
  button: true,
  child: ListTile(...),
)
```

- [ ] **Step 6: Chạy tests, commit**

```bash
cd viet_braille_app && flutter test
git add viet_braille_app/lib/presentation/
git commit -m "feat: add screen reader support with Semantics labels"
```

---

## Task B2: Font Size Adjustment

**Goal:** Settings slider để điều chỉnh kích thước chữ.

**Files:**
- Modify: `viet_braille_app/lib/presentation/screens/settings_screen.dart`
- Modify: `viet_braille_app/lib/core/app_theme.dart`
- Modify: `viet_braille_app/lib/presentation/providers/theme_provider.dart`

- [ ] **Step 1: Thêm fontScale vào ThemeNotifier**

```dart
double _fontScale = 1.0;
double get fontScale => _fontScale;

void setFontScale(double scale) {
  _fontScale = scale.clamp(0.8, 2.0);
  // notify listeners
}
```

- [ ] **Step 2: Thêm slider vào SettingsScreen**

```dart
Slider(
  value: ref.watch(themeProvider.notifier).fontScale,
  min: 0.8, max: 2.0, divisions: 6,
  label: '${(ref.watch(themeProvider.notifier).fontScale * 100).round()}%',
  onChanged: (value) => ref.read(themeProvider.notifier).setFontScale(value),
)
```

- [ ] **Step 3: Áp dụng fontSizeFactor trong theme**

```dart
textTheme: ThemeData.light().textTheme.apply(fontSizeFactor: fontScale),
```

- [ ] **Step 4: Persist qua SharedPreferences**

- [ ] **Step 5: Chạy tests, commit**

```bash
cd viet_braille_app && flutter test
git add viet_braille_app/lib/
git commit -m "feat: add font size adjustment for accessibility"
```

---

## Task B3: Voice Input (Speech-to-Text)

**Goal:** Nhập liệu bằng giọng nói tiếng Việt.

**Files:**
- Modify: `viet_braille_app/pubspec.yaml`
- Create: `viet_braille_app/lib/data/speech_service.dart`
- Modify: `viet_braille_app/lib/presentation/widgets/text_input_section.dart`

- [ ] **Step 1: Thêm dependency `speech_to_text: ^6.6.0`**

- [ ] **Step 2: Tạo SpeechService**

```dart
class SpeechService {
  final SpeechToText _speech = SpeechToText();

  Future<bool> initialize() async => await _speech.initialize();

  Future<void> startListening({
    required Function(String) onResult,
    String localeId = 'vi_VN',
  }) async {
    await _speech.listen(
      onResult: (result) => onResult(result.recognizedWords),
      localeId: localeId,
    );
  }

  Future<void> stopListening() async => await _speech.stop();
  bool get isListening => _speech.isListening;
}
```

- [ ] **Step 3: Thêm microphone button vào TextInputSection**

- [ ] **Step 4: Chạy tests, commit**

```bash
cd viet_braille_app && flutter test
git add viet_braille_app/
git commit -m "feat: add voice input with Vietnamese speech recognition"
```

---

## Task B4: Flutter Web Build

**Goal:** Enable Flutter web target.

**Files:**
- Modify: `viet_braille_app/lib/data/ocr_processor.dart` (conditional import)

- [ ] **Step 1: `flutter config --enable-web`**

- [ ] **Step 2: Conditional import cho OCR (not available on web)**

```dart
import 'ocr_processor_stub.dart'
    if (dart.library.io) 'ocr_processor_io.dart'
    if (dart.library.html) 'ocr_processor_web.dart';
```

- [ ] **Step 3: Tạo stub implementations**

- [ ] **Step 4: `flutter build web`**

- [ ] **Step 5: Commit**

```bash
git add viet_braille_app/
git commit -m "feat: enable Flutter web build with platform-safe OCR"
```

---

## Task B5: Extract viet_braille_core Package

**Goal:** Tách core logic thành package độc lập.

**Files:**
- Create: `packages/viet_braille_core/pubspec.yaml`
- Create: `packages/viet_braille_core/lib/viet_braille_core.dart`
- Copy: core files vào package

- [ ] **Step 1: Tạo package structure**

```bash
mkdir -p packages/viet_braille_core/lib packages/viet_braille_core/test
```

- [ ] **Step 2: Tạo pubspec.yaml (pure Dart, no dependencies)**

- [ ] **Step 3: Copy core files**

```bash
cp viet_braille_app/lib/core/braille_mapping.dart packages/viet_braille_core/lib/
cp viet_braille_app/lib/core/braille_dots.dart packages/viet_braille_core/lib/
cp viet_braille_app/lib/domain/braille_converter.dart packages/viet_braille_core/lib/
cp viet_braille_app/lib/domain/braille_reverse_converter.dart packages/viet_braille_core/lib/
cp viet_braille_app/lib/domain/brf_formatter.dart packages/viet_braille_core/lib/
```

- [ ] **Step 4: Tạo barrel file**

```dart
library viet_braille_core;
export 'braille_dots.dart';
export 'braille_mapping.dart';
export 'braille_converter.dart';
export 'braille_reverse_converter.dart';
export 'brf_formatter.dart';
```

- [ ] **Step 5: Thêm path dependency vào app**

```yaml
viet_braille_core:
  path: ../packages/viet_braille_core
```

- [ ] **Step 6: Update imports, chạy tests, commit**

```bash
cd viet_braille_app && flutter test
git add packages/ viet_braille_app/
git commit -m "refactor: extract viet_braille_core as standalone package"
```

---

## Task B6: REST API Server

**Goal:** Tạo REST API cho Braille conversion.

**Files:**
- Create: `api_server/bin/server.dart`
- Create: `api_server/lib/handlers/convert_handler.dart`
- Create: `api_server/pubspec.yaml`

- [ ] **Step 1: Tạo package với shelf + viet_braille_core dependency**

- [ ] **Step 2: Tạo server entry point với CORS**

- [ ] **Step 3: Tạo handlers: POST /convert, POST /reverse, POST /batch**

- [ ] **Step 4: Test locally**

```bash
cd api_server && dart run bin/server.dart
curl -X POST http://localhost:8080/convert -H "Content-Type: application/json" -d '{"text": "Xin chào"}'
```

- [ ] **Step 5: Commit**

```bash
git add api_server/
git commit -m "feat: add REST API server for Braille conversion"
```

---

## Task B7: Interactive Braille Learning Mode

**Goal:** Chế độ học Braille — tap vào dots để xem ký tự.

**Files:**
- Create: `viet_braille_app/lib/teaching/learning_screen.dart`
- Create: `viet_braille_app/lib/teaching/braille_grid_widget.dart`
- Modify: `viet_braille_app/lib/main.dart` (add route)

- [ ] **Step 1: Tạo BrailleGridWidget (6 dots, tap to toggle)**

- [ ] **Step 2: Tạo LearningScreen với alphabet grid**

- [ ] **Step 3: Thêm route `/learn` và drawer item**

- [ ] **Step 4: Chạy tests, commit**

```bash
git add viet_braille_app/lib/teaching/ viet_braille_app/lib/main.dart
git commit -m "feat: add interactive Braille learning mode"
```

---

## Task B8: Quiz Mode

**Goal:** Quiz: text → Braille, scoring.

**Files:**
- Create: `viet_braille_app/lib/teaching/quiz_screen.dart`

- [ ] **Step 1: Tạo QuizScreen với multiple choice**

- [ ] **Step 2: Thêm route `/quiz` và drawer item**

- [ ] **Step 3: Chạy tests, commit**

```bash
git add viet_braille_app/lib/teaching/quiz_screen.dart
git commit -m "feat: add quiz mode for Braille learning"
```

---

## Task B9: Batch Processing

**Goal:** Upload file, convert all lines.

**Files:**
- Modify: `viet_braille_app/lib/presentation/providers/conversion_provider.dart`
- Modify: `viet_braille_app/lib/presentation/screens/home_screen.dart`

- [ ] **Step 1: Thêm batchConvert method**

- [ ] **Step 2: Thêm "Chuyển đổi từ file" button**

- [ ] **Step 3: Chạy tests, commit**

```bash
git add viet_braille_app/lib/
git commit -m "feat: add batch processing from file upload"
```

---

## Task B10: PDF Export

**Goal:** Xuất Braille ra PDF.

**Files:**
- Modify: `viet_braille_app/lib/data/file_exporter.dart`
- Modify: `viet_braille_app/pubspec.yaml`

- [ ] **Step 1: Thêm dependencies `pdf: ^3.10.0`, `printing: ^5.12.0`**

- [ ] **Step 2: Thêm exportToPdf method**

- [ ] **Step 3: Thêm "Xuất PDF" button**

- [ ] **Step 4: Chạy tests, commit**

```bash
git add viet_braille_app/
git commit -m "feat: add PDF export for Braille text"
```

---
---

# TRACK C: INTEGRATION

## Task C1: Organize Python Tools

**Goal:** Tạo `tools/` directory, di chuyển scripts, tạo unified CLI.

**Files:**
- Move: Python scripts → `tools/verify/`, `tools/analysis/`, `tools/comparison/`
- Create: `tools/requirements.txt`
- Create: `tools/verify.py`

- [ ] **Step 1: Tạo thư mục và di chuyển**

```bash
mkdir -p tools/verify tools/analysis tools/comparison
mv verify_braille.py tools/verify/
mv deep_analysis.py tools/analysis/
mv ueb_comparison.py tools/comparison/
mv compare_detail.py tools/comparison/
mv compare_detailed_v2.py tools/comparison/
mv compare_rules_vs_app.py tools/comparison/
mv extract_braille.py tools/analysis/
mv verify_braille_complete.py tools/verify/
```

- [ ] **Step 2: Tạo requirements.txt**

```txt
pytest>=7.4.0
pdfplumber>=0.10.0
pyyaml>=6.0
```

- [ ] **Step 3: Tạo unified CLI `tools/verify.py`**

```python
#!/usr/bin/env python3
"""Unified CLI for Vietnamese Braille verification."""
import sys, os, subprocess

def run_script(path, desc):
    print(f"\n{'='*60}\n{desc}\n{'='*60}")
    return subprocess.run([sys.executable, path]).returncode == 0

def main():
    scripts = [
        ("tools/verify/verify_braille.py", "Braille mapping verification"),
        ("tools/analysis/deep_analysis.py", "Deep analysis"),
        ("tools/comparison/ueb_comparison.py", "UEB comparison"),
    ]
    failures = 0
    for path, desc in scripts:
        if os.path.exists(path):
            if not run_script(path, desc):
                failures += 1
    if failures:
        print(f"\n{failures} verification(s) FAILED")
        sys.exit(1)
    print("\nAll verifications PASSED")

if __name__ == "__main__":
    main()
```

- [ ] **Step 4: Commit**

```bash
git add tools/ verify_braille.py deep_analysis.py
git commit -m "chore: organize Python tools into tools/ directory with unified CLI"
```

---

## Task C2: CI Python Verification

**Goal:** Chạy Python verification trong CI.

**Files:**
- Modify: `.github/workflows/ci.yml`

- [ ] **Step 1: Thêm python-verify job vào CI workflow**

(Đã có trong Task A5, chỉ cần verify hoạt động)

- [ ] **Step 2: Commit nếu cần sửa**

---

## Task C3: Parse Thông tư 15 PDF

**Goal:** Extract rules từ PDF thành structured data.

**Files:**
- Create: `tools/parse_rules.py`
- Create: `tools/data/tt15_rules.json`

- [ ] **Step 1: Tạo script parse PDF**

```python
#!/usr/bin/env python3
"""Parse Thông tư 15/2019 PDF into structured JSON."""
import pdfplumber
import json

def parse_pdf(pdf_path):
    rules = {"alphabet": {}, "tones": {}, "symbols": {}}
    with pdfplumber.open(pdf_path) as pdf:
        for page in pdf.pages:
            tables = page.extract_tables()
            for table in tables:
                for row in table:
                    # Parse rows into rules structure
                    pass
    return rules

if __name__ == "__main__":
    rules = parse_pdf("quytac/501196e24bee7141a3d2d37f879d04a615_2019_TT_BGDDT.pdf")
    with open("tools/data/tt15_rules.json", "w", encoding="utf-8") as f:
        json.dump(rules, f, ensure_ascii=False, indent=2)
    print("Rules parsed successfully")
```

- [ ] **Step 2: Chạy script, verify output**

```bash
python tools/parse_rules.py
```

- [ ] **Step 3: Commit**

```bash
git add tools/parse_rules.py tools/data/
git commit -m "feat: add PDF parser for Thông tư 15/2019 Braille rules"
```

---

## Task C4: Auto-generate Test Cases từ Rules

**Goal:** Tạo test cases tự động từ parsed rules.

**Files:**
- Create: `tools/generate_tests.py`

- [ ] **Step 1: Tạo script generate tests từ JSON**

- [ ] **Step 2: Chạy script, verify generated tests**

- [ ] **Step 3: Commit**

```bash
git add tools/generate_tests.py
git commit -m "feat: auto-generate test cases from Braille rules PDF"
```

---

## Task C5: Compliance Report

**Goal:** Tạo report app compliance với Thông tư 15.

**Files:**
- Create: `tools/compliance_report.py`

- [ ] **Step 1: Tạo script so sánh app mapping với rules**

- [ ] **Step 2: Chạy script, xem report**

- [ ] **Step 3: Commit**

```bash
git add tools/compliance_report.py
git commit -m "feat: add compliance report against Thông tư 15/2019"
```

---
---

# TRACK D: DOCUMENTATION

## Task D1: CONTRIBUTING.md

**Goal:** Hướng dẫn đóng góp chi tiết.

**Files:**
- Create: `CONTRIBUTING.md`

- [ ] **Step 1: Tạo CONTRIBUTING.md**

Nội dung: prerequisites, setup, code style, PR process, issue templates.

- [ ] **Step 2: Commit**

```bash
git add CONTRIBUTING.md
git commit -m "docs: add detailed contributing guide"
```

---

## Task D2: LICENSE

**Goal:** Thêm file LICENSE.

**Files:**
- Create: `LICENSE`

- [ ] **Step 1: Tạo MIT License**

- [ ] **Step 2: Commit**

```bash
git add LICENSE
git commit -m "chore: add MIT license"
```

---

## Task D3: User Guide

**Goal:** Hướng dẫn sử dụng app cho người dùng.

**Files:**
- Create: `docs/user-guide.md`

- [ ] **Step 1: Viết user guide**

Nội dung: cài đặt, cách dùng (text→Braille, Braille→text, OCR, export), FAQ.

- [ ] **Step 2: Commit**

```bash
git add docs/user-guide.md
git commit -m "docs: add user guide with step-by-step instructions"
```

---

## Task D4: Architecture Overview

**Goal:** Tài liệu kiến trúc với diagrams.

**Files:**
- Create: `docs/architecture.md`

- [ ] **Step 1: Viết architecture doc với Mermaid diagrams**

Nội dung: clean architecture layers, data flow, component relationships.

- [ ] **Step 2: Commit**

```bash
git add docs/architecture.md
git commit -m "docs: add architecture overview with Mermaid diagrams"
```

---

## Task D5: CHANGELOG.md

**Goal:** Theo dõi thay đổi theo định dạng Keep a Changelog.

**Files:**
- Create: `CHANGELOG.md`

- [ ] **Step 1: Tạo CHANGELOG.md**

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/).

## [Unreleased]

### Added
- Official README with badges and quick start
- Integration tests for full conversion pipeline
- Edge case tests for tone stacking, qu/gi rules
- CI pipeline with dart format, analyze, test
- Screen reader support (Semantics)
- Font size adjustment
- Voice input (Vietnamese speech-to-text)
- Flutter web build support
- Interactive Braille learning mode
- Quiz mode
- REST API server
- PDF export
- Batch processing
- Python tools organization with unified CLI
- Compliance report against Thông tư 15/2019

### Changed
- Reverse converter uses immutable state (no more state leak)
- composeNfc logic extracted to shared implementation

### Fixed
- State leak between consecutive convert() calls
```

- [ ] **Step 2: Commit**

```bash
git add CHANGELOG.md
git commit -m "docs: add changelog following Keep a Changelog format"
```

---

## Task D6: GitHub Issue Templates

**Goal:** Templates cho bug reports, feature requests.

**Files:**
- Create: `.github/ISSUE_TEMPLATE/bug_report.md`
- Create: `.github/ISSUE_TEMPLATE/feature_request.md`

- [ ] **Step 1: Tạo templates**

- [ ] **Step 2: Commit**

```bash
git add .github/ISSUE_TEMPLATE/
git commit -m "chore: add GitHub issue templates for bugs and features"
```

---

## Task D7: GitHub Pages Docs Site

**Goal:** Deploy docs site với MkDocs.

**Files:**
- Create: `mkdocs.yml`
- Create: `.github/workflows/docs.yml`

- [ ] **Step 1: Tạo mkdocs.yml**

- [ ] **Step 2: Tạo GitHub Actions workflow để deploy**

- [ ] **Step 3: Commit**

```bash
git add mkdocs.yml .github/workflows/docs.yml
git commit -m "docs: add MkDocs site with GitHub Pages deployment"
```

---
---

## Verification Checklist

Sau khi hoàn thành tất cả tasks:

- [ ] `cd viet_braille_app && dart format --set-exit-if-changed lib/ test/` → exit 0
- [ ] `cd viet_braille_app && dart analyze` → no warnings
- [ ] `cd viet_braille_app && flutter test` → all tests PASS
- [ ] `python tools/verify.py` → all verifications PASSED
- [ ] `cd api_server && dart run bin/server.dart` → server starts
- [ ] `git log --oneline -30` → clean commits
- [ ] README renders correctly on GitHub
- [ ] CI pipeline green

---

## Execution Order (Recommended)

**Sprint 1 (Tuần 1-2):** A1, A2, A5, D1, D2, C1
**Sprint 2 (Tuần 3-4):** A3, A4, A6, D3, C2
**Sprint 3 (Tuần 5-6):** A7, A8, B1, B2, D4
**Sprint 4 (Tuần 7-8):** B3, B4, B5, C3, D5
**Sprint 5 (Tuần 9-10):** B6, B7, C4, D6
**Sprint 6 (Tuần 11-12):** B8, B9, C5, D7
**Sprint 7-10:** Polish, maintenance, dependency updates

Tasks trong cùng sprint có thể chạy song song (độc lập nhau).
# Tài liệu lịch sử

> Kế hoạch này được lưu để truy vết quyết định, không phải tài liệu sử dụng
> hiện tại. Xem README và `docs/architecture.md`.
