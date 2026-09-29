"""Vẽ icon app và feature graphic cho Play Store.

Chạy: python tools/icon/make_icon.py
"""
import math
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[2]
ICON_DIR = ROOT / "app" / "assets" / "icon"
STORE_DIR = ROOT / "store"

BG = (14, 16, 20, 255)
ACCENT = (255, 122, 69, 255)
TEXT = (236, 238, 242, 255)
MUTED = (154, 160, 171, 255)
SS = 4  # supersampling để viền mịn


def emblem(size: int, background: bool) -> Image.Image:
    """Vòng quản thúc chia 3 đoạn + cuốn sách mở ở giữa."""
    s = size * SS
    img = Image.new("RGBA", (s, s), BG if background else (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    c = s / 2

    # Vòng ngoài gồm 3 cung, mỗi cung có khe hở.
    r_out, width = s * 0.34, s * 0.055
    box = [c - r_out, c - r_out, c + r_out, c + r_out]
    for i in range(3):
        start = -90 + i * 120 + 14
        d.arc(box, start, start + 92, fill=ACCENT, width=int(width))

    # Ba mũi tên chĩa vào tâm tại các khe hở.
    for i in range(3):
        a = math.radians(-90 + i * 120)
        tip_r, base_r, half = s * 0.215, s * 0.30, s * 0.045
        tip = (c + tip_r * math.cos(a), c + tip_r * math.sin(a))
        bx, by = c + base_r * math.cos(a), c + base_r * math.sin(a)
        px, py = -math.sin(a) * half, math.cos(a) * half
        d.polygon([tip, (bx + px, by + py), (bx - px, by - py)], fill=ACCENT)

    # Cuốn sách mở.
    bw, bh = s * 0.19, s * 0.15
    top, spine_dip = c - bh * 0.45, s * 0.018
    left = [(c, top + spine_dip), (c - bw, top), (c - bw, top + bh), (c, top + bh + spine_dip)]
    right = [(c, top + spine_dip), (c + bw, top), (c + bw, top + bh), (c, top + bh + spine_dip)]
    d.polygon(left, fill=TEXT)
    d.polygon(right, fill=TEXT)
    d.line([(c, top + spine_dip), (c, top + bh + spine_dip)], fill=BG, width=int(s * 0.012))
    for k in range(3):
        y = top + bh * (0.28 + k * 0.22)
        for sign in (-1, 1):
            x0, x1 = c + sign * bw * 0.18, c + sign * bw * 0.78
            d.line([(x0, y + spine_dip * 0.6), (x1, y)], fill=MUTED, width=int(s * 0.008))

    return img.resize((size, size), Image.LANCZOS)


def font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont:
    name = "segoeuib.ttf" if bold else "segoeui.ttf"
    try:
        return ImageFont.truetype(name, size)
    except OSError:
        return ImageFont.load_default()


def feature_graphic() -> Image.Image:
    w, h = 1024, 500
    img = Image.new("RGBA", (w, h), BG)
    icon = emblem(420, background=False)
    img.alpha_composite(icon, (40, 40))
    d = ImageDraw.Draw(img)
    d.text((470, 150), "SCP Reader", font=font(88, bold=True), fill=TEXT)
    d.text((474, 262), "Secure. Contain. Read.", font=font(40), fill=ACCENT)
    d.text((474, 322), "Offline SCP Wiki reader", font=font(32), fill=MUTED)
    return img


def main() -> None:
    ICON_DIR.mkdir(parents=True, exist_ok=True)
    STORE_DIR.mkdir(parents=True, exist_ok=True)
    emblem(1024, background=True).save(ICON_DIR / "icon.png")
    # Adaptive icon: foreground trong suốt, launcher có thể cắt tới 1/3 viền nên thu nhỏ vào vùng an toàn.
    fg = Image.new("RGBA", (1024, 1024), (0, 0, 0, 0))
    fg.alpha_composite(emblem(700, background=False), (162, 162))
    fg.save(ICON_DIR / "icon_foreground.png")
    emblem(512, background=True).convert("RGB").save(STORE_DIR / "icon-512.png")
    feature_graphic().convert("RGB").save(STORE_DIR / "feature-graphic.png")
    print("ok")


if __name__ == "__main__":
    main()
