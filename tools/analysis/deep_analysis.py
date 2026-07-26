"""
Phan tich sau XUNG DOT va KIEM TRA TOAN BO mapping giua quy tac va code app
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
# TAT CA MAPPING TU APP CODE (da parse tu braille_mapping.dart)
# ============================================================
app_mapping = {
    # Alphabet
    'a': ([1], dots_to_braille([1])),
    'b': ([1,2], dots_to_braille([1,2])),
    'c': ([1,4], dots_to_braille([1,4])),
    'd': ([1,4,5], dots_to_braille([1,4,5])),
    'e': ([1,5], dots_to_braille([1,5])),
    'f': ([1,2,4], dots_to_braille([1,2,4])),
    'g': ([1,2,4,5], dots_to_braille([1,2,4,5])),
    'h': ([1,2,5], dots_to_braille([1,2,5])),
    'i': ([2,4], dots_to_braille([2,4])),
    'j': ([2,4,5], dots_to_braille([2,4,5])),
    'k': ([1,3], dots_to_braille([1,3])),
    'l': ([1,2,3], dots_to_braille([1,2,3])),
    'm': ([1,3,4], dots_to_braille([1,3,4])),
    'n': ([1,3,4,5], dots_to_braille([1,3,4,5])),
    'o': ([1,3,5], dots_to_braille([1,3,5])),
    'p': ([1,2,3,4], dots_to_braille([1,2,3,4])),
    'q': ([1,2,3,4,5], dots_to_braille([1,2,3,4,5])),
    'r': ([1,2,3,5], dots_to_braille([1,2,3,5])),
    's': ([2,3,4], dots_to_braille([2,3,4])),
    't': ([2,3,4,5], dots_to_braille([2,3,4,5])),
    'u': ([1,3,6], dots_to_braille([1,3,6])),
    'v': ([1,2,3,6], dots_to_braille([1,2,3,6])),
    'w': ([2,4,5,6], dots_to_braille([2,4,5,6])),
    'x': ([1,3,4,6], dots_to_braille([1,3,4,6])),
    'y': ([1,3,4,5,6], dots_to_braille([1,3,4,5,6])),
    'z': ([1,3,5,6], dots_to_braille([1,3,5,6])),
    # Vietnamese vowels
    'aw': ([3,4,5], dots_to_braille([3,4,5])),   # ă
    'aa': ([1,6], dots_to_braille([1,6])),       # â
    'ee': ([1,2,6], dots_to_braille([1,2,6])),   # ê
    'oo': ([1,4,5,6], dots_to_braille([1,4,5,6])),  # ô
    'ow': ([2,4,6], dots_to_braille([2,4,6])),   # ơ
    'uw': ([1,2,5,6], dots_to_braille([1,2,5,6])),  # ư
    'dj': ([2,3,4,6], dots_to_braille([2,3,4,6])),  # đ
    # Tone marks
    'tone_sac': ([3,5], dots_to_braille([3,5])),
    'tone_huyen': ([5,6], dots_to_braille([5,6])),
    'tone_hoi': ([2,6], dots_to_braille([2,6])),
    'tone_nga': ([3,6], dots_to_braille([3,6])),
    'tone_nang': ([6], dots_to_braille([6])),
    # Punctuation - tu app code
    'punct_comma': ([2], dots_to_braille([2])),
    'punct_period': ([2,5,6], dots_to_braille([2,5,6])),
    'punct_question': ([2,6], dots_to_braille([2,6])),   # <-- TRUNG VOI DAU HOI!
    'punct_exclaim': ([2,3,5], dots_to_braille([2,3,5])),
    'punct_colon': ([2,5], dots_to_braille([2,5])),
    'punct_semicolon': ([2,3], dots_to_braille([2,3])),
    'punct_squote': ([3], dots_to_braille([3])),
    'punct_dash': ([3,6], dots_to_braille([3,6])),  # <-- TRUNG VOI DAU NGA!
    'punct_dquote_open': ([2,3,6], dots_to_braille([2,3,6])),
    'punct_dquote_close': ([3,5,6], dots_to_braille([3,5,6])),
    'punct_backslash': ([3,4], dots_to_braille([3,4])),
    # Indicators
    'capital': ([4,6], dots_to_braille([4,6])),
    'number': ([3,4,5,6], dots_to_braille([3,4,5,6])),
    'symbol_prefix': ([4], dots_to_braille([4])),
    'math_prefix': ([5], dots_to_braille([5])),
}

# ============================================================
# KIEM TRA 1: Tim Braille chars bi TRUNG (collision)
# ============================================================
print("=" * 80)
print("KIEM TRA 1: TIM BRALLE CHAR BI TRUNG (COLLISION)")
print("=" * 80)

braille_to_items = {}
for item, (dots, char) in app_mapping.items():
    if char not in braille_to_items:
        braille_to_items[char] = []
    braille_to_items[char].append((item, dots))

collisions = []
for char, items in sorted(braille_to_items.items()):
    if len(items) > 1:
        dots_str = ','.join(str(d) for d in items[0][1])
        print(f"\n  COLLISION: {char} (U+{ord(char):04X}) dots {dots_str}")
        for item, d in items:
            print(f"       - '{item}' -> dots {','.join(str(x) for x in d)}")
        collisions.append((char, items))

print(f"\n  Tong collision: {len(collisions)}")

# ============================================================
# KIEM TRA 2: UEB Standard cho dau cau
# ============================================================
print("\n" + "=" * 80)
print("KIEM TRA 2: SO SANH VOI CHUAN UEB (Unified English Braille)")
print("=" * 80)

# UEB standard punctuation
ueb = {
    'period': ([2,5,6], '⠲'),
    'comma': ([2], '⠂'),
    'question_mark': ([2,3,6], '⠦'),  # UEB dung 2,3,6 KHONG phai 2,6!
    'exclaim': ([2,3,5], '⠖'),
    'colon': ([2,5], '⠒'),
    'semicolon': ([2,3], '⠆'),
    'dash': ([3,6], '⠤'),
    'squote': ([3], '⠄'),
    'dquote_open': ([2,3,6], '⠦'),
    'dquote_close': ([3,5,6], '⠴'),
}

print("\n  Punctuation - App vs UEB:")
print(f"  {'Ten':20s} {'App char':10s} {'App dots':12s} {'UEB char':10s} {'UEB dots':12s} {'Khop?':8s}")
print(f"  {'-'*20} {'-'*10} {'-'*12} {'-'*10} {'-'*12} {'-'*8}")

app_punct = {
    'period': app_mapping['punct_period'],
    'comma': app_mapping['punct_comma'],
    'question_mark': app_mapping['punct_question'],
    'exclaim': app_mapping['punct_exclaim'],
    'colon': app_mapping['punct_colon'],
    'semicolon': app_mapping['punct_semicolon'],
    'dash': app_mapping['punct_dash'],
    'squote': app_mapping['punct_squote'],
    'dquote_open': app_mapping['punct_dquote_open'],
    'dquote_close': app_mapping['punct_dquote_close'],
}

for name in ueb:
    ueb_dots, ueb_char = ueb[name]
    app_dots, app_char = app_punct[name]
    match = "OK" if app_dots == ueb_dots else "KHAC!"
    app_dots_str = ','.join(str(d) for d in app_dots)
    ueb_dots_str = ','.join(str(d) for d in ueb_dots)
    print(f"  {name:20s} {app_char:10s} {app_dots_str:12s} {ueb_char:10s} {ueb_dots_str:12s} {match:8s}")

# ============================================================
# KIEM TRA 3: Collision chi tiet
# ============================================================
print("\n" + "=" * 80)
print("KIEM TRA 3: PHAN TICH CHI TIET TUNG COLLISION")
print("=" * 80)

# Collision 1: ? (question mark) vs tone_hoi
print("\n  --- Collision 1: ⠢ (U+2822) dots 2,6 ---")
print("  Trong app:")
print("    - 'tone_hoi' (dau thanh hoi): _cell(_d2 | _d6) = ⠢")
print("    - 'punct_question' (dau cham hoi ?): _cell(_d2 | _d6) = ⠢")
print()
print("  Trong file quy tac:")
print("    - Muc III: Dau hoi = dots(26) = ⠢ -> Dung chuan")
print("    - Muc VIII: De cap dau hoi cau NHUNG KHONG CHO dots cu the")
print()
print("  Chuan UEB:")
print("    - Question mark = dots 2,3,6 = ⠦ (KHONG phai 2,6!)")
print()
print("  => VAN DE: App dung sai UEB cho dau cham hoi")
print("  => DE XUAT: Sua punct_question thanh _cell(_d2 | _d3 | _d6) = ⠦")

# Collision 2: dash vs tone_nga
print("\n  --- Collision 2: ⠤ (U+2824) dots 3,6 ---")
print("  Trong app:")
print("    - 'tone_nga' (dau thanh nga): _cell(_d3 | _d6) = ⠤")
print("    - 'punct_dash' (dau gach ngang -): _cell(_d3 | _d6) = ⠤")
print()
print("  Trong file quy tac:")
print("    - Muc III: Dau nga = dots(36) = ⠤ -> Dung chuan")
print("    - Muc VIII: Khong co mapping cu the cho dau gach ngang")
print()
print("  Chuan UEB:")
print("    - Dash = dots 3,6 = ⠤ (giong app)")
print()
print("  => VAN DE: Trung ky tu, nhung co the phan biet theo ngu canh")
print("     + Dau thanh nga LUON dung TRUOC nguyen am")
print("     + Dau gach ngang dung GIUA cac tu/so")
print("  => DE XUAT: Co the giu nguyen, hoac dung prefix cho dau cau:")
print("     punct_dash = _symbolPrefix + _cell(_d3 | _d6) = ⠈⠤")

# Collision 3: dquote_open vs question_mark (trong UEB)
print("\n  --- Luan them: ⠦ (U+2826) dots 2,3,6 ---")
print("  Trong app:")
print("    - 'punct_dquote_open': _cell(_d2 | _d3 | _d6) = ⠦")
print()
print("  Chuan UEB:")
print("    - Question mark = dots 2,3,6 = ⠦")
print("    - Opening quote = dots 2,3,6 = ⠦")
print()
print("  => UEB cung trung 2 cai nay! Nen app dung ⠦ cho dquote_open")
print("     la HOP LY theo UEB.")
print("  => Neu sua question_mark thanh ⠦ thi se trung VOI dquote_open!")
print()
print("  GIAI PHAP:")
print("    Option A: Dung ⠦ cho question mark, dung ⠢ cho dquote_open")
print("              -> Vi pham UEB cho quote")
print("    Option B: Dung ⠦ cho dquote_open, dung ⠈⠦ (prefix+2,3,6) cho question mark")
print("              -> An toan nhat, khong trung voi bat ky thu gi")
print("    Option C: Dung ⠦ cho question mark, dung _symbolPrefix+⠦ cho dquote_open")
print("              -> Hop ly vi dau cau pho bien hon")

print("\n" + "=" * 80)
print("TOM TAT VAN DE VA GIAI PHAP")
print("=" * 80)

print("""
VAN DE 1: Dau cham hoi (?) trung voi dau thanh hoi
   - Hien tai: Ca 2 deu dung _cell(_d2 | _d6) = ⠢
   - UEB: Question mark = 2,3,6 = ⠦
   - Giai phap TOT NHAT:
       question_mark = _symbolPrefix + _cell(_d2 | _d3 | _d6)
                     = ⠈ + ⠦ = ⠈⠦
     Ly do:
       + Khong trung voi tone_hoi (⠢)
       + Khong trung voi dquote_open (⠦)
       + Prefix 4 (⠈) bao day la ky tu dac biet/dau cau
       + Phu hop voi cach app da dung _symbolPrefix cho ( ) / _

VAN DE 2: Dau gach ngang (-) trung voi dau thanh nga
   - Hien tai: Ca 2 deu dung _cell(_d3 | _d6) = ⠤
   - UEB: Dash = 3,6 = ⠤ (giong app)
   - Giai phap:
     + Option 1: Giu nguyen (phan biet theo ngu canh)
     + Option 2 (an toan hon):
       punct_dash = _symbolPrefix + _cell(_d3 | _d6) = ⠈⠤

RECOMMENDATION CUOI CUNG:
  1. Sua _question = _symbolPrefix + _cell(_d2 | _d3 | _d6)  # ⠈⠦
  2. Sua _dash = _symbolPrefix + _cell(_d3 | _d6)            # ⠈⠤
  3. Cap nhat reverse mapping trong _reverseMap tuong ung
""")
