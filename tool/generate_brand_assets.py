#!/usr/bin/env python3
"""Generate Theeb Stream brand assets from deterministic vector-like geometry."""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
S = 2048
BG = (15, 23, 42, 255)
PANEL = (12, 18, 32, 255)
CYAN = (0, 242, 254, 255)
SILVER = (232, 238, 245, 255)
MUTED = (148, 163, 184, 255)


def draw_mark(transparent: bool) -> Image.Image:
    img = Image.new("RGBA", (S, S), (0, 0, 0, 0) if transparent else BG)
    d = ImageDraw.Draw(img)
    if not transparent:
        d.rounded_rectangle((80, 80, S - 80, S - 80), radius=360, fill=PANEL)

    cx = S // 2
    wolf = [
        (cx, 270), (cx - 150, 380), (cx - 430, 250),
        (cx - 350, 610), (cx - 480, 790), (cx - 390, 1170),
        (cx - 220, 1420), (cx, 1620), (cx + 220, 1420),
        (cx + 390, 1170), (cx + 480, 790), (cx + 350, 610),
        (cx + 430, 250), (cx + 150, 380),
    ]
    d.polygon(wolf, fill=SILVER)

    cut = (0, 0, 0, 0) if transparent else PANEL
    for poly in [
        [(cx, 470), (cx - 240, 620), (cx - 310, 880), (cx - 170, 1090), (cx, 970)],
        [(cx, 470), (cx + 240, 620), (cx + 310, 880), (cx + 170, 1090), (cx, 970)],
        [(cx - 320, 960), (cx - 150, 1060), (cx - 100, 1310), (cx - 220, 1420), (cx - 390, 1170)],
        [(cx + 320, 960), (cx + 150, 1060), (cx + 100, 1310), (cx + 220, 1420), (cx + 390, 1170)],
    ]:
        d.polygon(poly, fill=cut)

    d.polygon([(cx - 275, 790), (cx - 85, 835), (cx - 220, 900)], fill=CYAN)
    d.polygon([(cx + 275, 790), (cx + 85, 835), (cx + 220, 900)], fill=CYAN)
    d.polygon([(cx - 80, 1115), (cx + 80, 1115), (cx, 1200)], fill=(45, 55, 72, 255))
    d.polygon([(cx - 72, 1250), (cx - 72, 1425), (cx + 100, 1338)], fill=CYAN)

    # Two streaming arcs complete the "Stream" part of the mark.
    for radius, width in ((350, 20), (420, 16)):
        box = (cx - radius, 1245 - radius // 2, cx + radius, 1245 + radius // 2)
        d.arc(box, start=205, end=335, fill=MUTED, width=width)
    return img


def save_png(image: Image.Image, path: Path, size: tuple[int, int]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    image.resize(size, Image.Resampling.LANCZOS).save(path, optimize=True)


app = draw_mark(False)
mark = draw_mark(True)
save_png(app, ROOT / "assets/images/app_icon.png", (1024, 1024))
save_png(mark, ROOT / "assets/images/theeb_stream_logo.png", (1024, 1024))
save_png(mark, ROOT / "android/tvapp/src/main/res/drawable-nodpi/ic_launcher_foreground.png", (512, 512))

banner = Image.new("RGBA", (1280, 720), BG)
bd = ImageDraw.Draw(banner)
bd.polygon([(0, 610), (1280, 460), (1280, 540), (0, 690)], fill=(0, 242, 254, 44))
banner.alpha_composite(mark.resize((420, 420), Image.Resampling.LANCZOS), (110, 150))
font_path = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"
if Path(font_path).exists():
    title_font = ImageFont.truetype(font_path, 82)
    sub_font = ImageFont.truetype(font_path, 34)
else:
    title_font = ImageFont.load_default()
    sub_font = ImageFont.load_default()
bd.text((560, 250), "THEEB STREAM", font=title_font, fill=SILVER)
bd.text((566, 365), "STREAM. DISCOVER. WATCH.", font=sub_font, fill=MUTED)
save_png(banner, ROOT / "android/tvapp/src/main/res/drawable-nodpi/tv_banner_bg.png", (1280, 720))

print("Generated Theeb Stream cyan wolf/play brand assets.")
