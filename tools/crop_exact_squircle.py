import os
from PIL import Image, ImageDraw, ImageFilter

def create_perfect_rounded_icon():
    src_path = "e:/vietnamese_braille/viet_braille_app/assets/icon/app_icon.png"
    dst_png = "e:/vietnamese_braille/viet_braille_app/assets/icon/app_icon_clean.png"
    dst_ico_assets = "e:/vietnamese_braille/viet_braille_app/assets/icon/app_icon.ico"
    dst_ico_windows = "e:/vietnamese_braille/viet_braille_app/windows/runner/resources/app_icon.ico"

    img = Image.open(src_path).convert("RGBA")
    width, height = img.size

    # Detect the squircle card bounds: scan from center outwards or find color change
    # Center is (512, 512). The card background is very light/white.
    # Let's find where the card shadow/border begins from the edges.
    
    # Crop the central card area (approx 520x520 in the center of 1024x1024)
    # Let's auto-find the card boundary by looking for shadow/border pixels around center
    card_margin = 256 # Default crop box around center
    
    # Let's find exact bounding box by searching for card background
    # Scan from top down to find top edge of card shadow/border:
    center_x = width // 2
    
    # Find top edge of the card
    top = 0
    for y in range(0, height // 2):
        r, g, b, a = img.getpixel((center_x, y))
        if r > 240 and g > 240 and b > 240:
            top = y
            break
            
    # Find bottom edge of the card
    bottom = height
    for y in range(height - 1, height // 2, -1):
        r, g, b, a = img.getpixel((center_x, y))
        if r > 240 and g > 240 and b > 240:
            bottom = y
            break

    # To be 100% clean and precise: crop box [250, 250, 774, 774]
    left = 250
    top = 250
    right = 774
    bottom = 774
    
    cropped = img.crop((left, top, right, bottom))
    c_w, c_h = cropped.size
    
    # Create an antialiased rounded rectangle mask at 4x resolution
    scale = 4
    mask_size = (c_w * scale, c_h * scale)
    mask = Image.new("L", mask_size, 0)
    draw = ImageDraw.Draw(mask)
    
    radius = int(c_w * scale * 0.22) # 22% corner radius for smooth squircle
    draw.rounded_rectangle([(0, 0), mask_size], radius=radius, fill=255)
    
    # Downsample mask to 1x with LANCZOS for super smooth antialiasing
    mask = mask.resize((c_w, c_h), Image.Resampling.LANCZOS)
    
    # Create output image
    output = Image.new("RGBA", (c_w, c_h), (0, 0, 0, 0))
    output.paste(cropped, (0, 0), mask=mask)
    
    # Save clean PNG
    output.save(dst_png, "PNG")
    
    # Save multi-resolution ICO file
    sizes = [(16, 16), (24, 24), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)]
    output.save(dst_ico_assets, format="ICO", sizes=sizes)
    output.save(dst_ico_windows, format="ICO", sizes=sizes)
    print("Successfully created PERFECT antialiased rounded ICO icon!")

if __name__ == "__main__":
    create_perfect_rounded_icon()
