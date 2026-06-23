"""
Comprehensive verification of Vietnamese Braille rules file against reference images.
Compares dot-to-Unicode mappings and extracts Braille from PNG images for cross-reference.
"""
from PIL import Image
import numpy as np
from scipy import ndimage

def dots_to_braille(dot_numbers):
    """Convert list of dot numbers (1-6) to Braille Unicode character."""
    val = 0
    for d in dot_numbers:
        val += 2 ** (d - 1)
    return chr(0x2800 + val), val

def dots_to_braille_str(dot_groups):
    """Convert dot-groups to Braille string.
    If first element is int -> single character
    If first element is list -> multiple characters
    " " -> space
    """
    if not dot_groups:
        return ""
    if isinstance(dot_groups[0], int):
        char, _ = dots_to_braille(dot_groups)
        return char
    chars = []
    for g in dot_groups:
        if g == " ":
            chars.append(" ")
        elif isinstance(g, (list, tuple)):
            char, _ = dots_to_braille(g)
            chars.append(char)
    return "".join(chars)

def extract_braille_from_image(img_path, right_ratio=0.50):
    """Extract Braille cells by removing table borders first."""
    img = Image.open(img_path).convert('L')
    arr = np.array(img)
    h, w = arr.shape
    dark = arr < 128
    
    # Remove horizontal lines
    row_sums = np.sum(dark, axis=1)
    h_line_mask = row_sums > (w * 0.25)
    h_line_dilated = ndimage.binary_dilation(h_line_mask, structure=np.ones((6,)))
    
    # Remove vertical lines
    col_sums = np.sum(dark, axis=0)
    v_line_mask = col_sums > (h * 0.2)
    v_line_dilated = ndimage.binary_dilation(v_line_mask, structure=np.ones((6,)))
    
    cleaned = dark.copy()
    cleaned[h_line_dilated, :] = False
    cleaned[:, v_line_dilated] = False
    
    right_start = int(w * right_ratio)
    region = cleaned[:, right_start:]
    
    labeled, num = ndimage.label(region, structure=np.ones((3,3)))
    
    cells = []
    for i in range(1, num+1):
        mask = labeled == i
        area = np.sum(mask)
        rows = np.where(np.any(mask, axis=1))[0]
        cols = np.where(np.any(mask, axis=0))[0]
        if len(rows) == 0 or len(cols) == 0:
            continue
        ch = rows[-1] - rows[0] + 1
        cw = cols[-1] - cols[0] + 1
        
        if ch < 8 or ch > 25 or cw < 5 or cw > 20:
            continue
        if cw > ch * 1.2:
            continue
        
        cell = dark[rows[0]:rows[-1]+1, cols[0]+right_start:cols[-1]+1+right_start]
        dot_h = ch / 3.0
        dot_w = cw / 2.0
        
        dots = []
        for dr in range(3):
            for dc in range(2):
                dr1 = int(dr * dot_h)
                dr2 = int((dr+1) * dot_h) if dr < 2 else ch
                dc1 = int(dc * dot_w)
                dc2 = int((dc+1) * dot_w) if dc < 1 else cw
                sub = cell[dr1:dr2, dc1:dc2]
                ratio = np.sum(sub) / sub.size if sub.size > 0 else 0
                dots.append(1 if ratio > 0.15 else 0)
        
        if sum(dots) == 0:
            continue
        
        val = 0
        if dots[0]: val |= 1
        if dots[1]: val |= 2
        if dots[2]: val |= 4
        if dots[3]: val |= 8
        if dots[4]: val |= 16
        if dots[5]: val |= 32
        
        cells.append({
            'x': cols[0] + right_start + cw // 2,
            'y': rows[0] + ch // 2,
            'dots': dots,
            'char': chr(0x2800 + val),
            'code': val
        })
    
    return sorted(cells, key=lambda x: (x['y'], x['x']))

def verify_internal_consistency():
    """Verify that all dot numbers in the rules file correctly map to their Unicode characters."""
    all_checks = 0
    passed = 0
    errors = []
    
    tests = {
        "I. Alphabet": [
            ("a", [1], "\u2801"), ("\u0103", [3,4,5], "\u281c"), ("\u00e2", [1,6], "\u2821"),
            ("b", [1,2], "\u2803"), ("c", [1,4], "\u2809"), ("d", [1,4,5], "\u2819"),
            ("\u0111", [2,3,4,6], "\u282e"), ("e", [1,5], "\u2811"), ("\u00ea", [1,2,6], "\u2823"),
            ("g", [1,2,4,5], "\u281b"), ("h", [1,2,5], "\u2813"), ("i", [2,4], "\u280a"),
            ("k", [1,3], "\u2805"), ("l", [1,2,3], "\u2807"), ("m", [1,3,4], "\u280d"),
            ("n", [1,3,4,5], "\u281d"), ("o", [1,3,5], "\u2815"), ("\u00f4", [1,4,5,6], "\u2839"),
            ("\u01a1", [2,4,6], "\u282a"), ("p", [1,2,3,4], "\u280f"), ("q", [1,2,3,4,5], "\u281f"),
            ("r", [1,2,3,5], "\u2817"), ("s", [2,3,4], "\u280e"), ("t", [2,3,4,5], "\u281e"),
            ("u", [1,3,6], "\u2825"), ("\u01b0", [1,2,5,6], "\u2833"), ("v", [1,2,3,6], "\u2827"),
            ("x", [1,3,4,6], "\u282d"), ("y", [1,3,4,5,6], "\u283d"),
        ],
        "II. Extended": [
            ("f", [1,2,4], "\u280b"), ("j", [2,4,5], "\u281a"),
            ("w", [2,4,5,6], "\u283a"), ("z", [1,3,5,6], "\u2835"),
        ],
        "III. Tone marks": [
            ("huyen", [5,6], "\u2830"), ("sac", [3,5], "\u2814"),
            ("hoi", [2,6], "\u2822"), ("nga", [3,6], "\u2824"), ("nang", [6], "\u2820"),
        ],
        "IV. Symbols": [
            ("hoa tat ca", [[4,6],[4,6]], "\u2828\u2828"),
            ("hoa chu cai dau", [[2,5],[4,6]], "\u2812\u2828"),
            ("phong dac biet", [4,5,6], "\u2838"),
            ("in dam", [4,5], "\u2818"),
            ("in nghieng", [5], "\u2810"),
            ("gach chan 1 chu", [[4,6],[2]], "\u2828\u2802"),
            ("gach chan ca chu", [[4,5,6],[2,3,5,6]], "\u2838\u2836"),
            ("ket thuc gach chan", [[4,5,6],[3]], "\u2838\u2804"),
            ("dam+nghieng+gach", [[4,6],[3,4]], "\u2828\u280c"),
            ("ket thuc phong", [1,5,6], "\u2831"),
            ("canh giua", [[2,5],[1,2]], "\u2812\u2803"),
            ("viet tat 1 tu", [6], "\u2820"),
            ("viet tat cum tu", [[6],[6]], "\u2820\u2820"),
            ("tieng nuoc ngoai", [4], "\u2808"),
            ("va / &", [1,2,3,4,6], "\u282f"),
            ("chu Hy Lap", [5,6], "\u2830"),
            ("hoa Hy Lap", [4,5,6], "\u2838"),
            ("a...z", [[1],[3],[3],[3],[1,3,5,6]], "\u2801\u2804\u2804\u2804\u2835"),
            ("A...Z", [[4,6],[1],[3],[3],[3],[4,6],[1,3,5,6]], "\u2828\u2801\u2804\u2804\u2804\u2828\u2835"),
            ("mac dinh", [[2,3,5,6],[3],[3],[3],[2,3,5,6]], "\u2836\u2804\u2804\u2804\u2836"),
            ("bao tho", [3,4,5], "\u281c"),
            ("het doan tho", [[3,4,5],[3,4,5]], "\u281c\u281c"),
            ("het bai tho", [1,5,6], "\u2831"),
        ],
        "VI. Tone examples": [
            ("oan", [[3,5],[1,3,5],[1],[1,3,4,5]], "\u2814\u2815\u2801\u281d"),
            ("chinh", [[1,4],[1,2,5],[3,5],[2,4],[1,3,4,5],[1,2,5]], "\u2809\u2813\u2814\u280a\u281d\u2813"),
            ("vung", [[1,2,3,6],[5,6],[1,2,5,6],[1,3,4,5],[1,2,4,5]], "\u2827\u2830\u2833\u281d\u281b"),
            ("qua", [[1,2,3,4,5],[1,3,6],[2,6],[1]], "\u281f\u2825\u2822\u2801"),
            ("quyet", [[1,2,3,4,5],[1,3,6],[3,5],[1,3,4,5,6],[1,2,6],[2,3,4,5]], "\u281f\u2825\u2814\u283d\u2823\u281e"),
            ("gioi", [[1,2,4,5],[2,4],[2,6],[1,3,5],[2,4]], "\u281b\u280a\u2822\u2815\u280a"),
            ("giang giai", [[1,2,4,5],[2,4],[2,6],[1],[1,3,4,5],[1,2,4,5]," ",[1,2,4,5],[2,4],[2,6],[1],[2,4]], "\u281b\u280a\u2822\u2801\u281d\u281b \u281b\u280a\u2822\u2801\u280a"),
            ("gin", [[1,2,4,5],[5,6],[2,4],[1,3,4,5]], "\u281b\u2830\u280a\u281d"),
            ("gi", [[1,2,4,5],[5,6],[2,4]], "\u281b\u2830\u280a"),
        ],
        "VII. Capital examples": [
            ("Loan", [[4,6],[1,2,3],[1,3,5],[1],[1,3,4,5]], "\u2828\u2807\u2815\u2801\u281d"),
            ("song Hong", [[2,3,4],[1,4,5,6],[1,3,4,5],[1,2,4,5]," ",[4,6],[1,2,5],[5,6],[1,4,5,6],[1,3,4,5],[1,2,4,5]], "\u280e\u2839\u281d\u281b \u2828\u2813\u2830\u2839\u281d\u281b"),
            ("bac An", [[1,2],[3,5],[1],[1,4]," ",[2,6],[4,6],[1,6],[1,3,4,5]], "\u2803\u2814\u2801\u2809 \u2822\u2828\u2821\u281d"),
            ("UNESCO", [[4,5,6],[1,3,6],[1,3,4,5],[1,5],[2,3,4],[1,4],[1,3,5]], "\u2838\u2825\u281d\u2811\u280e\u2809\u2815"),
            ("Viet Nam", [[2,5],[4,6],[1,2,3,6],[6],[2,4],[1,2,6],[2,3,4,5]," ",[1,3,4,5],[1],[1,3,4],[1,5,6]], "\u2812\u2828\u2827\u2820\u280a\u2823\u281e \u281d\u2801\u280d\u2831"),
            ("VIET NAM", [[4,6],[4,6],[1,2,3,6],[6],[2,4],[1,2,6],[2,3,4,5]," ",[1,3,4,5],[1],[1,3,4],[1,5,6]], "\u2828\u2828\u2827\u2820\u280a\u2823\u281e \u281d\u2801\u280d\u2831"),
        ],
        "X. Abbreviations": [
            ("GDHN", [[6],[4,5,6],[1,2,4,5],[1,4,5],[1,2,5],[1,3,4,5]], "\u2820\u2838\u281b\u2819\u2813\u281d"),
            ("HSPT", [[6],[6],[4,5,6],[1,2,5],[2,3,4],[1,2,3,4],[2,3,4,5]], "\u2820\u2820\u2838\u2813\u280e\u280f\u281e"),
        ],
        "XI. Foreign": [
            ("Microsoft", [[4],[4,6],[1,3,4],[2,4],[1,4],[1,2,3,5],[1,3,5],[2,3,4],[1,3,5],[1,2,4],[2,3,4,5]], "\u2808\u2828\u280d\u280a\u2809\u2817\u2815\u280e\u2815\u280b\u281e"),
        ],
        "XII. Notes": [
            ("bao ghi chu", [[2,5],[2,3]], "\u2812\u2806"),
            ("ket thuc ghi chu", [[2,3],[2,5]], "\u2806\u2812"),
        ],
    }
    
    for section, items in tests.items():
        print(f"\n{section}:")
        for name, dots, expected in items:
            all_checks += 1
            result = dots_to_braille_str(dots)
            if result == expected:
                passed += 1
            else:
                errors.append(f"{section}: {name} (got '{result}', expected '{expected}')")
    
    print(f"\n{'='*60}")
    print(f"INTERNAL CONSISTENCY: {passed}/{all_checks} passed")
    if errors:
        print(f"ERRORS ({len(errors)}):")
        for e in errors:
            print(f"  - {e}")
    else:
        print("All mappings are internally consistent!")
    return passed == all_checks

if __name__ == "__main__":
    verify_internal_consistency()
