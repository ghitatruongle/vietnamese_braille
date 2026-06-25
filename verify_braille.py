def dots_to_unicode(dot_numbers):
    """Convert list of dot numbers (1-6) to Braille Unicode"""
    val = 0
    for d in dot_numbers:
        val += 2 ** (d - 1)
    return chr(0x2800 + val), val

def unicode_to_dots(char):
    """Convert Braille Unicode char to list of dot numbers"""
    val = ord(char) - 0x2800
    dots = []
    for i in range(6):
        if val & (1 << i):
            dots.append(i + 1)
    return dots

errors = []
all_checks = 0
passed = 0

def check(name, dots, expected):
    global all_checks, passed, errors
    all_checks += 1
    
    # Wrap flat list of integers to a list of lists
    if dots and isinstance(dots[0], int):
        actual_dots = [dots]
    else:
        actual_dots = dots
        
    chars = []
    for g in actual_dots:
        if g == " ":
            chars.append(" ")
        elif isinstance(g, (list, tuple)):
            char, code = dots_to_unicode(g)
            chars.append(char)
        else:
            char, code = dots_to_unicode([g])
            chars.append(char)
    result = "".join(chars)
    if result == expected:
        passed += 1
        print(f"  {name:<15} -> {result} OK")
    else:
        print(f"  {name:<15} -> got '{result}', expected '{expected}' ERROR")
        errors.append(name)

print("=" * 70)
print("I. BANG CHU CAI TIENG VIET")
print("=" * 70)
alphabet = [
    ("a", [1], "\u2801"),
    (u"\u0103", [3,4,5], "\u281c"),  # ă
    (u"\u00e2", [1,6], "\u2821"),  # â
    ("b", [1,2], "\u2803"),
    ("c", [1,4], "\u2809"),
    ("d", [1,4,5], "\u2819"),
    (u"\u0111", [2,3,4,6], "\u282e"),  # đ
    ("e", [1,5], "\u2811"),
    (u"\u00ea", [1,2,6], "\u2823"),  # ê
    ("g", [1,2,4,5], "\u281b"),
    ("h", [1,2,5], "\u2813"),
    ("i", [2,4], "\u280a"),
    ("k", [1,3], "\u2805"),
    ("l", [1,2,3], "\u2807"),
    ("m", [1,3,4], "\u280d"),
    ("n", [1,3,4,5], "\u281d"),
    ("o", [1,3,5], "\u2815"),
    (u"\u00f4", [1,4,5,6], "\u2839"),  # ô
    (u"\u01a1", [2,4,6], "\u282a"),  # ơ
    ("p", [1,2,3,4], "\u280f"),
    ("q", [1,2,3,4,5], "\u281f"),
    ("r", [1,2,3,5], "\u2817"),
    ("s", [2,3,4], "\u280e"),
    ("t", [2,3,4,5], "\u281e"),
    ("u", [1,3,6], "\u2825"),
    (u"\u01b0", [1,2,5,6], "\u2833"),  # ư
    ("v", [1,2,3,6], "\u2827"),
    ("x", [1,3,4,6], "\u282d"),
    ("y", [1,3,4,5,6], "\u283d")
]
for name, dots, expected in alphabet:
    check(name, dots, expected)

print("\n" + "=" * 70)
print("II. BANG CHU CAI MO RONG (f, j, w, z)")
print("=" * 70)
extended = [
    ("f", [1,2,4], "\u280b"),
    ("j", [2,4,5], "\u281a"),
    ("w", [2,4,5,6], "\u283a"),
    ("z", [1,3,5,6], "\u2835")
]
for name, dots, expected in extended:
    check(name, dots, expected)

print("\n" + "=" * 70)
print("III. DAU THANH")
print("=" * 70)
tones = [
    ("huyen", [5,6], "\u2830"),
    ("sac", [3,5], "\u2814"),
    ("hoi", [2,6], "\u2822"),
    ("nga", [3,6], "\u2824"),
    ("nang", [6], "\u2820")
]
for name, dots, expected in tones:
    check(name, dots, expected)

print("\n" + "=" * 70)
print("IV. KY HIEU TRINH BAY")
print("=" * 70)
symbols = [
    ("26.hoa tat ca", [[4,6],[4,6]], "\u2828\u2828"),
    ("27.hoa chu cai dau", [[2,5],[4,6]], "\u2812\u2828"),
    ("28.phong dac biet", [4,5,6], "\u2838"),
    ("29.in dam", [4,5], "\u2818"),
    ("30.ket thuc in dam", [4,5], "\u2818"),
    ("31.in nghieng", [5], "\u2810"),
    ("32.ket thuc in nghieng", [5], "\u2810"),
    ("33.gach chan 1 chu", [[4,6],[2]], "\u2828\u2802"),
    ("34.gach chan ca chu", [[4,5,6],[2,3,5,6]], "\u2838\u2836"),
    ("35.ket thuc gach chan", [[4,5,6],[3]], "\u2838\u2804"),
    ("36.dam+nghieng+gach", [[4,6],[3,4]], "\u2828\u280c"),
    ("37.ket thuc phong", [1,5,6], "\u2831"),
    ("38.canh giua", [[2,5],[1,2]], "\u2812\u2803"),
    ("39.viet tat 1 tu", [6], "\u2820"),
    ("40.viet tat cum tu", [[6],[6]], "\u2820\u2820"),
    ("41.tieng nuoc ngoai", [4], "\u2808"),
    ("42.email / @", [4], "\u2808"),
    ("43.va / &", [1,2,3,4,6], "\u282f"),
    ("44.chu Hy Lap", [5,6], "\u2830"),
    ("45.hoa Hy Lap", [4,5,6], "\u2838"),
    ("46.a...z", [[1],[3],[3],[3],[1,3,5,6]], "\u2801\u2804\u2804\u2804\u2835"),
    ("47.A...Z", [[4,6],[1],[3],[3],[3],[4,6],[1,3,5,6]], "\u2828\u2801\u2804\u2804\u2804\u2828\u2835"),
    ("48.mac dinh", [[2,3,5,6],[3],[3],[3],[2,3,5,6]], "\u2836\u2804\u2804\u2804\u2836"),
    ("49.bao tho", [3,4,5], "\u281c"),
    ("50.het cau tho", [3,4,5], "\u281c"),
    ("51.het doan tho", [[3,4,5],[3,4,5]], "\u281c\u281c"),
    ("52.het bai tho", [1,5,6], "\u2831")
]
for name, dots, expected in symbols:
    check(name, dots, expected)

print("\n" + "=" * 70)
print("VI. VI DU DAT DAU THANH")
print("=" * 70)
tone_examples = [
    ("oan", [[3,5],[1,3,5],[1],[1,3,4,5]], "\u2814\u2815\u2801\u281d"),
    ("chinh", [[1,4],[1,2,5],[3,5],[2,4],[1,3,4,5],[1,2,5]], "\u2809\u2813\u2814\u280a\u281d\u2813"),
    ("vung", [[1,2,3,6],[5,6],[1,2,5,6],[1,3,4,5],[1,2,4,5]], "\u2827\u2830\u2833\u281d\u281b"),
    ("qua", [[1,2,3,4,5],[1,3,6],[2,6],[1]], "\u281f\u2825\u2822\u2801"),
    ("quyet", [[1,2,3,4,5],[1,3,6],[3,5],[1,3,4,5,6],[1,2,6],[2,3,4,5]], "\u281f\u2825\u2814\u283d\u2823\u281e"),
    ("gioi", [[1,2,4,5],[2,4],[2,6],[1,3,5],[2,4]], "\u281b\u280a\u2822\u2815\u280a"),
    ("giang giai", [[1,2,4,5],[2,4],[2,6],[1],[1,3,4,5],[1,2,4,5]," ",[1,2,4,5],[2,4],[2,6],[1],[2,4]], "\u281b\u280a\u2822\u2801\u281d\u281b \u281b\u280a\u2822\u2801\u280a"),
    ("gin", [[1,2,4,5],[5,6],[2,4],[1,3,4,5]], "\u281b\u2830\u280a\u281d"),
    ("gi", [[1,2,4,5],[5,6],[2,4]], "\u281b\u2830\u280a")
]
for name, dots, expected in tone_examples:
    check(name, dots, expected)

print("\n" + "=" * 70)
print("VII. VI DU VIET HOA")
print("=" * 70)
capital_examples = [
    ("Loan", [[4,6],[1,2,3],[1,3,5],[1],[1,3,4,5]], "\u2828\u2807\u2815\u2801\u281d"),
    ("song Hong", [[2,3,4],[1,4,5,6],[1,3,4,5],[1,2,4,5]," ",[4,6],[1,2,5],[5,6],[1,4,5,6],[1,3,4,5],[1,2,4,5]], "\u280e\u2839\u281d\u281b \u2828\u2813\u2830\u2839\u281d\u281b"),
    ("bac An", [[1,2],[3,5],[1],[1,4]," ",[2,6],[4,6],[1,6],[1,3,4,5]], "\u2803\u2814\u2801\u2809 \u2822\u2828\u2821\u281d"),
    ("UNESCO", [[4,5,6],[1,3,6],[1,3,4,5],[1,5],[2,3,4],[1,4],[1,3,5]], "\u2838\u2825\u281d\u2811\u280e\u2809\u2815"),
    ("Viet Nam", [[2,5],[4,6],[1,2,3,6],[6],[2,4],[1,2,6],[2,3,4,5]," ",[1,3,4,5],[1],[1,3,4],[1,5,6]], "\u2812\u2828\u2827\u2820\u280a\u2823\u281e \u281d\u2801\u280d\u2831"),
    ("VIET NAM", [[4,6],[4,6],[1,2,3,6],[6],[2,4],[1,2,6],[2,3,4,5]," ",[1,3,4,5],[1],[1,3,4],[1,5,6]], "\u2828\u2828\u2827\u2820\u280a\u2823\u281e \u281d\u2801\u280d\u2831")
]
for name, dots, expected in capital_examples:
    check(name, dots, expected)

print("\n" + "=" * 70)
print("X. VI DU VIET TAT")
print("=" * 70)
abbrev_examples = [
    ("GDHN", [[6],[4,5,6],[1,2,4,5],[1,4,5],[1,2,5],[1,3,4,5]], "\u2820\u2838\u281b\u2819\u2813\u281d"),
    ("HSPT", [[6],[6],[4,5,6],[1,2,5],[2,3,4],[1,2,3,4],[2,3,4,5]], "\u2820\u2820\u2838\u2813\u280e\u280f\u281e")
]
for name, dots, expected in abbrev_examples:
    check(name, dots, expected)

print("\n" + "=" * 70)
print("XI. TIENG NUOC NGOAI")
print("=" * 70)
foreign = [
    ("Microsoft", [[4],[4,6],[1,3,4],[2,4],[1,4],[1,2,3,5],[1,3,5],[2,3,4],[1,3,5],[1,2,4],[2,3,4,5]], "\u2808\u2828\u280d\u280a\u2809\u2817\u2815\u280e\u2815\u280b\u281e")
]
for name, dots, expected in foreign:
    check(name, dots, expected)

print("\n" + "=" * 70)
print("XII. KY HIEU GHI CHU")
print("=" * 70)
note_symbols = [
    ("bao ghi chu", [[2,5],[2,3]], "\u2812\u2806"),
    ("ket thuc ghi chu", [[2,3],[2,5]], "\u2806\u2812")
]
for name, dots, expected in note_symbols:
    check(name, dots, expected)

print("\n" + "=" * 70)
print(f"TONG KET: {passed}/{all_checks} kiem tra dung")
print("=" * 70)
if errors:
    print(f"\nLOI ({len(errors)}):")
    for e in errors:
        print(f"  - {e}")
else:
    print("\nTAT CA ANH XA DEU DUNG!")
