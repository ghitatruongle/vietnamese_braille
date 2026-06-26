"""
Kiem tra chuan Unicode Braille U+2800-U+28FF va so sanh voi app.
Unicode Braille Pattern la tieu chuan quoc te (ISO/IEC 11548-1).
"""

def dots_to_braille(dots):
    val = 0
    for d in dots:
        val |= (1 << (d - 1))
    return chr(0x2800 + val)

def braille_to_dots(char):
    val = ord(char) - 0x2800
    dots = []
    for i in range(6):
        if val & (1 << i):
            dots.append(i + 1)
    return dots

# ============================================================
# CHUAN 6-DOT BRAILLE (Unicode official)
# ============================================================

unicode_alphabet = {
    'a': [1],        'b': [1,2],      'c': [1,4],
    'd': [1,4,5],    'e': [1,5],      'f': [1,2,4],
    'g': [1,2,4,5],  'h': [1,2,5],    'i': [2,4],
    'j': [2,4,5],    'k': [1,3],      'l': [1,2,3],
    'm': [1,3,4],    'n': [1,3,4,5],  'o': [1,3,5],
    'p': [1,2,3,4],  'q': [1,2,3,4,5],'r': [1,2,3,5],
    's': [2,3,4],    't': [2,3,4,5],  'u': [1,3,6],
    'v': [1,2,3,6],  'w': [2,4,5,6],  'x': [1,3,4,6],
    'y': [1,3,4,5,6],'z': [1,3,5,6],
}

# Standard UEB punctuation
ueb_punctuation = {
    'period (.': [2,5,6],
    'comma (,)': [2],
    'question (?)': [2,3,6],
    'exclaim (!)': [2,3,5],
    'colon (:)': [2,5],
    'semicolon (;)': [2,3],
    'dash (-)': [3,6],
    "squote_apos": [3],
    'dquote_open': [2,3,6],
    'dquote_close': [3,5,6],
    'num_indicator': [3,4,5,6],
    'capital': [4,6],
}

# App mappings from braille_mapping.dart
app_punct = {
    'period': [2,5,6],
    'comma': [2],
    'question': [2,6],       # <-- CAN KIEM TRA
    'exclaim': [2,3,5],
    'colon': [2,5],
    'semicolon': [2,3],
    'dash': [3,6],
    'squote': [3],
    'dquote_open': [2,3,6],
    'dquote_close': [3,5,6],
}

# Vietnamese tone marks (Vietnamese-specific, not in UEB)
viet_tones = {
    'tone_sac': [3,5],
    'tone_huyen': [5,6],
    'tone_hoi': [2,6],
    'tone_nga': [3,6],
    'tone_nang': [6],
}

print("=" * 80)
print("SO SANH APP CODE VOI CHUAN UEB (Unified English Braille)")
print("=" * 80)

print()
print("PUNCTUATION - App vs UEB Standard:")
print("-" * 70)
print("  {:20s} {:>6s}  {:>6s}  {:>8s}".format("Ten", "App", "UEB", "Khop?"))
print("  {:20s} {:>6s}  {:>6s}  {:>8s}".format("-" * 20, "-" * 6, "-" * 6, "-" * 8))

for key in sorted(ueb_punctuation.keys()):
    if key not in app_punct:
        print("  {:20s} {:>6s}  {:>6s}  {:>8s}".format(key, "N/A", "", "thieu"))
        continue
    
    app_dots = app_punct[key]
    ueb_dots = ueb_punctuation[key]
    
    app_char = dots_to_braille(app_dots)
    ueb_char = dots_to_braille(ueb_dots)
    
    match = "OK" if app_dots == ueb_dots else "SAI!"
    
    app_dots_str = ''.join(str(d) for d in app_dots)
    ueb_dots_str = ''.join(str(d) for d in ueb_dots)
    
    print("  {:20s} {}({})  {}({})  {:>8s}".format(
        key, app_char, app_dots_str, ueb_char, ueb_dots_str, match))

# ============================================================
# COLLISION ANALYSIS
# ============================================================
print()
print("=" * 80)
print("PHAN TICH COLLISION - DAU THANH vs DAU CAU")
print("=" * 80)

all_items = {}
for name, dots in viet_tones.items():
    char = dots_to_braille(dots)
    all_items[name] = (dots, char, "DAU THANH")

for name, dots in app_punct.items():
    char = dots_to_braille(dots)
    all_items[name] = (dots, char, "DAU CAU")

by_char = {}
for name, (dots, char, cat) in all_items.items():
    if char not in by_char:
        by_char[char] = []
    by_char[char].append((name, dots, cat))

collision_count = 0
for char in sorted(by_char.keys()):
    items = by_char[char]
    if len(items) > 1:
        collision_count += 1
        dots_str = ''.join(str(d) for d in items[0][1])
        print()
        print("  COLLISION: {} (U+{:04X}) dots {}".format(char, ord(char), dots_str))
        for name, dots, cat in items:
            print("    [{:12s}] {}".format(cat, name))

print()
print("  Tong collision: {}".format(collision_count))

# ============================================================
# ALPHABET CHECK
# ============================================================
print()
print("=" * 80)
print("KIEM TRA BANG CHU CAI APP vs CHUAN UNICODE")
print("=" * 80)

app_alphabet = {
    'a': [1], 'b': [1,2], 'c': [1,4], 'd': [1,4,5], 'e': [1,5],
    'f': [1,2,4], 'g': [1,2,4,5], 'h': [1,2,5], 'i': [2,4], 'j': [2,4,5],
    'k': [1,3], 'l': [1,2,3], 'm': [1,3,4], 'n': [1,3,4,5], 'o': [1,3,5],
    'p': [1,2,3,4], 'q': [1,2,3,4,5], 'r': [1,2,3,5], 's': [2,3,4],
    't': [2,3,4,5], 'u': [1,3,6], 'v': [1,2,3,6], 'w': [2,4,5,6],
    'x': [1,3,4,6], 'y': [1,3,4,5,6], 'z': [1,3,5,6],
}

alphabet_ok = 0
alphabet_err = 0
for letter in sorted(app_alphabet.keys()):
    if app_alphabet[letter] == unicode_alphabet[letter]:
        alphabet_ok += 1
    else:
        alphabet_err += 1
        print("  SAI: '{}' app={} standard={}".format(
            letter, app_alphabet[letter], unicode_alphabet[letter]))

print()
print("  Alphabet: {}/{} dung chuan Unicode 6-dot Braille".format(alphabet_ok, alphabet_ok + alphabet_err))

# ============================================================
# VIETNAMESE TONE MARKS VERIFICATION
# ============================================================
print()
print("=" * 80)
print("DAU THANH TIENG VIET (doc quyen - khong co trong UEB)")
print("=" * 80)
print()
print("  Day la quy dinh rieng cua Viet Nam theo Bo GD&DT.")
print("  Khong co trong chuan UEB quoc te.")
print()
for name, dots in sorted(viet_tones.items()):
    char = dots_to_braille(dots)
    dots_str = ''.join(str(d) for d in dots)
    print("  {:12s} dots={:>6s} -> {}  U+{:04X}".format(name, dots_str, char, ord(char)))

# ============================================================
# COLLISION DETAIL + SOLUTION
# ============================================================
print()
print("=" * 80)
print("CHI TIET COLLISION VA GIAI PHAP")
print("=" * 80)

print()
print("  COLLISION 1: U+2822 (dots 2,6)")
print("    [DAU THANH ] tone_hoi (quy tac VN: dots 26 = U+2822)")
print("    [DAU CAU   ] question (?) - App dung dots 2,6 = U+2822")
print("    [CHUAN UEB ] Question mark = dots 2,3,6 = U+2826 (KHAC!)")
print()
print("    => App dung SAI chuan UEB cho dau cham hoi")
print("    => Neu sua theo UEB (dots 2,3,6) se trung voi dquote_open")
print()
print("    GIAI PHAP TOT NHAT:")
print("      Sua _question = _symbolPrefix + _cell(_d2 | _d3 | _d6)")
print("                   = U+2808 + U+2826 = 2 ky tu")
print("      Ly do: App da dung prefix nay cho ( ) / _ @ $ ^")

print()
print("  COLLISION 2: U+2824 (dots 3,6)")
print("    [DAU THANH ] tone_nga (quy tac VN: dots 36 = U+2824)")
print("    [DAU CAU   ] dash (-) - App dung dots 3,6 = U+2824")
print("    [CHUAN UEB ] Dash = dots 3,6 = U+2824 (GIONG app!)")
print()
print("    => App dung DUNG chuan UEB cho dash")
print("    => Nhung trung voi tone_nga cua tieng Viet")
print()
print("    GIAI PHAP:")
print("      Sua _dash = _symbolPrefix + _cell(_d3 | _d6)")
print("                = U+2808 + U+2824 = 2 ky tu")
print("      Giong cach app da lam voi cac ky hieu dac biet khac")

# ============================================================
# SUMMARY TABLE
# ============================================================
print()
print("=" * 80)
print("TOM TAT - TAT CA KY TU CAN SUA")
print("=" * 80)
print()
print("  Ky tu         | Hien tai       | Nen sua thanh      | Ly do")
print("  " + "-" * 70)
print("  _question (?) | _cell(2,6)     | _symbolPrefix      | Sai UEB, trung")
print("                | = U+2822       | + _cell(2,3,6)     | voi tone_hoi")
print("                | = ⠢            | = U+2808+U+2826    |")
print("                |                | = ⠈⠦               |")
print("  " + "-" * 70)
print("  _dash (-)     | _cell(3,6)     | _symbolPrefix      | Dung UEB nhung")
print("                | = U+2824       | + _cell(3,6)       | trung voi")
print("                | = ⠤            | = U+2808+U+2824    | tone_nga")
print("                |                | = ⠈⠤               |")
