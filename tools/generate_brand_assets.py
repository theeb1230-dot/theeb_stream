#!/usr/bin/env python3
"""Generate deterministic Theeb Stream brand PNG assets using stdlib only."""
from __future__ import annotations

import math
import os
import struct
import zlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BG = (15, 23, 42, 255)          # Slate Dark
CYAN = (0, 242, 254, 255)       # Electric Cyan
WHITE = (248, 250, 252, 255)
MUTED = (30, 41, 59, 255)

def _chunk(kind: bytes, data: bytes) -> bytes:
    return struct.pack(">I", len(data)) + kind + data + struct.pack(">I", zlib.crc32(kind + data) & 0xFFFFFFFF)

def write_png(path: Path, w: int, h: int, pixels: bytearray) -> None:
    raw = bytearray()
    stride = w * 4
    for y in range(h):
        raw.append(0)
        raw.extend(pixels[y * stride:(y + 1) * stride])
    png = b"\x89PNG\r\n\x1a\n"
    png += _chunk(b"IHDR", struct.pack(">IIBBBBB", w, h, 8, 6, 0, 0, 0))
    png += _chunk(b"IDAT", zlib.compress(bytes(raw), 9))
    png += _chunk(b"IEND", b"")
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(png)

def canvas(w: int, h: int, color=BG) -> bytearray:
    return bytearray(color * (w * h))

def setpx(p: bytearray, w: int, h: int, x: int, y: int, c) -> None:
    if 0 <= x < w and 0 <= y < h:
        i = (y * w + x) * 4
        p[i:i+4] = bytes(c)

def fill_rect(p, w, h, x0, y0, x1, y1, c):
    x0, x1 = max(0, int(x0)), min(w, int(x1))
    y0, y1 = max(0, int(y0)), min(h, int(y1))
    for y in range(y0, y1):
        for x in range(x0, x1):
            setpx(p, w, h, x, y, c)

def point_in_poly(x: float, y: float, pts) -> bool:
    inside = False
    j = len(pts) - 1
    for i, (xi, yi) in enumerate(pts):
        xj, yj = pts[j]
        if ((yi > y) != (yj > y)) and (x < (xj - xi) * (y - yi) / ((yj - yi) or 1e-9) + xi):
            inside = not inside
        j = i
    return inside

def fill_poly(p, w, h, pts, c):
    minx = max(0, int(min(x for x, _ in pts)))
    maxx = min(w - 1, int(max(x for x, _ in pts)) + 1)
    miny = max(0, int(min(y for _, y in pts)))
    maxy = min(h - 1, int(max(y for _, y in pts)) + 1)
    for y in range(miny, maxy + 1):
        for x in range(minx, maxx + 1):
            if point_in_poly(x + 0.5, y + 0.5, pts):
                setpx(p, w, h, x, y, c)

def fill_circle(p, w, h, cx, cy, r, c):
    x0, x1 = max(0, int(cx-r)), min(w-1, int(cx+r))
    y0, y1 = max(0, int(cy-r)), min(h-1, int(cy+r))
    rr = r*r
    for y in range(y0, y1+1):
        for x in range(x0, x1+1):
            if (x-cx)*(x-cx)+(y-cy)*(y-cy) <= rr:
                setpx(p, w, h, x, y, c)

def icon(size: int) -> bytearray:
    p = canvas(size, size)
    s = float(size)

    # inset dark plate with cyan halo
    fill_circle(p, size, size, s*0.5, s*0.5, s*0.43, MUTED)
    fill_circle(p, size, size, s*0.5, s*0.5, s*0.405, BG)

    # stylized wolf head: ears + angular muzzle
    wolf = [
        (s*.27, s*.29), (s*.38, s*.36), (s*.50, s*.30),
        (s*.62, s*.36), (s*.73, s*.29), (s*.69, s*.52),
        (s*.61, s*.69), (s*.50, s*.78), (s*.39, s*.69),
        (s*.31, s*.52),
    ]
    fill_poly(p, size, size, wolf, CYAN)

    # inner face cutout
    inner = [
        (s*.36, s*.42), (s*.50, s*.36), (s*.64, s*.42),
        (s*.60, s*.57), (s*.50, s*.67), (s*.40, s*.57)
    ]
    fill_poly(p, size, size, inner, BG)

    # eyes
    fill_poly(p, size, size, [(s*.37,s*.47),(s*.46,s*.45),(s*.43,s*.51)], WHITE)
    fill_poly(p, size, size, [(s*.63,s*.47),(s*.54,s*.45),(s*.57,s*.51)], WHITE)

    # play triangle at center/muzzle
    fill_poly(p, size, size, [(s*.46,s*.53),(s*.46,s*.65),(s*.58,s*.59)], WHITE)
    return p

def banner(w=320, h=180) -> bytearray:
    p = canvas(w, h)
    # cyan accent line
    fill_rect(p, w, h, 0, 0, w, max(3, h//36), CYAN)
    # centered icon mark scaled by direct drawing from square source nearest-neighbor
    src_size = min(h - 24, 148)
    src = icon(src_size)
    ox, oy = (w-src_size)//2, (h-src_size)//2
    for y in range(src_size):
        for x in range(src_size):
            si = (y*src_size+x)*4
            di = ((oy+y)*w+(ox+x))*4
            p[di:di+4] = src[si:si+4]
    return p

def save_icon(path: str, size: int):
    write_png(ROOT / path, size, size, icon(size))

def main():
    # Flutter/shared
    save_icon("assets/images/app_icon.png", 1024)
    save_icon("assets/images/theeb_stream_logo.png", 1024)

    # Web
    for path, size in [
        ("web/icons/Icon-192.png", 192),
        ("web/icons/Icon-512.png", 512),
        ("web/icons/Icon-maskable-192.png", 192),
        ("web/icons/Icon-maskable-512.png", 512),
    ]:
        save_icon(path, size)

    # Android mobile mipmaps
    for density, size in [("mdpi",48),("hdpi",72),("xhdpi",96),("xxhdpi",144),("xxxhdpi",192)]:
        save_icon(f"android/app/src/main/res/mipmap-{density}/ic_launcher.png", size)

    # TV launcher bitmaps + banner
    for density, size in [("mdpi",48),("hdpi",72),("xhdpi",96),("xxhdpi",144),("xxxhdpi",192)]:
        save_icon(f"android/tvapp/src/main/res/mipmap-{density}/ic_launcher.png", size)
    save_icon("android/tvapp/src/main/res/drawable-nodpi/ic_launcher.png", 192)
    save_icon("android/tvapp/src/main/res/drawable-nodpi/ic_launcher_foreground.png", 512)
    write_png(ROOT / "android/tvapp/src/main/res/drawable-nodpi/tv_banner_bg.png", 320, 180, banner())

    # iOS icons
    ios = {
        "Icon-App-20x20@1x.png":20, "Icon-App-20x20@2x.png":40, "Icon-App-20x20@3x.png":60,
        "Icon-App-29x29@1x.png":29, "Icon-App-29x29@2x.png":58, "Icon-App-29x29@3x.png":87,
        "Icon-App-40x40@1x.png":40, "Icon-App-40x40@2x.png":80, "Icon-App-40x40@3x.png":120,
        "Icon-App-60x60@2x.png":120, "Icon-App-60x60@3x.png":180,
        "Icon-App-76x76@1x.png":76, "Icon-App-76x76@2x.png":152,
        "Icon-App-83.5x83.5@2x.png":167, "Icon-App-1024x1024@1x.png":1024,
    }
    for name, size in ios.items():
        save_icon(f"ios/Runner/Assets.xcassets/AppIcon.appiconset/{name}", size)

    print("Generated Theeb Stream brand assets.")

if __name__ == "__main__":
    main()
