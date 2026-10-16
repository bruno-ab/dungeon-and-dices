#!/usr/bin/env python3
"""Compõe Mira a partir do Mana Seed Demo e fatia frames no padrão Magus."""

from __future__ import annotations

import shutil
import subprocess
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
ARCHIVE = ROOT / "assets" / "archive" / "FREE Mana Seed Character Base Demo 2.0.zip"
TMP = ROOT / "assets" / "_mana_tmp"
OUT = ROOT / "assets" / "sprites" / "mira" / "frames"
SHEET_OUT = ROOT / "assets" / "sprites" / "mira" / "mira_sheet.png"
LEGACY = ROOT / "assets" / "sprites" / "mira" / "_legacy"
CELL = 64

# Camadas alinhadas do demo Mana Seed (cada arquivo = sheet 512×512).
LAYERS = [
    "char_a_p1/char_a_p1_0bas_humn_v01.png",
    "char_a_p1/1out/char_a_p1_1out_undi_v01.png",
    "char_a_p1/1out/char_a_p1_1out_fstr_v03.png",  # vestimenta “forest”
    "char_a_p1/4har/char_a_p1_4har_bob1_v01.png",  # cabelo bob (depois roxo)
]

# Linhas 0–3 = poses; 4–7 = walk (frente, costas, direita, esquerda).
DIR_ROWS = {
    "front": 4,
    "back": 5,
    "right": 6,
    "left": 7,
}


def seven() -> str:
    return r"C:\Program Files\7-Zip\7z.exe"


def extract_layers() -> list[Path]:
    TMP.mkdir(parents=True, exist_ok=True)
    for old in TMP.glob("*.png"):
        old.unlink()
    cmd = [seven(), "e", str(ARCHIVE), f"-o{TMP}", *LAYERS, "-y"]
    subprocess.run(cmd, check=True, capture_output=True)
    paths = []
    for layer in LAYERS:
        name = Path(layer).name
        path = TMP / name
        if not path.exists():
            raise FileNotFoundError(path)
        paths.append(path)
    return paths


def tint_purple(im: Image.Image, strength: float = 0.55) -> Image.Image:
    """Empurra o cabelo para um roxo próximo da Mira antiga."""
    im = im.convert("RGBA")
    px = im.load()
    w, h = im.size
    for y in range(h):
        for x in range(w):
            r, g, b, a = px[x, y]
            if a < 20:
                continue
            # ignora quase-branco / pele
            if r > 220 and g > 200 and b > 180:
                continue
            lum = (r + g + b) / 3.0
            nr = int(lum * 0.55 + 90 * strength)
            ng = int(lum * 0.35 + 40 * strength)
            nb = int(lum * 0.75 + 120 * strength)
            px[x, y] = (min(255, nr), min(255, ng), min(255, nb), a)
    return im


def composite(paths: list[Path]) -> Image.Image:
    base = Image.new("RGBA", (512, 512), (0, 0, 0, 0))
    for i, path in enumerate(paths):
        layer = Image.open(path).convert("RGBA")
        if "4har_bob1" in path.name:
            layer = tint_purple(layer)
        base.alpha_composite(layer)
    return base


def cell(sheet: Image.Image, col: int, row: int) -> Image.Image:
    x0, y0 = col * CELL, row * CELL
    frame = sheet.crop((x0, y0, x0 + CELL, y0 + CELL))
    bbox = frame.getbbox()
    if not bbox:
        return frame
    # mantém canvas 64×64, só garante conteúdo
    return frame


def write_direction(sheet: Image.Image, name: str, row: int) -> None:
    folder = OUT / name
    folder.mkdir(parents=True, exist_ok=True)
    for old in folder.glob("*.png"):
        old.unlink()
    # Colunas 0–4: idle + walk típico do base Mana Seed nessa linha.
    for col in range(5):
        frame = cell(sheet, col, row)
        frame.save(folder / f"{col:02d}.png")
    # alias idle
    Image.open(folder / "00.png").save(OUT / f"idle_{name}.png")
    print(f"{name}: 5 frames (row {row})")


def archive_legacy() -> None:
    LEGACY.mkdir(parents=True, exist_ok=True)
    for name in [
        "mira_00.png",
        "mira_01.png",
        "mira_walk_00.png",
        "mira_walk_01.png",
        "mira_walk_02.png",
        "mira_walk_03.png",
    ]:
        src = ROOT / "assets" / "sprites" / "mira" / name
        if src.exists():
            dest = LEGACY / name
            shutil.move(str(src), str(dest))
            print("legacy", dest.relative_to(ROOT))
            imp = Path(str(src) + ".import")
            if imp.exists():
                shutil.move(str(imp), str(LEGACY / imp.name))


def main() -> None:
    paths = extract_layers()
    sheet = composite(paths)
    SHEET_OUT.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(SHEET_OUT)
    print("sheet", SHEET_OUT.relative_to(ROOT), sheet.size)

    OUT.mkdir(parents=True, exist_ok=True)
    for name, row in DIR_ROWS.items():
        write_direction(sheet, name, row)

    archive_legacy()
    print("done")


if __name__ == "__main__":
    main()
