import os
from PIL import Image, ImageDraw

def process_icon():
    src_path = "e:/vietnamese_braille/viet_braille_app/assets/icon/app_icon.png"
    dst_png = "e:/vietnamese_braille/viet_braille_app/assets/icon/app_icon_transparent.png"
    dst_ico_assets = "e:/vietnamese_braille/viet_braille_app/assets/icon/app_icon.ico"
    dst_ico_windows = "e:/vietnamese_braille/viet_braille_app/windows/runner/resources/app_icon.ico"

    img = Image.open(src_path).convert("RGBA")
    width, height = img.size

    # Flood fill or convert outer white background to transparent RGBA (0, 0, 0, 0)
    datas = img.getdata()
    new_data = []
    for item in datas:
        # Check if pixel is white / near white (outer background)
        r, g, b, a = item
        if r > 245 and g > 245 and b > 245:
            new_data.append((255, 255, 255, 0)) # Fully transparent
        else:
            new_data.append((r, g, b, a))

    img.putdata(new_data)

    # Crop bounding box of non-transparent content
    bbox = img.getbbox()
    if bbox:
        img = img.crop(bbox)

    # Create a nice clean square image with rounded corners
    max_dim = max(img.width, img.height)
    square_img = Image.new("RGBA", (max_dim, max_dim), (0, 0, 0, 0))
    offset = ((max_dim - img.width) // 2, (max_dim - img.height) // 2)
    square_img.paste(img, offset, img)

    # Save transparent PNG
    square_img.save(dst_png, "PNG")

    # Save ICO with multiple sizes with transparency
    sizes = [(16, 16), (24, 24), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)]
    square_img.save(dst_ico_assets, format="ICO", sizes=sizes)
    square_img.save(dst_ico_windows, format="ICO", sizes=sizes)
    print("Successfully created transparent ICO icon!")

if __name__ == "__main__":
    process_icon()
