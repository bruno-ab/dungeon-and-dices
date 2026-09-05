#!/usr/bin/env python3
"""Gera sprites pixel art placeholder para o MVP Dungeon and Dices."""

from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "assets" / "sprites"
SCALE = 4  # 16x16 -> 64x64 on export for visibility
SIZE = 16

# Paleta sóbria
C = {
    "empty": (0, 0, 0, 0),
    "outline": (18, 16, 22, 255),
    # Guerreiro
    "skin": (196, 164, 132, 255),
    "skin_shadow": (150, 118, 96, 255),
    "steel": (120, 132, 148, 255),
    "steel_dark": (70, 78, 92, 255),
    "cloak": (56, 72, 88, 255),
    "gold": (196, 168, 96, 255),
    "boot": (54, 40, 36, 255),
    # Mira
    "mira_cloak": (92, 64, 120, 255),
    "mira_cloak_d": (58, 40, 78, 255),
    "mira_hair": (210, 180, 120, 255),
    "mira_accent": (180, 120, 200, 255),
    # Slime
    "slime": (64, 120, 78, 255),
    "slime_d": (36, 72, 48, 255),
    "slime_h": (120, 180, 130, 255),
    "eye": (220, 230, 200, 255),
    "pupil": (20, 24, 20, 255),
    # Shade
    "shade": (58, 52, 78, 255),
    "shade_d": (28, 24, 40, 255),
    "shade_g": (120, 100, 160, 255),
}


def blank():
    return [[None for _ in range(SIZE)] for _ in range(SIZE)]


def set_px(grid, x, y, color):
    if 0 <= x < SIZE and 0 <= y < SIZE:
        grid[y][x] = color


def fill_rect(grid, x0, y0, w, h, color):
    for y in range(y0, y0 + h):
        for x in range(x0, x0 + w):
            set_px(grid, x, y, color)


def outline_nonzero(grid, outline="outline"):
    src = [row[:] for row in grid]
    for y in range(SIZE):
        for x in range(SIZE):
            if src[y][x] is None:
                continue
            for dx, dy in ((-1, 0), (1, 0), (0, -1), (0, 1)):
                nx, ny = x + dx, y + dy
                if not (0 <= nx < SIZE and 0 <= ny < SIZE) or src[ny][nx] is None:
                    set_px(grid, nx, ny, C[outline])


def save(grid, path: Path):
    img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    px = img.load()
    for y in range(SIZE):
        for x in range(SIZE):
            if grid[y][x] is not None:
                px[x, y] = grid[y][x]
    big = img.resize((SIZE * SCALE, SIZE * SCALE), Image.Resampling.NEAREST)
    path.parent.mkdir(parents=True, exist_ok=True)
    big.save(path)
    print("wrote", path.relative_to(ROOT))


def warrior(frame: int):
    g = blank()
    # legs
    leg = 1 if frame % 2 == 0 else 0
    fill_rect(g, 5, 12, 2, 3, C["boot"])
    fill_rect(g, 9, 12, 2, 3, C["boot"])
    if frame in (1, 3):
        fill_rect(g, 4 + leg, 12, 2, 3, C["boot"])
        fill_rect(g, 10 - leg, 11, 2, 4, C["boot"])
    # body / cloak
    fill_rect(g, 5, 7, 6, 5, C["cloak"])
    fill_rect(g, 6, 8, 4, 3, C["steel"])
    # head
    fill_rect(g, 6, 3, 4, 4, C["skin"])
    fill_rect(g, 6, 3, 4, 1, C["skin_shadow"])
    # helmet crest
    fill_rect(g, 7, 2, 2, 1, C["gold"])
    fill_rect(g, 5, 4, 1, 2, C["steel_dark"])
    fill_rect(g, 10, 4, 1, 2, C["steel_dark"])
    # sword arm
    arm_y = 8 + (1 if frame in (1, 2) else 0)
    fill_rect(g, 11, arm_y, 3, 1, C["skin"])
    fill_rect(g, 13, arm_y - 2, 1, 4, C["steel"])
    fill_rect(g, 13, arm_y - 3, 1, 1, C["gold"])
    outline_nonzero(g)
    return g


def mira(frame: int):
    g = blank()
    bob = 0 if frame % 2 == 0 else 1
    fill_rect(g, 5, 12 + bob, 2, 3 - bob, C["boot"])
    fill_rect(g, 9, 12 + bob, 2, 3 - bob, C["boot"])
    fill_rect(g, 5, 7 + bob, 6, 5, C["mira_cloak"])
    fill_rect(g, 6, 8 + bob, 4, 3, C["mira_cloak_d"])
    fill_rect(g, 6, 3 + bob, 4, 4, C["skin"])
    fill_rect(g, 5, 3 + bob, 6, 2, C["mira_hair"])
    fill_rect(g, 4, 5 + bob, 1, 3, C["mira_hair"])
    fill_rect(g, 11, 5 + bob, 1, 3, C["mira_hair"])
    # staff
    fill_rect(g, 12, 4 + bob, 1, 9, C["mira_accent"])
    fill_rect(g, 11, 3 + bob, 3, 1, C["gold"])
    outline_nonzero(g)
    return g


def slime(frame: int):
    g = blank()
    squash = frame % 2
    top = 6 - squash
    h = 8 + squash
    fill_rect(g, 3, top, 10, h, C["slime"])
    fill_rect(g, 4, top + 1, 8, h - 2, C["slime_h"])
    fill_rect(g, 3, top + h - 2, 10, 2, C["slime_d"])
    # eyes
    ey = top + 3
    fill_rect(g, 5, ey, 2, 2, C["eye"])
    fill_rect(g, 9, ey, 2, 2, C["eye"])
    fill_rect(g, 6, ey + 1, 1, 1, C["pupil"])
    fill_rect(g, 10, ey + 1, 1, 1, C["pupil"])
    # shine
    set_px(g, 5, top + 1, C["eye"])
    outline_nonzero(g)
    return g


def shade(frame: int):
    g = blank()
    drift = frame % 2
    fill_rect(g, 5, 3 + drift, 6, 10, C["shade"])
    fill_rect(g, 6, 4 + drift, 4, 7, C["shade_d"])
    # ragged bottom
    for x, y in ((4, 12 + drift), (7, 13 + drift), (10, 12 + drift), (12, 11 + drift)):
        set_px(g, x, y, C["shade"])
    # glowing eyes
    fill_rect(g, 6, 6 + drift, 2, 1, C["shade_g"])
    fill_rect(g, 9, 6 + drift, 2, 1, C["shade_g"])
    fill_rect(g, 7, 5 + drift, 1, 1, C["eye"])
    fill_rect(g, 10, 5 + drift, 1, 1, C["eye"])
    outline_nonzero(g)
    return g


def campfire(frame: int):
    g = blank()
    fill_rect(g, 4, 11, 8, 3, C["boot"])
    fill_rect(g, 5, 10, 6, 1, C["steel_dark"])
    flicker = frame % 3
    flame = [
        (7, 8, C["gold"]),
        (8, 7, C["gold"]),
        (6, 7, (220, 120, 60, 255)),
        (7, 6, (240, 180, 80, 255)),
        (8, 5 - (1 if flicker == 1 else 0), (255, 220, 140, 255)),
        (7, 4 if flicker != 2 else 5, (255, 240, 180, 255)),
    ]
    for x, y, col in flame:
        set_px(g, x, y, col)
        set_px(g, x + (1 if flicker == 0 else 0), y + 1, (220, 100, 50, 255))
    outline_nonzero(g)
    return g


def main():
    chars = {
        "warrior": (warrior, 4),
        "mira": (mira, 2),
        "slime": (slime, 2),
        "shade": (shade, 2),
        "campfire": (campfire, 3),
    }
    for name, (fn, frames) in chars.items():
        folder = OUT / name
        for i in range(frames):
            save(fn(i), folder / f"{name}_{i:02d}.png")
        # also export a portrait (frame 0)
        save(fn(0), OUT / "portraits" / f"{name}.png")
    print("done ->", OUT)


if __name__ == "__main__":
    main()
