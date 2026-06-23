"""Extract Braille characters from PNG images by properly handling table structure."""
from PIL import Image
import numpy as np
from scipy import ndimage
import sys

def dots_to_braille(dots_6):
    val = 0
    if dots_6[0]: val |= 1
    if dots_6[1]: val |= 2
    if dots_6[2]: val |= 4
    if dots_6[3]: val |= 8
    if dots_6[4]: val |= 16
    if dots_6[5]: val |= 32
    return chr(0x2800 + val)

def extract_braille_v2(img_path, right_ratio=0.50):
    """Extract Braille cells by first removing ALL table lines, then finding connected components."""
    img = Image.open(img_path).convert('L')
    arr = np.array(img)
    h, w = arr.shape
    dark = arr < 128
    
    # Step 1: Identify horizontal lines - rows with many DARK pixels in a row
    # A horizontal line has many consecutive dark pixels
    h_line_rows = set()
    for y in range(h):
        run = 0
        for x in range(w):
            if dark[y, x]:
                run += 1
                if run > w * 0.4:  # More than 40% of row width
                    h_line_rows.add(y)
            else:
                run = 0
    
    # Step 2: Identify vertical lines
    v_line_cols = set()
    for x in range(w):
        run = 0
        for y in range(h):
            if dark[y, x]:
                run += 1
                if run > h * 0.3:  # More than 30% of column height
                    v_line_cols.add(x)
            else:
                run = 0
    
    # Step 3: Dilate the line masks
    h_line_mask = np.zeros(h, dtype=bool)
    for y in h_line_rows:
        for dy in range(-3, 4):
            if 0 <= y+dy < h:
                h_line_mask[y+dy] = True
    
    v_line_mask = np.zeros(w, dtype=bool)
    for x in v_line_cols:
        for dx in range(-3, 4):
            if 0 <= x+dx < w:
                v_line_mask[x+dx] = True
    
    # Remove lines
    cleaned = dark.copy()
    cleaned[h_line_mask, :] = False
    cleaned[:, v_line_mask] = False
    
    # Focus on right portion
    right_start = int(w * right_ratio)
    region = cleaned[:, right_start:]
    rh, rw = region.shape
    
    # Label components
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
        
        # Braille cells: 8-22px tall, 6-18px wide
        if ch < 8 or ch > 22 or cw < 5 or cw > 18:
            continue
        
        # Aspect ratio check
        if cw > ch * 1.1 or ch > cw * 2.5:
            continue
        
        # Fullness check - Braille cells are NOT solid rectangles
        fullness = area / (ch * cw)
        if fullness > 0.75:
            continue
        
        # Extract from ORIGINAL dark image
        cell = dark[rows[0]:rows[-1]+1, cols[0]+right_start:cols[-1]+1+right_start]
        
        # Divide into 3x2
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

# Extract from all images
for i in range(1, 13):
    try:
        cells = extract_braille_v2(f'E:/vietnamese_braille/quytac/trinh_bay_vb/{i}.png', right_ratio=0.50)
        chars = [c['char'] for c in cells]
        codes = [c['code'] for c in cells]
        unique_codes = sorted(set(codes))
        print(f"Image {i:2d}: {len(cells):3d} cells, unique codes: {unique_codes}")
        if len(cells) > 0:
            print(f"          chars: {''.join(chars[:20])}")
    except Exception as e:
        print(f"Image {i:2d}: Error - {e}")
    print()
