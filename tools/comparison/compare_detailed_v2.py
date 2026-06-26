"""
So sánh CHI TIẾT TỪNG DÒNG giữa:
  - File quy tắc: quy_tac_trinh_bay_van_ban_braille.txt  
  - Code app: viet_braille_app/lib/core/braille_mapping.dart

Cách hoạt động:
1. Parse Dart code để lấy tất cả _cell() calls và tính dot pattern → Unicode
2. Parse file quy tắc để lấy dot notation → Unicode
3. So sánh từng ký tự một
"""
import re

# ============================================================
# BƯỚC 1: Parse Dart code để trích mapping
# ============================================================
dart_file = r'E:\vietnamese_braille\viet_braille_app\lib\core\braille_mapping.dart'
with open(dart_file, 'r', encoding='utf-8') as f:
    dart_code = f.read()

def dots_to_braille_char(dots):
    """Convert list of dot numbers (1-6) to Braille Unicode character"""
    val = 0
    for d in dots:
        val |= (1 << (d - 1))
    return chr(0x2800 + val)

def parse_dart_cell_call(call_str):
    """Parse '_cell(_d1 | _d3 | _d5)' style calls into list of dot numbers"""
    # Extract the dots: _d1 | _d3 | _d5  =>  [1, 3, 5]
    dots = []
    for m in re.finditer(r'_d(\d)', call_str):
        dots.append(int(m.group(1)))
    return dots

def parse_dart_var_defs(dart_code):
    """Extract all static final String _xxx = _cell(...) definitions"""
    var_defs = {}
    # Pattern: static final String _name = _cell(_d1 | _d3);
    pattern = r'static\s+final\s+String\s+(_\w+)\s*=\s*_cell\(([^)]+)\);'
    for m in re.finditer(pattern, dart_code):
        var_name = m.group(1)
        cell_content = m.group(2)
        dots = parse_dart_cell_call(f'_cell({cell_content})')
        char = dots_to_braille_char(dots)
        var_defs[var_name] = {'dots': dots, 'char': char}
    return var_defs

var_defs = parse_dart_var_defs(dart_code)

# Print all extracted variable definitions
print("=" * 80)
print("BANG 1: TAT CA BIEN DOT PATTERN TRONG CODE APP")
print("=" * 80)
for name, info in sorted(var_defs.items()):
    dots_str = ','.join(str(d) for d in info['dots'])
    char = info['char']
    ucode = f"U+{ord(char):04X}"
    print(f"  {name:20s} dots={dots_str:12s} → {char}  ({ucode})")

# ============================================================
# BƯỚC 2: Xây dựng bảng mapping từ app code
# ============================================================

# Alphabet mapping: ký tự → _var_name
alphabet_vars = {
    'a': '_a', 'b': '_b', 'c': '_c', 'd': '_d', 'e': '_e',
    'f': '_f', 'g': '_g', 'h': '_h', 'i': '_i', 'j': '_j',
    'k': '_k', 'l': '_l', 'm': '_m', 'n': '_n', 'o': '_o',
    'p': '_p', 'q': '_q', 'r': '_r', 's': '_s', 't': '_t',
    'u': '_u', 'v': '_v', 'w': '_w', 'x': '_x', 'y': '_y', 'z': '_z',
    # Vietnamese special chars
    'ă': '_aw', 'â': '_aa', 'ê': '_ee', 'ô': '_oo',
    'ơ': '_ow', 'ư': '_uw', 'đ': '_dj',
}

tone_vars = {
    'sắc': '_toneSac',
    'huyền': '_toneHuyen',
    'hỏi': '_toneHoi',
    'ngã': '_toneNga',
    'nặng': '_toneNang',
}

# Indicators
indicator_vars = {
    'number_indicator': '_num',
    'capital_indicator': '_capital',
    'symbol_prefix': '_symbolPrefix',
    'math_prefix': '_mathPrefix',
    'special_prefix': '_cell(_d4 | _d5 | _d6)',
    'bracket_prefix': '_cell(_d4 | _d6)',
    'dquote_close': '_dquoteClose',
}

# Punctuation
punct_vars = {
    'dấu phẩy': '_comma',
    'dấu chấm': '_period',
    'dấu hỏi': '_question',
    'dấu chấm than': '_exclaim',
    'dấu hai chấm': '_colon',
    'dấu chấm phẩy': '_semicolon',
    'nháy đơn': '_squote',
    'nháy kép mở': '_dquoteOpen',
    'nháy kép đóng': '_dquoteClose',
    'dấu gạch ngang': '_dash',
}

# Build app alphabet table
app_alphabet = {}
for char, var_name in alphabet_vars.items():
    if var_name in var_defs:
        app_alphabet[char] = var_defs[var_name]
    else:
        app_alphabet[char] = {'error': f'var {var_name} not found'}

app_tones = {}
for name, var_name in tone_vars.items():
    if var_name in var_defs:
        app_tones[name] = var_defs[var_name]
    else:
        app_tones[name] = {'error': f'var {var_name} not found'}

# ============================================================
# BƯỚC 3: Parse file quy tắc
# ============================================================
rules_file = r'E:\vietnamese_braille\quytac\trinh_bay_vb\quy_tac_trinh_bay_van_ban_braille.txt'
with open(rules_file, 'r', encoding='utf-8') as f:
    rules_text = f.read()

def parse_rules_section(rules_text, start_marker, end_marker):
    """Parse a rules section and return dict of {name: {'dots': str, 'braille': str}}"""
    start = rules_text.find(start_marker)
    end = rules_text.find(end_marker) if end_marker else len(rules_text)
    section = rules_text[start:end]
    
    results = {}
    for line in section.splitlines():
        # Pattern for single char: | a (1) | ⠁ |
        m = re.match(r'\|\s*([^\|]+?)\s*\(([\d,\s]+)\)\s*\|\s*(\S+)\s*\|', line)
        if m:
            name = m.group(1).strip()
            dots = m.group(2).strip()
            braille = m.group(3).strip()
            results[name] = {'dots': dots, 'braille': braille}
    return results

rules_alphabet = parse_rules_section(rules_text, 'I. BANG CHU CAI TIENG VIET\n', 'II. BANG CHU CAI')
rules_extended = parse_rules_section(rules_text, 'II. BANG CHU CAI TIENG VIET MO RONG', 'III. DAU THANH')
rules_tones = parse_rules_section(rules_text, 'III. DAU THANH', 'IV. CAC KY HIEU')
rules_symbols = parse_rules_section(rules_text, 'IV. CAC KY HIEU TRINH BAY VAN BAN', 'V. QUY TAC VIET CHU')

# ============================================================
# BƯỚC 4: SO SÁNH TỪNG KÝ TỰ
# ============================================================
errors = []
passed = 0
total = 0

def normalize_dots(dots_str):
    """Normalize dots string for comparison: '1, 3, 5' → '135'"""
    return dots_str.replace(',', '').replace(' ', '')

def compare(name, rules_data, app_data):
    global errors, passed, total
    total += 1
    
    if 'error' in app_data:
        errors.append(f"APP ERROR: '{name}' - {app_data['error']}")
        print(f"  ❌ '{name}': APP ERROR - {app_data['error']}")
        return False
    
    r_dots = normalize_dots(rules_data['dots'])
    r_braille = rules_data['braille']
    a_dots = ''.join(str(d) for d in app_data['dots'])
    a_char = app_data['char']
    
    # Check 1: Braille chars match
    if r_braille != a_char:
        errors.append(f"'{name}': rules='{r_braille}' (U+{ord(r_braille):04X}) ≠ app='{a_char}' (U+{ord(a_char):04X})")
        print(f"  ❌ '{name}': rules='{r_braille}' (U+{ord(r_braille):04X}) ≠ app='{a_char}' (U+{ord(a_char):04X})")
        return False
    
    # Check 2: Dots match
    if r_dots != a_dots:
        # Check if they represent the same set of dots
        if set(r_dots) == set(a_dots):
            # Same dots, different order
            passed += 1
            print(f"  ⚠️  '{name}': rules dots={rules_data['dots']} ≠ app dots={a_dots} (same set, diff order)")
            return True
        else:
            errors.append(f"'{name}': rules dots={rules_data['dots']} ≠ app dots={a_dots}")
            print(f"  ❌ '{name}': rules dots={rules_data['dots']} ≠ app dots={a_dots}")
            return False
    
    passed += 1
    print(f"  ✅ '{name}': dots={rules_data['dots']} → {r_braille} (U+{ord(r_braille):04X})")
    return True

print("\n" + "=" * 80)
print("BANG 2: SO SANH BANG CHU CAI (Section I)")
print("=" * 80)
for char in sorted(rules_alphabet.keys()):
    if char in app_alphabet:
        compare(char, rules_alphabet[char], app_alphabet[char])
    else:
        total += 1
        errors.append(f"Missing in app: '{char}'")
        print(f"  ❌ '{char}': CÓ trong quy tắc nhưng KHÔNG CÓ trong app")

print("\n" + "=" * 80)
print("BANG 3: SO SANH CHU MO RONG (Section II - f, j, w, z)")
print("=" * 80)
extended_only = set(rules_extended.keys()) - set(rules_alphabet.keys())
for char in sorted(extended_only):
    if char in app_alphabet:
        compare(char, rules_extended[char], app_alphabet[char])
    else:
        total += 1
        errors.append(f"Missing in app: '{char}'")
        print(f"  ❌ '{char}': CÓ trong quy tắc nhưng KHÔNG CÓ trong app")

# Check app has no extra chars
app_extra = set(app_alphabet.keys()) - set(rules_alphabet.keys()) - set(rules_extended.keys())
if app_extra:
    print(f"\n  ⚠️  App có thêm ký tự không có trong quy tắc: {sorted(app_extra)}")

print("\n" + "=" * 80)
print("BANG 4: SO SANH DAU THANH (Section III)")
print("=" * 80)
for name in sorted(rules_tones.keys()):
    if name in app_tones:
        compare(name, rules_tones[name], app_tones[name])
    else:
        total += 1
        errors.append(f"Missing in app tone: '{name}'")
        print(f"  ❌ '{name}': CÓ trong quy tắc nhưng KHÔNG CÓ trong app")

# ============================================================
# BƯỚC 5: So sánh các ký hiệu từ file quy tắc với code app
# ============================================================
print("\n" + "=" * 80)
print("BANG 5: SO SANH KY HIEU TU FILE QUY TAC VOI CODE APP")
print("=" * 80)

# Map rules symbol numbers to app variables
symbol_mapping = {
    '26': None,  # hoa tất cả = _capital + _capital
    '27': None,  # hoa chữ cái đầu = ⠒⠨
    '28': '_cell(_d4 | _d5 | _d6)',  # phông đặc biệt
    '29': '_cell(_d4 | _d5)',        # in đậm (không có biến trực tiếp)
    '30': '_cell(_d4 | _d5)',        # kết thúc in đậm
    '31': '_mathPrefix',             # in nghiêng = _mathPrefix = _cell(_d5)
    '32': '_mathPrefix',             # kết thúc in nghiêng
    '33': None,  # gạch chân 1 chữ = ⠨⠂
    '34': None,  # gạch chân cả chữ
    '35': None,  # kết thúc gạch chân
    '36': None,  # đậm+nghiêng+gạch
    '37': '_cell(_d1 | _d5 | _d6)',  # kết thúc phông
    '38': None,  # canh giữa
    '39': '_cell(_d6)',              # viết tắt 1 từ = dot 6 (dùng _toneNang)
    '40': None,  # viết tắt cụm từ
    '41': '_symbolPrefix',           # tiếng nước ngoài = _symbolPrefix = _cell(_d4)
    '42': '_symbolPrefix',           # email/@
    '43': None,  # dấu và / & = ⠯ (app dùng _symbolPrefix + _cell(...))
    '44': '_toneHuyen',              # chữ Hy Lạp = _toneHuyen = _cell(_d5 | _d6)
    '45': '_cell(_d4 | _d5 | _d6)',  # hoa Hy Lạp
    '46': None,  # a...z
    '47': None,  # A...Z
    '48': None,  # mặc định
    '49': '_aw',                     # báo thơ = _aw = _cell(_d3 | _d4 | _d5)
    '50': '_aw',                     # hết câu thơ
    '51': None,  # hết đoạn thơ
    '52': '_cell(_d1 | _d5 | _d6)',  # hết bài thơ
}

# Compute dots for inline _cell calls
def compute_inline_cell(expr):
    """Compute dots from inline _cell(_dX | _dY) expression"""
    m = re.match(r'_cell\((.+)\)', expr)
    if m:
        dots = parse_dart_cell_call(f'_cell({m.group(1)})')
        return {'dots': dots, 'char': dots_to_braille_char(dots)}
    return None

for num in sorted(rules_symbols.keys()):
    # Extract the number from key like "26.dấu báo..."
    num_match = re.match(r'(\d+)', num)
    if not num_match:
        continue
    num_val = num_match.group(1)
    
    sym_name = num.split('.', 1)[1] if '.' in num else num
    
    if num_val in symbol_mapping:
        var_expr = symbol_mapping[num_val]
        if var_expr:
            if var_expr.startswith('_cell('):
                app_data = compute_inline_cell(var_expr)
            elif var_expr in var_defs:
                app_data = var_defs[var_expr]
            elif var_expr.startswith('_cell(_d'):
                app_data = compute_inline_cell(var_expr)
            else:
                app_data = {'error': f'unknown var: {var_expr}'}
            
            if app_data and 'error' not in app_data:
                r_braille = rules_symbols[num]['braille']
                a_char = app_data['char']
                a_dots = app_data['dots']
                
                total += 1
                if r_braille == a_char:
                    passed += 1
                    r_dots = normalize_dots(rules_symbols[num]['dots'])
                    a_dots_str = ''.join(str(d) for d in a_dots)
                    if r_dots == a_dots_str:
                        print(f"  ✅ {num_val}.{sym_name[:30]:30s} dots={rules_symbols[num]['dots']:15s} → {r_braille}")
                    else:
                        print(f"  ⚠️  {num_val}.{sym_name[:30]:30s} rules dots={rules_symbols[num]['dots']:12s} app dots={a_dots_str}")
                        errors.append(f"{num}.{sym_name}: dots mismatch rules={rules_symbols[num]['dots']} app={a_dots_str}")
                else:
                    print(f"  ❌ {num_val}.{sym_name[:30]:30s} rules='{r_braille}' ≠ app='{a_char}'")
                    errors.append(f"{num}.{sym_name}: {r_braille} ≠ {a_char}")

# ============================================================
# BƯỚC 6: So sánh dấu câu (có trong app nhưng không có trong quy tắc)
# ============================================================
print("\n" + "=" * 80)
print("BANG 6: KY HIEU CO TRONG APP NHUNG KHONG CO TRONG QUY TAC")
print("=" * 80)

punct_vars_in_dart = {
    'comma': '_comma',
    'period': '_period',
    'question': '_question',
    'exclaim': '_exclaim',
    'colon': '_colon',
    'semicolon': '_semicolon',
    'squote': '_squote',
    'dquote_open': '_dquoteOpen',
    'dquote_close': '_dquoteClose',
    'dash': '_dash',
    'backslash': '_backslash',
}

# Check which punctuation vars are defined
for name, var_name in sorted(punct_vars_in_dart.items()):
    if var_name in var_defs:
        info = var_defs[var_name]
        dots_str = ','.join(str(d) for d in info['dots'])
        char = info['char']
        ucode = f"U+{ord(char):04X}"
        print(f"  📌 {name:15s} dots={dots_str:12s} → {char} ({ucode})")

# ============================================================
# TỔNG KẾT
# ============================================================
print("\n" + "=" * 80)
print(f"TONG KET: {passed}/{total} ánh xạ so sánh được và khớp nhau")
print("=" * 80)

if errors:
    print(f"\n❌ VAN DE ({len(errors)}):")
    for e in errors:
        print(f"  - {e}")
else:
    print("\n✅ TAT CA ANH XA DU KHIEM TRA DEU KHOP NHAU!")

print(f"\n⚠️  Lưu ý: File quy tắc KHÔNG có mapping cho các dấu câu (phẩy, chấm, hỏi...)")
print("   nhưng app CÓ implement. Đây có thể là mở rộng hợp lý.")
