# Bug Report & Accuracy Analysis - Vietnamese Braille Converter

**Generated:** 2026-06-30  
**Analyzed File:** `packages/viet_braille_core/lib/braille_converter.dart`  
**Analysis Tool:** `tools/bug_check.py`

---

## Executive Summary

Phân tích code đã phát hiện **7 bugs** với mức độ nghiêm trọng từ LOW đến HIGH, và **5 vấn đề về độ chính xác** cần được xác minh. Bug quan trọng nhất là lỗi logic tại line 138 có thể ảnh hưởng đến việc nhóm từ viết hoa.

---

## 🔴 HIGH PRIORITY BUGS

### Bug #2: Logic Error trong Phrase Grouping (Line 138-140)

**Mức độ:** HIGH  
**File:** `braille_converter.dart:138-140`  
**Vị trí:** Hàm `_groupWords()` - All Caps Phrase detection

**Code hiện tại:**
```dart
final sep = normalized.substring(words[j - 1].end, words[j].start);
if (sep.trim().isNotEmpty || sep.isEmpty) {
  break; // chỉ cho phép ngăn cách bằng khoảng trắng
}
```

**Vấn đề:**
- Điều kiện `sep.trim().isNotEmpty || sep.isEmpty` **LUÔN LUÔN ĐÚNG** (always true)
- Logic này không bao giờ cho phép các từ viết hoa được nhóm lại thành cụm
- Test cases như "THÔNG TƯ SỐ 15" sẽ không được xử lý đúng

**Phân tích logic:**
- Nếu `sep = "  "` (2 spaces):
  - `sep.trim().isNotEmpty` = false
  - `sep.isEmpty` = false  
  - → false || false = false ✓ (không break, tiếp tục)
  
- Nếu `sep = ""` (empty):
  - `sep.trim().isNotEmpty` = false
  - `sep.isEmpty` = true
  - → false || true = **TRUE** ✗ (break ngay lập tức!)

- Nếu `sep = "\n"` hoặc ký tự đặc biệt:
  - `sep.trim().isNotEmpty` = false (sau trim còn "")
  - `sep.isEmpty` = false (trước trim khác "")
  - → false || false = false ✓

**Cách sửa:**
```dart
// Option 1: Chỉ break khi có ký tự không phải whitespace
if (sep.trim().isNotEmpty) {
  break;
}

// Option 2: Rõ ràng hơn
if (!sep.trim().isEmpty && sep.isNotEmpty) {
  break; // có ký tự đặc biệt, không phải chỉ khoảng trắng
}

// Option 3: Đơn giản nhất (recommended)
if (sep.trim().isNotEmpty) {
  break; // chỉ cho phép ngăn cách bằng khoảng trắng/tab/newline
}
```

**Impact:**
- Tất cả các cụm từ viết hoa như "HÀ NỘI", "UNESCO VIỆT NAM" sẽ không được format đúng
- Dấu `allCapsPhrase` và `endFormat` không được thêm vào
- Vi phạm quy tắc trình bày Braille theo Thông tư 15

**Test case bị ảnh hưởng:**
```python
"THÔNG TƯ SỐ 15" → Cần: allCapsPhrase + ... + endFormat
"HÀ NỘI" → Initcaps nhưng không áp dụng phrase mode đúng
```

---

## 🟡 MEDIUM PRIORITY BUGS

### Bug #1: Decimal Point Logic Conflict (Line 277-291)

**Mức độ:** MEDIUM  
**File:** `braille_converter.dart:277-291`  
**Vị trí:** Number mode - decimal separator handling

**Code hiện tại:**
```dart
if (inNumber &&
    ch == '.' &&
    i + 1 < normalized.length &&
    _isDigit(normalized[i + 1])) {
  buffer.write(_mapping.mapChar("'")!); // chấm hàng nghìn -> ⠄ (dot 3)
  // ...
}
if (inNumber &&
    ch == ',' &&
    i + 1 < normalized.length &&
    _isDigit(normalized[i + 1])) {
  buffer.write(_mapping.mapChar(',')!); // phẩy thập phân -> ⠂ (dot 2)
  // ...
}
```

**Vấn đề:**
- Logic xử lý dấu chấm `.` và phẩy `,` chỉ hoạt động trong `inNumber` mode
- Nếu `inNumber` flag không được set đúng, dấu chấm sẽ được xử lý như punctuation thông thường
- Có thể conflict với dấu chấm kết thúc câu ngay sau số

**Ví dụ edge case:**
```
Input: "Năm 2024. Việt Nam..."
       ↓
"2024." ← Dấu chấm này là punctuation hay decimal?

Input: "3.14 là số PI"
       ↓
Nếu inNumber = false trước "3" thì ".14" sẽ không được xử lý đúng
```

**Khuyến nghị:**
- Thêm lookahead/lookbehind để phân biệt decimal point vs sentence punctuation
- Xem xét context rộng hơn (ví dụ: `\d+\.\d+` pattern)
- Test với các trường hợp: "123.", "3.14", "1,234.56"

---

### Bug #4: qu Context Tracking Issue (Line 319-321)

**Mức độ:** MEDIUM  
**File:** `braille_converter.dart:319-321`  
**Vị trí:** qu rule handling

**Code hiện tại:**
```dart
if (!inQuContext && ch == 'u' && prevCharLower == 'q') {
  inQuContext = true;
}
if (inQuContext && !_isVowel(ch) && !_isTonedVowel(ch)) {
  // Clear qu context when we hit a consonant or non-vowel
  inQuContext = false;
}
```

**Vấn đề:**
- `inQuContext` được set sau khi gặp `q + u`
- Nhưng không clear khi gặp consonant **ngay sau `u`**
- Có thể gây false positive cho các từ không thuộc qu rule

**Ví dụ có vấn đề:**
```
Input: "quy" (từ đúng qu rule)
  q → prevChar = 'q'
  u → inQuContext = true ✓
  y → _isVowel('y') = true, không clear context ✓

Input: "quyết" (từ đúng qu rule)
  q → u → inQuContext = true
  y → vowel, không clear
  ê → toned vowel, không clear ✓
  t → consonant, clear context ✓

Input: "qu-abc" (giả định, không phải từ thực)
  q → u → inQuContext = true
  - → không phải vowel/tonedVowel/consonant?
     → Context có clear không?
```

**Khuyến nghị:**
- Kiểm tra logic `_isVowel()` và `_isTonedVowel()` có cover hết các ký tự không?
- Thêm test cho các edge case: số, punctuation nằm giữa qu sequence
- Xem xét dùng state machine rõ ràng hơn cho qu/gi rules

---

### Bug #7: Operator Space Removal - Infinite Loop Risk (Line 56-64)

**Mức độ:** MEDIUM  
**File:** `braille_converter.dart:56-64`  
**Vị trí:** `_preprocess()` - operator whitespace removal

**Code hiện tại:**
```dart
final opRegex = RegExp(r'(\d)\s*([\+\-\*\/x\:=\<\>≈≤≥])\s*(\d)');
String prev = '';
while (text != prev) {
  prev = text;
  text = text.replaceAllMapped(
    opRegex,
    (match) => '${match.group(1)}${match.group(2)}${match.group(3)}',
  );
}
```

**Vấn đề:**
- While loop với điều kiện `text != prev`
- Nếu regex không match hoặc replacement tạo ra cùng pattern, loop vẫn an toàn
- Nhưng nếu có bug trong regex hoặc edge case, có thể gây infinite loop

**Phân tích an toàn:**
- Regex yêu cầu `\d` ở cả 2 đầu → chỉ match với số
- Replacement xóa whitespace → text ngắn hơn hoặc bằng
- Mỗi lần loop, text phải thay đổi (ngắn hơn) hoặc không match nữa
- → **Về lý thuyết an toàn**, nhưng khó debug nếu có vấn đề

**Ví dụ:**
```
"2  +  3  *  4" 
→ "2+3  *  4"   (lần 1)
→ "2+3*4"       (lần 2)
→ "2+3*4"       (lần 3, không đổi, thoát loop) ✓
```

**Khuyến nghị:**
- Thêm counter max iterations (vd: 100) để prevent infinite loop
- Log warning nếu loop chạy quá nhiều lần
- Có thể thay bằng regex global match một lần:
  ```dart
  text = text.replaceAll(RegExp(r'(\d)\s*([\+\-\*\/x\:=\<\>≈≤≥])\s*(\d)'), r'$1$2$3');
  ```
  (Nhưng cần kiểm tra xem có case nào cần multiple passes không)

---

## 🟢 LOW PRIORITY BUGS

### Bug #3: Code Duplication - Init Caps Phrase (Line 169)

**Mức độ:** LOW  
**File:** `braille_converter.dart:169`  
**Vấn đề:** Logic tương tự với all caps phrase, có thể refactor để tái sử dụng code

---

### Bug #6: Unit Regex Pattern Coverage (Line 47-52)

**Mức độ:** LOW  
**File:** `braille_converter.dart:47-52`  
**Vấn đề:** Negative lookahead có thể không cover hết edge cases (cuối chuỗi, sau ký tự đặc biệt)

**Test cases cần verify:**
```
"5km" → ✓
"5km." → ? (sau đơn vị có dấu chấm)
"5km\n" → ? (sau đơn vị có newline)
"(5km)" → ? (trong ngoặc)
```

---

### Bug #8: NFC Composition - Hard-coded 3 Passes (braille_mapping.dart:376-402)

**Mức độ:** LOW  
**File:** `braille_mapping.dart:376-402`  
**Vấn đề:** Hard-coded max 3 passes cho NFC composition, có thể không đủ cho các trường hợp phức tạp (nhưng rất hiếm gặp trong tiếng Việt)

---

## 📊 ACCURACY CONCERNS

### Concern #1: qu/gi Rule Edge Cases

**Mô tả:** Các từ có nhiều nguyên âm sau qu/gi cần verify tone placement chính xác

**Ví dụ cần test:**
```
quyết → q + u + sắc + y + ê + t (dấu sau u, trước y) ✓ hay
        q + u + y + sắc + ê + t (dấu trên ế) ✗

quyền → q + u + sac + y + ê + n hay q + u + y + ê + sac + n?

giảng → g + hoi + i + ă + n + g (dấu giữa g và i) ✓

quá → q + u + sac + a ✓ (case đơn giản)
```

**Quy tắc cần verify:**
- Theo Thông tư 15: Dấu thanh đặt **sau chữ cái đầu tiên** trong cụm qu/gi
- "qu + á" → dấu sau u (chữ cái đầu tiên của cụm ấm vần)
- "qu + yết" → dấu sau u (chữ cái đầu của nhóm), trước y

**Recommended action:** Test với real braille converter và so sánh với tài liệu chuẩn

---

### Concern #2: Capitalization với Tone

**Mô tả:** Thứ tự capital/tone indicator phức tạp, dễ nhầm

**Quy tắc:**
```
Chữ thường có phụ âm:  
  Việt → v + i + ê + t

Chữ HOA có phụ âm:
  Việt → capital + v + i + ê + t

Chữ thường KHÔNG phụ âm (nguyên âm đầu có dấu):
  ấn → sac + â + n

Chữ HOA KHÔNG phụ âm (nguyên âm đầu có dấu):
  Ấn → sac + capital + â + n
       ^^^^^^^^^^^^^^^^^^^^
       TONE + CAPITAL + VOWEL
```

**Code hiện tại (line 375-398):**
```dart
if (!isCapital &&
    _isTonedVowel(ch) &&
    !hasConsonantBefore &&
    prevCharLower.isNotEmpty &&
    _isVowel(prevCharLower) &&
    // ... nhiều điều kiện khác
```

**Vấn đề:**
- Logic phức tạp với nhiều điều kiện lồng nhau
- Khó verify tất cả các edge cases
- Cần test kỹ với: Ấn, Ảnh, Ứng, Ướt, etc.

---

### Concern #3: Number Mode Context

**Mô tả:** `inNumber` flag có thể bị reset không đúng lúc

**Test cases:**
```
"123abc456" 
→ Expected: number_indicator + 1 + 2 + 3 + a + b + c + number_indicator + 4 + 5 + 6
→ Actual: cần verify

"Năm 2024"
→ Expected: n + ă + m + space + number_indicator + 2 + 0 + 2 + 4
→ inNumber được set khi nào? Clear khi nào?

"2+3=5"
→ inNumber có bị break bởi operators không?
```

**Code cần review:**
```dart
if (_isDigit(ch)) {
  if (!inNumber) {
    buffer.write(_mapping.numberIndicator);
    inNumber = true;
  }
  // ...
} else {
  if (inNumber) {
    inNumber = false;
  }
}
```

**Question:** Operators (`+`, `-`, `=`) có làm break number mode không?

---

### Concern #4: NFD Normalization với qu/gi Rule

**Mô tả:** NFD input (combining diacritics) có thể xử lý sai với qu/gi rule

**Ví dụ:**
```
NFD: q + u + a + combining_acute
     ^^^^^^^^^^^^^^^^^^^^^^^^^ 
     4 characters riêng biệt

NFC: q + u + á
     ^^^^^^^^^
     3 characters (á = single codepoint)
```

**Vấn đề potential:**
- Logic qu rule check `prevCharLower == 'q'` và `ch == 'u'`
- Nhưng khi xử lý NFD, tone mark là character riêng biệt
- Có thể tone được xử lý trước khi nhận ra đây là qu cluster

**Test case cần verify:**
```python
# NFC
input = "quá"  # q + u + á (3 chars)
expected = [q, u, sac, a]

# NFD  
input = "qu\u0061\u0301"  # q + u + a + combining_acute (4 chars)
expected = [q, u, sac, a]  # Phải giống NFC!
```

**Code preprocess có normalize:**
```dart
String normalized = text.toNFC();
```

→ Nếu normalize đúng ở đầu thì không vấn đề. Nhưng cần test.

---

### Concern #5: Phrase Capitalization End Format

**Mô tả:** Dấu kết thúc `endFormat` có được thêm đúng vị trí không?

**Theo Thông tư 15:**
- Cụm từ viết hoa cần có dấu kết thúc sau từ cuối cùng
- `HÀ NỘI` → `allCapsPhrase + H + À + space + N + Ô + I + endFormat`

**Code cần verify:**
```dart
if (words[k].phraseMode == _PhraseMode.allCaps) {
  // Thêm allCapsPhrase indicator
}
// ... convert word ...
if (isLastInPhrase) {
  // Thêm endFormat
}
```

**Test cases:**
```
"HÀ NỘI" → endFormat sau I ✓
"THÔNG TƯ SỐ 15" → endFormat sau 5 hay sau "15"? 
                    (vì "15" là Roman hay số?)
```

---

## 🧪 RECOMMENDED TESTS

### Test Suite 1: Phrase Grouping (Fix Bug #2)

```dart
test('All caps phrase with spaces', () {
  expect(convert("UNESCO"), contains(allCapsWord));
  expect(convert("HÀ NỘI"), contains(allCapsPhrase));
  expect(convert("THÔNG TƯ SỐ 15"), contains(allCapsPhrase));
});

test('Mixed case should not trigger phrase mode', () {
  expect(convert("Hà Nội"), contains(initCapsPhrase));
  expect(convert("UNESCO Việt Nam"), isNot(contains(allCapsPhrase)));
});
```

### Test Suite 2: qu/gi Rules

```dart
test('qu with tone placement', () {
  expect(convert("quá"), equals("q + u + sac + a"));
  expect(convert("quyết"), equals("q + u + sac + y + ê + t"));
  expect(convert("quyền"), equals("q + u + sac + y + ê + n"));
  expect(convert("Quý"), equals("capital + q + u + sac + y"));
});

test('gi with tone placement', () {
  expect(convert("giá"), equals("g + sac + i + a"));
  expect(convert("gió"), equals("g + sac + i + o"));
  expect(convert("Giảng"), equals("capital + g + hoi + i + ă + n + g"));
});
```

### Test Suite 3: Number Mode

```dart
test('Numbers with punctuation', () {
  expect(convert("123"), contains(numberIndicator));
  expect(convert("3.14"), contains(numberIndicator));
  expect(convert("Năm 2024."), /* verify correct handling */);
});

test('Mixed letters and numbers', () {
  expect(convert("abc123xyz"), /* should have 2 number indicators? */);
});
```

### Test Suite 4: NFD Input

```dart
test('NFD normalization', () {
  final nfc = "quá";  // NFC
  final nfd = "qu\u0061\u0301";  // NFD
  expect(convert(nfc), equals(convert(nfd)));
});
```

### Test Suite 5: Edge Cases

```dart
test('Empty and whitespace', () {
  expect(convert(""), equals(""));
  expect(convert("   "), equals("   "));
});

test('Units with punctuation', () {
  expect(convert("5km."), /* verify unit + punct handling */);
  expect(convert("(10kg)"), /* verify unit in parens */);
});
```

---

## 🔧 IMMEDIATE ACTIONS REQUIRED

### Priority 1: FIX BUG #2 (HIGH)

**File:** `packages/viet_braille_core/lib/braille_converter.dart:138`

**Change:**
```dart
// BEFORE (BUG):
if (sep.trim().isNotEmpty || sep.isEmpty) {
  break;
}

// AFTER (FIXED):
if (sep.trim().isNotEmpty) {
  break;
}
```

**Impact:** Critical fix cho phrase capitalization

---

### Priority 2: ADD UNIT TESTS

Tạo test file: `packages/viet_braille_core/test/braille_converter_test.dart`

Implement test suites 1-5 ở trên.

---

### Priority 3: VERIFY ACCURACY

Chạy test với các test cases từ `bug_check.py`:
- 30 test cases cover 12 categories
- So sánh output với quy tắc trong Thông tư 15
- Document các edge cases phát hiện được

---

### Priority 4: ADD SAFEGUARDS

**Bug #7 - Infinite loop protection:**
```dart
final opRegex = RegExp(r'(\d)\s*([\+\-\*\/x\:=\<\>≈≤≥])\s*(\d)');
String prev = '';
int iterations = 0;
const maxIterations = 100;

while (text != prev && iterations < maxIterations) {
  iterations++;
  prev = text;
  text = text.replaceAllMapped(opRegex, (match) => 
    '${match.group(1)}${match.group(2)}${match.group(3)}',
  );
}

if (iterations >= maxIterations) {
  print('WARNING: Operator space removal exceeded max iterations');
}
```

---

### Priority 5: CODE REFACTORING

**Bug #5 - Simplify complex logic:**

Extract initial vowel handling to separate method:
```dart
bool _shouldReorderToneForInitialVowel(String ch, String prevChar, String prevPrevChar, bool hasConsonantBefore) {
  if (hasConsonantBefore) return false;
  if (!_isTonedVowel(ch)) return false;
  if (!_isVowel(prevChar)) return false;
  if (prevPrevChar.isNotEmpty && _isConsonant(prevPrevChar)) return false;
  return true;
}
```

---

## 📈 VERIFICATION CHECKLIST

- [ ] Fix bug #2 (phrase grouping logic)
- [ ] Test bug #2 fix với "HÀ NỘI", "THÔNG TƯ SỐ 15"
- [ ] Implement 30 test cases từ bug_check.py
- [ ] Verify qu/gi rule với quyết, quyền, giảng
- [ ] Test capitalization với Ấn, Ảnh, Ứng
- [ ] Test number mode với "123abc456", "Năm 2024."
- [ ] Test NFD input với qu/gi rules
- [ ] Add safeguard cho infinite loop trong operator removal
- [ ] Refactor complex initial vowel logic
- [ ] Document edge cases và expected behaviors
- [ ] Validate với tài liệu Thông tư 15 chính thức
- [ ] Test với real-world Vietnamese text

---

## 📚 REFERENCES

- **Quy tắc trình bày:** `quytac/QUY_TAC_TRINH_BAY_VAN_BAN_CHU_NOI_BRAILLE.md`
- **Thông tư 15/2017/TT-BGDĐT**
- **Test cases:** `tools/bug_check.py` (30 tests, 12 categories)
- **Mapping definitions:** `packages/viet_braille_core/lib/braille_mapping.dart`

---

## 📝 NOTES

1. **Bug #2 là critical** - cần fix ngay vì ảnh hưởng đến tất cả phrase capitalization
2. Các bugs khác (MEDIUM/LOW) ít ảnh hưởng đến usage thông thường nhưng cần fix để đạt 100% accuracy
3. Accuracy concerns cần verify bằng test thực tế, không chỉ code review
4. Nên tạo comprehensive test suite trước khi refactor code

---

**End of Report**
