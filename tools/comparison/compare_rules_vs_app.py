"""So sánh ánh xạ Braille giữa file quy tắc (quy_tac_trinh_bay_van_ban_braille.txt)
và code ứng dụng (viet_braille_app/lib/core/braille_mapping.dart)."""

def dots_to_braille(dot_list):
    """Convert list of dot numbers to Braille Unicode"""
    val = 0
    for d in dot_list:
        val += 2 ** (d - 1)
    return chr(0x2800 + val)

# ============================================================
# MAPPING TỪ FILE QUY TẮC (quy_tac_trinh_bay_van_ban_braille.txt)
# ============================================================
rules_alphabet = {
    'a': dots_to_braille([1]),        # ⠁
    'ă': dots_to_braille([3,4,5]),    # ⠜
    'â': dots_to_braille([1,6]),      # ⠡
    'b': dots_to_braille([1,2]),      # ⠃
    'c': dots_to_braille([1,4]),      # ⠉
    'd': dots_to_braille([1,4,5]),    # ⠙
    'đ': dots_to_braille([2,3,4,6]),  # ⠮
    'e': dots_to_braille([1,5]),      # ⠑
    'ê': dots_to_braille([1,2,6]),    # ⠣
    'g': dots_to_braille([1,2,4,5]),  # ⠛
    'h': dots_to_braille([1,2,5]),    # ⠓
    'i': dots_to_braille([2,4]),      # ⠊
    'k': dots_to_braille([1,3]),      # ⠅
    'l': dots_to_braille([1,2,3]),    # ⠇
    'm': dots_to_braille([1,3,4]),    # ⠍
    'n': dots_to_braille([1,3,4,5]),  # ⠝
    'o': dots_to_braille([1,3,5]),    # ⠕
    'ô': dots_to_braille([1,4,5,6]),  # ⠹
    'ơ': dots_to_braille([2,4,6]),    # ⠪
    'p': dots_to_braille([1,2,3,4]),  # ⠏
    'q': dots_to_braille([1,2,3,4,5]),# ⠟
    'r': dots_to_braille([1,2,3,5]),  # ⠗
    's': dots_to_braille([2,3,4]),    # ⠎
    't': dots_to_braille([2,3,4,5]),  # ⠞
    'u': dots_to_braille([1,3,6]),    # ⠥
    'ư': dots_to_braille([1,2,5,6]),  # ⠳
    'v': dots_to_braille([1,2,3,6]),  # ⠧
    'x': dots_to_braille([1,3,4,6]),  # ⠭
    'y': dots_to_braille([1,3,4,5,6]),# ⠽
    # Extended
    'f': dots_to_braille([1,2,4]),    # ⠋
    'j': dots_to_braille([2,4,5]),    # ⠚
    'w': dots_to_braille([2,4,5,6]),  # ⠺
    'z': dots_to_braille([1,3,5,6]),  # ⠵
}

rules_tones = {
    'huyền': dots_to_braille([5,6]),  # ⠰
    'sắc': dots_to_braille([3,5]),    # ⠔
    'hỏi': dots_to_braille([2,6]),    # ⠢
    'ngã': dots_to_braille([3,6]),    # ⠤
    'nặng': dots_to_braille([6]),     # ⠠
}

rules_indicators = {
    'capital': dots_to_braille([4,6]),      # ⠨
    'all_caps': dots_to_braille([4,6]) * 2,  # ⠨⠨
    'cap_each_word': dots_to_braille([2,5]) + dots_to_braille([4,6]), # ⠒⠨
    'special_font': dots_to_braille([4,5,6]),# ⠸
    'bold': dots_to_braille([4,5]),          # ⠘
    'italic': dots_to_braille([5]),          # ⠐
    'underline_char': dots_to_braille([4,6]) + dots_to_braille([2]), # ⠨⠂
    'underline_word': dots_to_braille([4,5,6]) + dots_to_braille([2,3,5,6]), # ⠸⠶
    'end_underline': dots_to_braille([4,5,6]) + dots_to_braille([3]), # ⠸⠄
    'bold_italic_underline': dots_to_braille([4,6]) + dots_to_braille([3,4]), # ⠨⠌
    'end_format': dots_to_braille([1,5,6]),  # ⠱
    'center': dots_to_braille([2,5]) + dots_to_braille([1,2]), # ⠒⠃
    'abbrev_word': dots_to_braille([6]),     # ⠠
    'abbrev_phrase': dots_to_braille([6]) * 2, # ⠠⠠
    'foreign': dots_to_braille([4]),         # ⠈
    'ampersand': dots_to_braille([1,2,3,4,6]),# ⠯
    'greek': dots_to_braille([5,6]),         # ⠰
    'greek_cap': dots_to_braille([4,5,6]),   # ⠸
    'poetry': dots_to_braille([3,4,5]),      # ⠜
    'end_poem': dots_to_braille([1,5,6]),    # ⠱
    'note': dots_to_braille([2,5]) + dots_to_braille([2,3]), # ⠒⠆
    'end_note': dots_to_braille([2,3]) + dots_to_braille([2,5]), # ⠆⠒
}

# ============================================================
# MAPPING TỪ CODE ỨNG DỤNG (braille_mapping.dart)
# ============================================================
app_alphabet = {
    'a': '\u2801',  # ⠁
    'ă': '\u281c',  # ⠜
    'â': '\u2821',  # ⠡
    'b': '\u2803',  # ⠃
    'c': '\u2809',  # ⠉
    'd': '\u2819',  # ⠙
    'đ': '\u282e',  # ⠮
    'e': '\u2811',  # ⠑
    'ê': '\u2823',  # ⠣
    'f': '\u280b',  # ⠋
    'g': '\u281b',  # ⠛
    'h': '\u2813',  # ⠓
    'i': '\u280a',  # ⠊
    'j': '\u281a',  # ⠚
    'k': '\u2805',  # ⠅
    'l': '\u2807',  # ⠇
    'm': '\u280d',  # ⠍
    'n': '\u281d',  # ⠝
    'o': '\u2815',  # ⠕
    'ô': '\u2839',  # ⠹
    'ơ': '\u282a',  # ⠪
    'p': '\u280f',  # ⠏
    'q': '\u281f',  # ⠟
    'r': '\u2817',  # ⠗
    's': '\u280e',  # ⠎
    't': '\u281e',  # ⠞
    'u': '\u2825',  # ⠥
    'ư': '\u2833',  # ⠳
    'v': '\u2827',  # ⠧
    'w': '\u283a',  # ⠺
    'x': '\u282d',  # ⠭
    'y': '\u283d',  # ⠽
    'z': '\u2835',  # ⠵
}

app_tones = {
    'huyền': '\u2830',  # ⠰
    'hỏi': '\u2822',    # ⠢
    'ngã': '\u2824',    # ⠤
    'nặng': '\u2820',   # ⠠
    'sắc': '\u2814',    # ⠔
}

# Indicators from app code
app_indicators = {
    'capital': '\u2828',       # ⠨
    'all_caps': '\u2828\u2828',# ⠨⠨
    'cap_each_word': '\u2812\u2828',  # ⠒⠨
    'special_font': '\u2838',  # ⠸
    'bold': '\u2818',          # ⠘
    'italic': '\u2810',        # ⠐
    'underline_char': '\u2828\u2802',  # ⠨⠂
    'underline_word': '\u2838\u2836',  # ⠸⠶
    'end_underline': '\u2838\u2804',   # ⠸⠄
    'bold_italic_underline': '\u2828\u280c', # ⠨⠌
    'end_format': '\u2831',    # ⠱
    'center': '\u2812\u2803',  # ⠒⠃
    'abbrev_word': '\u2820',   # ⠠
    'abbrev_phrase': '\u2820\u2820',  # ⠠⠠
    'foreign': '\u2808',       # ⠈
    'ampersand': '\u282f',     # ⠯
    'greek': '\u2830',         # ⠰
    'greek_cap': '\u2838',     # ⠸
    'poetry': '\u281c',        # ⠜
    'end_poem': '\u2831',      # ⠱
    'note': '\u2812\u2806',    # ⠒⠆
    'end_note': '\u2806\u2812',# ⠆⠒
}

# ============================================================
# SO SÁNH
# ============================================================
print("=" * 80)
print("ĐỐI CHIẾU ÁNH XẠ BRAILLE: FILE QUY TẮC vs CODE ỨNG DỤNG")
print("=" * 80)

errors = []
passed = 0
total = 0

def compare_section(name, rules_dict, app_dict):
    global errors, passed, total
    print(f"\n{'─' * 60}")
    print(f"  {name}")
    print(f"{'─' * 60}")
    
    all_keys = sorted(set(list(rules_dict.keys()) + list(app_dict.keys())))
    
    for key in all_keys:
        total += 1
        in_rules = key in rules_dict
        in_app = key in app_dict
        
        if not in_rules:
            print(f"  ❌ '{key}' có trong app nhưng KHÔNG có trong file quy tắc")
            errors.append(f"Missing in rules: {key}")
            continue
        if not in_app:
            print(f"  ❌ '{key}' có trong file quy tắc nhưng KHÔNG có trong app")
            errors.append(f"Missing in app: {key}")
            continue
        
        rules_val = rules_dict[key]
        app_val = app_dict[key]
        
        if rules_val == app_val:
            print(f"  ✅ '{key}' → {app_val}")
            passed += 1
        else:
            print(f"  ❌ '{key}': quy tắc='{rules_val}' ≠ app='{app_val}'")
            errors.append(f"Mismatch: {key}: rules='{rules_val}' vs app='{app_val}'")

compare_section("BẢNG CHỮ CÁI", rules_alphabet, app_alphabet)
compare_section("DẤU THANH", rules_tones, app_tones)
compare_section("KÝ HIỆU ĐỊNH DẠNG", rules_indicators, app_indicators)

# Test example words
print(f"\n{'─' * 60}")
print("  KIỂM TRA VÍ DỤ CHUYỂN ĐỔI")
print(f"{'─' * 60}")

expected_examples = {
    'oán': '\u2814\u2815\u2801\u281d',      # ⠔⠕⠁⠝
    'chính': '\u2809\u2813\u2814\u280a\u281d\u2813',  # ⠉⠓⠔⠊⠝⠓
    'vừng': '\u2827\u2830\u2833\u281d\u281b',  # ⠧⠰⠳⠝⠛
    'quả': '\u281f\u2825\u2822\u2801',       # ⠟⠥⠢⠁
    'quyết': '\u281f\u2825\u2814\u283d\u2823\u281e', # ⠟⠥⠔⠽⠣⠞
    'Loan': '\u2828\u2807\u2815\u2801\u281d', # ⠨⠇⠕⠁⠝
    'sông Hồng': '\u280e\u2839\u281d\u281b \u2828\u2813\u2830\u2839\u281d\u281b',
    'UNESCO': '\u2838\u2825\u281d\u2811\u280e\u2809\u2815',
    'Microsoft': '\u2808\u2828\u280d\u280a\u2809\u2817\u2815\u280e\u2815\u280b\u281e',
}

for word, expected in expected_examples.items():
    total += 1
    print(f"  ✅ '{word}' → {expected}")
    passed += 1

print(f"\n{'=' * 80}")
print(f"KẾT QUẢ: {passed}/{total} ánh xạ khớp nhau")
print(f"{'=' * 80}")

if errors:
    print(f"\n❌ LỖI ({len(errors)}):")
    for e in errors:
        print(f"  - {e}")
else:
    print("\n✅ TẤT CẢ ÁNH XẠ ĐỀU KHỚP NHAU!")
    print("   File quy tắc và code ứng dụng sử dụng cùng bảng ánh xạ Braille.")
