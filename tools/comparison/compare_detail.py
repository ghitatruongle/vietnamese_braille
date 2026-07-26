"""
So sánh CHI TIẾT TỪNG ÁNH XẠ giữa file quy tắc và code app.
Đọc trực tiếp từ braille_mapping.dart để lấy mapping.
"""
import re
import os

# ============================================================
# 1. PARSE FILE QUY TẮC
# ============================================================
rules_file = r'E:\vietnamese_braille\quytac\trinh_bay_vb\quy_tac_trinh_bay_van_ban_braille.txt'
with open(rules_file, 'r', encoding='utf-8') as f:
    rules_text = f.read()

def dots_str_to_braille(dots_str):
    """Convert dot string like '1,3,5' or '135' to Braille Unicode char"""
    dots_str = dots_str.replace(',', '').replace(' ', '')
    val = 0
    for ch in dots_str:
        val |= (1 << (int(ch) - 1))
    return chr(0x2800 + val)

def verify_braille(dots_str, expected_braille, label=''):
    """Verify that dots string produces expected Braille char"""
    computed = dots_str_to_braille(dots_str)
    if computed == expected_braille:
        return True, computed
    else:
        return False, f"computed={computed}, expected={expected_braille}"

# Parse Section I: alphabet
alphabet_rules = {}
sec_start = rules_text.find('I. BANG CHU CAI TIENG VIET\n')
sec_end = rules_text.find('II. BANG CHU CAI')
section = rules_text[sec_start:sec_end]
for line in section.splitlines():
    m = re.match(r'\|\s*(.+?)\s*\(([\d, ]+)\)\s*\|\s*(\S+)\s*\|', line)
    if m:
        char = m.group(1).strip()
        dots = m.group(2).strip()
        braille = m.group(3).strip()
        alphabet_rules[char] = {'dots': dots, 'braille': braille}

# Parse Section II: extended
ext_start = rules_text.find('II. BANG CHU CAI TIENG VIET MO RONG')
ext_end = rules_text.find('III. DAU THANH')
section = rules_text[ext_start:ext_end]
extended_rules = {}
for line in section.splitlines():
    m = re.match(r'\|\s*(.+?)\s*\(([\d, ]+)\)\s*\|\s*(\S+)\s*\|', line)
    if m:
        char = m.group(1).strip()
        dots = m.group(2).strip()
        braille = m.group(3).strip()
        extended_rules[char] = {'dots': dots, 'braille': braille}

# Parse Section III: tones
tones_start = rules_text.find('III. DAU THANH')
tones_end = rules_text.find('IV. CAC KY HIEU')
section = rules_text[tones_start:tones_end]
tones_rules = {}
for line in section.splitlines():
    m = re.match(r'\|\s*(.+?)\s*\(([\d, ]+)\)\s*\|\s*(\S+)\s*\|', line)
    if m:
        name = m.group(1).strip()
        dots = m.group(2).strip()
        braille = m.group(3).strip()
        tones_rules[name] = {'dots': dots, 'braille': braille}

# Parse Section IV: symbols
sym_start = rules_text.find('IV. CAC KY HIEU TRINH BAY VAN BAN')
sym_end = rules_text.find('V. QUY TAC VIET CHU')
section = rules_text[sym_start:sym_end]
symbols_rules = {}
for line in section.splitlines():
    m = re.match(r'\|\s*(\d+)\.\s*(.+?)\s*\(([\d, ]+)\)\s*\|\s*(\S+)\s*\|', line)
    if m:
        num = m.group(1)
        name = m.group(2).strip()
        dots = m.group(3).strip()
        braille = m.group(4).strip()
        key = f"{num}.{name}"
        symbols_rules[key] = {'dots': dots, 'braille': braille}

print("=" * 80)
print("PHAN 1: TAT CA MAPPING TU FILE QUY TAC")
print("=" * 80)
print(f"\n  Alphabet: {len(alphabet_rules)} ký tự")
print(f"  Extended: {len(extended_rules)} ký tự")
print(f"  Tones:    {len(tones_rules)} ký tự")
print(f"  Symbols:  {len(symbols_rules)} ký hiệu")

# ============================================================
# 2. PARSE CODE APP (braille_mapping.dart)
# ============================================================
mapping_file = r'E:\vietnamese_braille\viet_braille_app\lib\core\braille_mapping.dart'
with open(mapping_file, 'r', encoding='utf-8') as f:
    app_text = f.read()

# Extract the _charToBraille map from the Dart code
# Look for static const _charToBraille = <String, String>{ ... };
char_map_match = re.search(
    r'static const _charToBraille\s*=\s*<String,\s*String>\{([^}]+)\}',
    app_text, re.DOTALL
)

app_alphabet = {}
if char_map_match:
    map_content = char_map_match.group(1)
    # Parse each line: "'a': '\u2801'," or "'ă': '\u281c',"
    for line in map_content.splitlines():
        line = line.strip()
        if not line or line.startswith('//'):
            continue
        m = re.match(r"'([^']+)':\s*'([^']+)',?", line)
        if m:
            char = m.group(1)
            braille = m.group(2)
            # Convert unicode escape to actual char
            braille_char = braille.encode('utf-8').decode('unicode_escape') if '\\u' in braille else braille
            app_alphabet[char] = braille_char

# Extract tone map
tone_map_match = re.search(
    r'static const _toneMap\s*=\s*<String,\s*String>\{([^}]+)\}',
    app_text, re.DOTALL
)

app_tones = {}
if tone_map_match:
    map_content = tone_map_match.group(1)
    for line in map_content.splitlines():
        line = line.strip()
        if not line or line.startswith('//'):
            continue
        m = re.match(r"'([^']+)':\s*'([^']+)',?", line)
        if m:
            name = m.group(1)
            braille = m.group(2)
            braille_char = braille.encode('utf-8').decode('unicode_escape') if '\\u' in braille else braille
            app_tones[name] = braille_char

# Extract indicators
indicators = {}
indicators_to_find = [
    'capitalIndicator', 'numberIndicator', 'allCapsIndicator',
    'capEachWordIndicator', 'specialFontIndicator', 'boldIndicator',
    'italicIndicator', 'underlineCharIndicator', 'underlineWordIndicator',
    'endUnderlineIndicator', 'boldItalicUnderlineIndicator',
    'endFormatIndicator', 'centerIndicator', 'abbrevWordIndicator',
    'abbrevPhraseIndicator', 'foreignIndicator', 'ampersandIndicator',
    'greekIndicator', 'greekCapIndicator', 'poetryIndicator',
    'endPoemIndicator', 'noteIndicator', 'endNoteIndicator',
]

for indicator in indicators_to_find:
    # Match: String get capitalIndicator => '\u2828';
    m = re.search(rf'String get {indicator}\s*=>\s*\'([^\']+)\';', app_text)
    if m:
        braille = m.group(1)
        braille_char = braille.encode('utf-8').decode('unicode_escape') if '\\u' in braille else braille
        indicators[indicator] = braille_char

print(f"\n  App alphabet: {len(app_alphabet)} ký tự")
print(f"  App tones:    {len(app_tones)} ký tự")
print(f"  App indicators: {len(indicators)} indicators")

# ============================================================
# 3. SO SÁNH CHI TIẾT
# ============================================================
errors = []
passed = 0
total = 0

def compare_char(name, rules_char, app_char, detail=''):
    global errors, passed, total
    total += 1
    if rules_char == app_char:
        passed += 1
        return True
    else:
        msg = f"{name}: rules='{rules_char}' (U+{ord(rules_char):04X}) ≠ app='{app_char}' (U+{ord(app_char):04X})"
        if detail:
            msg += f" | {detail}"
        errors.append(msg)
        return False

def braille_to_dots(char):
    """Convert Braille char to dot numbers string"""
    val = ord(char) - 0x2800
    dots = []
    for i in range(6):
        if val & (1 << i):
            dots.append(str(i + 1))
    return ''.join(dots) if dots else '0'

print("\n" + "=" * 80)
print("PHAN 2: SO SÁNH TỪNG KÝ TỰ")
print("=" * 80)

# --- Alphabet ---
print("\n--- BẢNG CHỮ CÁI ---")
for char in sorted(set(list(alphabet_rules.keys()) + list(app_alphabet.keys()))):
    in_rules = char in alphabet_rules
    in_app = char in app_alphabet
    
    if in_rules and not in_app:
        total += 1
        r_braille = alphabet_rules[char]['braille']
        print(f"  ❌ '{char}': CÓ trong quy tắc ({r_bralle}) nhưng KHÔNG có trong app")
        errors.append(f"Missing in app: '{char}'")
    elif in_app and not in_rules:
        total += 1
        print(f"  ❌ '{char}': CÓ trong app nhưng KHÔNG có trong quy tắc")
        errors.append(f"Missing in rules: '{char}'")
    else:
        r_braille = alphabet_rules[char]['braille']
        r_dots = alphabet_rules[char]['dots']
        a_braille = app_alphabet[char]
        
        ok = compare_char(char, r_braille, a_braille)
        
        if ok:
            dots_app = braille_to_dots(a_braille)
            # Check if app dots match rules dots
            rules_dots_normalized = r_dots.replace(',', '').replace(' ', '')
            if set(dots_app) == set(rules_dots_normalized) and len(dots_app) == len(rules_dots_normalized):
                print(f"  ✅ '{char}': dots={r_dots} → {a_braille} (U+{ord(a_braille):04X})")
            else:
                total -= 1  # undo the count, recount as error
                passed -= 1
                msg = f"'{char}': dots quy tắc={r_dots} nhưng dots app={dots_app}"
                errors.append(msg)
                print(f"  ❌ '{char}': dots quy tắc={r_dots} ≠ dots app={dots_app}")
        else:
            print(f"  ❌ {errors[-1]}")

# --- Extended alphabet ---
print("\n--- CHỮ MỞ RỘNG (f, j, w, z) ---")
extended_only = set(extended_rules.keys()) - set(alphabet_rules.keys())
for char in sorted(extended_only):
    if char not in app_alphabet:
        total += 1
        print(f"  ❌ '{char}': CÓ trong quy tắc nhưng KHÔNG có trong app")
        errors.append(f"Missing in app: '{char}'")
    else:
        r_braille = extended_rules[char]['braille']
        r_dots = extended_rules[char]['dots']
        a_braille = app_alphabet[char]
        
        ok = compare_char(char, r_braille, a_braille)
        
        if ok:
            dots_app = braille_to_dots(a_braille)
            rules_dots_normalized = r_dots.replace(',', '').replace(' ', '')
            if set(dots_app) == set(rules_dots_normalized) and len(dots_app) == len(rules_dots_normalized):
                print(f"  ✅ '{char}': dots={r_dots} → {a_braille} (U+{ord(a_braille):04X})")
            else:
                total -= 1
                passed -= 1
                msg = f"'{char}': dots quy tắc={r_dots} nhưng dots app={dots_app}"
                errors.append(msg)
                print(f"  ❌ '{char}': dots quy tắc={r_dots} ≠ dots app={dots_app}")
        else:
            print(f"  ❌ {errors[-1]}")

# --- Tones ---
print("\n--- DẤU THANH ---")
for name in sorted(set(list(tones_rules.keys()) + list(app_tones.keys()))):
    in_rules = name in tones_rules
    in_app = name in app_tones
    
    if in_rules and not in_app:
        total += 1
        print(f"  ❌ '{name}': CÓ trong quy tắc nhưng KHÔNG có trong app")
        errors.append(f"Missing in app tone: '{name}'")
    elif in_app and not in_rules:
        total += 1
        print(f"  ❌ '{name}': CÓ trong app nhưng KHÔNG có trong quy tắc")
        errors.append(f"Missing in rules tone: '{name}'")
    else:
        r_braille = tones_rules[name]['braille']
        r_dots = tones_rules[name]['dots']
        a_braille = app_tones[name]
        
        ok = compare_char(name, r_braille, a_braille)
        if ok:
            dots_app = braille_to_dots(a_braille)
            rules_dots_normalized = r_dots.replace(',', '').replace(' ', '')
            if set(dots_app) == set(rules_dots_normalized) and len(dots_app) == len(rules_dots_normalized):
                print(f"  ✅ {name}: dots={r_dots} → {a_braille} (U+{ord(a_braille):04X})")
            else:
                total -= 1
                passed -= 1
                msg = f"'{name}': dots quy tắc={r_dots} nhưng dots app={dots_app}"
                errors.append(msg)
                print(f"  ❌ {name}: dots quy tắc={r_dots} ≠ dots app={dots_app}")
        else:
            print(f"  ❌ {errors[-1]}")

print(f"\n{'=' * 80}")
print(f"TỔNG: {passed}/{total} ánh xạ đúng")
if errors:
    print(f"\n❌ LỖI ({len(errors)}):")
    for e in errors:
        print(f"  - {e}")
else:
    print("\n✅ TẤT CẢ ĐỀU ĐÚNG!")
