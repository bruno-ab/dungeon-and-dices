#!/usr/bin/env python3
"""Gera sprites pixel art do Gildesh Siannodel (Elezen Mage) a partir do concept."""

from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "assets" / "sprites" / "gildesh"
PORTRAITS = ROOT / "assets" / "sprites" / "portraits"
SIZE = 32
SCALE = 4

# Paleta do concept: roxo profundo, prata, couro, pele bronzeada, gema azul
P = {
    "outline": (12, 10, 16, 255),
    "skin": (148, 108, 82, 255),
    "skin_d": (110, 78, 58, 255),
    "hair": (18, 16, 20, 255),
    "hair_h": (40, 36, 44, 255),
    "robe": (72, 42, 98, 255),
    "robe_d": (42, 24, 58, 255),
    "robe_h": (98, 62, 128, 255),
    "silver": (186, 196, 210, 255),
    "silver_d": (110, 120, 138, 255),
    "leather": (78, 52, 38, 255),
    "boot": (36, 28, 26, 255),
    "scarf": (58, 54, 62, 255),
    "gem": (64, 150, 220, 255),
    "gem_h": (140, 210, 255, 255),
    "eye": (30, 24, 28, 255),
    "tatter": (58, 34, 78, 255),
}


def blank():
    return [[None for _ in range(SIZE)] for _ in range(SIZE)]


def px(g, x, y, c):
    if 0 <= x < SIZE and 0 <= y < SIZE:
        g[y][x] = c


def rect(g, x0, y0, w, h, c):
    for y in range(y0, y0 + h):
        for x in range(x0, x0 + w):
            px(g, x, y, c)


def outline(g):
    src = [row[:] for row in g]
    for y in range(SIZE):
        for x in range(SIZE):
            if src[y][x] is None:
                continue
            for dx, dy in ((-1, 0), (1, 0), (0, -1), (0, 1)):
                nx, ny = x + dx, y + dy
                if not (0 <= nx < SIZE and 0 <= ny < SIZE) or src[ny][nx] is None:
                    px(g, nx, ny, P["outline"])


def save(g, path: Path):
    img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    pix = img.load()
    for y in range(SIZE):
        for x in range(SIZE):
            if g[y][x] is not None:
                pix[x, y] = g[y][x]
    big = img.resize((SIZE * SCALE, SIZE * SCALE), Image.Resampling.NEAREST)
    path.parent.mkdir(parents=True, exist_ok=True)
    big.save(path)
    print("wrote", path.relative_to(ROOT))


def gildesh_front(frame: int = 0):
    """Vista frontal / 3/4 leve — idle e walk."""
    g = blank()
    bob = 0 if frame % 2 == 0 else 1
    step = frame % 4

    # Boots / legs
    if step in (0, 2):
        rect(g, 12, 26 + bob, 3, 5, P["boot"])
        rect(g, 17, 26 + bob, 3, 5, P["boot"])
    elif step == 1:
        rect(g, 11, 25 + bob, 3, 6, P["boot"])
        rect(g, 18, 26 + bob, 3, 4, P["boot"])
    else:
        rect(g, 12, 26 + bob, 3, 4, P["boot"])
        rect(g, 18, 25 + bob, 3, 6, P["boot"])

    # Long tattered robe
    rect(g, 10, 14 + bob, 12, 13, P["robe"])
    rect(g, 11, 15 + bob, 10, 10, P["robe_h"])
    rect(g, 10, 22 + bob, 12, 4, P["robe_d"])
    # tatters
    for x, y in ((9, 27 + bob), (10, 28 + bob), (14, 28 + bob), (20, 28 + bob), (21, 27 + bob), (22, 26 + bob)):
        px(g, x, y, P["tatter"])

    # Belt + gem + satchel + potion
    rect(g, 11, 20 + bob, 10, 2, P["leather"])
    rect(g, 14, 18 + bob, 3, 3, P["gem"])
    px(g, 15, 18 + bob, P["gem_h"])
    rect(g, 20, 21 + bob, 4, 4, P["leather"])  # grimoire pouch
    rect(g, 9, 21 + bob, 2, 2, P["gem"])  # potion

    # Silver braid tassel
    rect(g, 15, 22 + bob, 1, 5, P["silver_d"])
    px(g, 15, 27 + bob, P["silver"])

    # Torso / high collar
    rect(g, 12, 11 + bob, 8, 4, P["robe"])
    rect(g, 13, 10 + bob, 6, 2, P["scarf"])
    rect(g, 12, 9 + bob, 8, 2, P["robe_d"])  # high collar

    # Pauldrons
    rect(g, 8, 12 + bob, 4, 3, P["silver"])
    rect(g, 20, 12 + bob, 4, 3, P["silver"])
    px(g, 8, 11 + bob, P["silver_d"])
    px(g, 23, 11 + bob, P["silver_d"])

    # Arms / gauntlets
    arm = 1 if step in (1, 2) else 0
    rect(g, 7, 15 + bob + arm, 3, 5, P["robe_d"])
    rect(g, 7, 18 + bob + arm, 3, 3, P["silver"])
    rect(g, 22, 15 + bob - arm, 3, 5, P["robe_d"])
    rect(g, 22, 18 + bob - arm, 3, 3, P["silver"])

    # Head
    rect(g, 13, 4 + bob, 6, 6, P["skin"])
    rect(g, 13, 4 + bob, 6, 2, P["skin_d"])
    # eyes
    px(g, 14, 7 + bob, P["eye"])
    px(g, 17, 7 + bob, P["eye"])
    # hair + ponytail
    rect(g, 12, 2 + bob, 8, 3, P["hair"])
    rect(g, 13, 1 + bob, 5, 2, P["hair_h"])
    rect(g, 18, 5 + bob, 2, 5, P["hair"])  # ponytail side/back hint
    # long elf ears
    rect(g, 10, 6 + bob, 3, 1, P["skin"])
    rect(g, 9, 6 + bob, 2, 1, P["skin_d"])
    rect(g, 19, 6 + bob, 3, 1, P["skin"])
    rect(g, 21, 6 + bob, 2, 1, P["skin_d"])

    outline(g)
    return g


def gildesh_back(frame: int = 0):
    g = blank()
    bob = frame % 2
    # boots
    rect(g, 12, 26 + bob, 3, 5, P["boot"])
    rect(g, 17, 26 + bob, 3, 5, P["boot"])
    # robe
    rect(g, 10, 14 + bob, 12, 13, P["robe"])
    rect(g, 11, 15 + bob, 10, 11, P["robe_d"])
    for x, y in ((9, 27 + bob), (14, 28 + bob), (21, 27 + bob)):
        px(g, x, y, P["tatter"])
    # crest on back (silver jagged)
    rect(g, 14, 16 + bob, 4, 5, P["silver"])
    px(g, 13, 17 + bob, P["silver_d"])
    px(g, 18, 17 + bob, P["silver_d"])
    px(g, 15, 15 + bob, P["silver"])
    px(g, 16, 15 + bob, P["silver"])
    # pauldrons
    rect(g, 8, 12 + bob, 4, 3, P["silver"])
    rect(g, 20, 12 + bob, 4, 3, P["silver"])
    # head back / hair
    rect(g, 13, 4 + bob, 6, 6, P["hair"])
    rect(g, 14, 3 + bob, 4, 2, P["hair_h"])
    rect(g, 15, 8 + bob, 3, 6, P["hair"])  # ponytail down
    # ears from behind
    rect(g, 10, 6 + bob, 2, 1, P["skin"])
    rect(g, 20, 6 + bob, 2, 1, P["skin"])
    outline(g)
    return g


def gildesh_portrait():
    """Retrato 32x32 mais close no busto."""
    g = blank()
    # shoulders
    rect(g, 4, 20, 24, 10, P["robe"])
    rect(g, 6, 18, 20, 6, P["robe_h"])
    rect(g, 2, 18, 6, 6, P["silver"])
    rect(g, 24, 18, 6, 6, P["silver"])
    # collar / scarf
    rect(g, 10, 16, 12, 4, P["scarf"])
    rect(g, 9, 14, 14, 3, P["robe_d"])
    # gem
    rect(g, 14, 20, 4, 4, P["gem"])
    px(g, 15, 20, P["gem_h"])
    # head
    rect(g, 11, 6, 10, 10, P["skin"])
    rect(g, 11, 6, 10, 3, P["skin_d"])
    px(g, 13, 11, P["eye"])
    px(g, 18, 11, P["eye"])
    # hair
    rect(g, 10, 3, 12, 5, P["hair"])
    rect(g, 12, 2, 7, 2, P["hair_h"])
    rect(g, 19, 8, 3, 8, P["hair"])
    # ears
    rect(g, 6, 10, 5, 2, P["skin"])
    rect(g, 5, 10, 2, 1, P["skin_d"])
    rect(g, 21, 10, 5, 2, P["skin"])
    rect(g, 25, 10, 2, 1, P["skin_d"])
    outline(g)
    return g


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    PORTRAITS.mkdir(parents=True, exist_ok=True)
    for i in range(4):
        save(gildesh_front(i), OUT / f"gildesh_{i:02d}.png")
    save(gildesh_back(0), OUT / "gildesh_back_00.png")
    save(gildesh_back(1), OUT / "gildesh_back_01.png")
    save(gildesh_portrait(), PORTRAITS / "gildesh.png")
    save(gildesh_front(0), PORTRAITS / "warrior.png")  # player usa este como default
    print("done")


if __name__ == "__main__":
    main()
