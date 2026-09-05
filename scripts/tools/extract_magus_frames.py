#!/usr/bin/env python3
"""Fatia a spritesheet magus.png em frames PNG com fundo transparente."""

from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
SRC = ROOT / "assets" / "sprites" / "magus" / "magus.png"
OUT = ROOT / "assets" / "sprites" / "magus" / "frames"
PORTRAITS = ROOT / "assets" / "sprites" / "portraits"

ROW_BANDS = [
    (12, 162),
    (184, 327),
    (342, 488),
    (499, 654),
    (688, 856),
    (889, 1053),
    (1082, 1234),
]

ROW_NAMES = [
    "front",
    "right",
    "left",
    "back",
    "attack",
    "cast",
    "hurt",
]


def is_empty(px) -> bool:
    r, g, b, a = px
    return a < 10 or (r > 240 and g > 240 and b > 240)


def make_transparent(im: Image.Image) -> Image.Image:
    im = im.convert("RGBA")
    out = []
    for item in im.getdata():
        if is_empty(item):
            out.append((0, 0, 0, 0))
        else:
            out.append(item)
    im.putdata(out)
    return im


def segments_in_row(im: Image.Image, y0: int, y1: int) -> list[tuple[int, int]]:
    w, _ = im.size
    dens = []
    for x in range(w):
        has = any(not is_empty(im.getpixel((x, y))) for y in range(y0, y1, 2))
        dens.append(1 if has else 0)
    segs: list[tuple[int, int]] = []
    inb = False
    s = 0
    for x, v in enumerate(dens):
        if v and not inb:
            s = x
            inb = True
        elif not v and inb:
            if x - s > 20:
                segs.append((s, x))
            inb = False
    if inb and w - s > 20:
        segs.append((s, w))
    # drop tiny leftover fragments
    return [(a, b) for a, b in segs if (b - a) >= 40]


def tight_crop(im: Image.Image, box: tuple[int, int, int, int], pad: int = 2) -> Image.Image:
    x0, y0, x1, y1 = box
    crop = im.crop((x0, y0, x1, y1))
    bbox = crop.getbbox()
    if not bbox:
        return crop
    bx0, by0, bx1, by1 = bbox
    bx0 = max(0, bx0 - pad)
    by0 = max(0, by0 - pad)
    bx1 = min(crop.width, bx1 + pad)
    by1 = min(crop.height, by1 + pad)
    return crop.crop((bx0, by0, bx1, by1))


def main() -> None:
    raw = Image.open(SRC).convert("RGBA")
    im = make_transparent(raw.copy())
    OUT.mkdir(parents=True, exist_ok=True)
    for (y0, y1), name in zip(ROW_BANDS, ROW_NAMES):
        segs = segments_in_row(raw, y0, y1)
        folder = OUT / name
        folder.mkdir(parents=True, exist_ok=True)
        # limpa frames antigos
        for old in folder.glob("*.png"):
            old.unlink()
        print(f"{name}: {len(segs)} frames")
        for fi, (x0, x1) in enumerate(segs):
            frame = tight_crop(im, (x0, y0, x1, y1))
            dest = folder / f"{fi:02d}.png"
            frame.save(dest)
            print(" ", dest.relative_to(ROOT), frame.size)

    # aliases de gameplay
    aliases = {
        "idle_front": OUT / "front" / "00.png",
        "idle_right": OUT / "right" / "00.png",
        "idle_left": OUT / "left" / "00.png",
        "idle_back": OUT / "back" / "00.png",
    }
    for alias, src in aliases.items():
        if src.exists():
            dest = OUT / f"{alias}.png"
            Image.open(src).save(dest)
            print("alias", dest.name)

    PORTRAITS.mkdir(parents=True, exist_ok=True)
    portrait_src = OUT / "front" / "00.png"
    if portrait_src.exists():
        Image.open(portrait_src).convert("RGBA").save(PORTRAITS / "magus.png")
        print("wrote portraits/magus.png")


if __name__ == "__main__":
    main()
