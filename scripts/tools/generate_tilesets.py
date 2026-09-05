#!/usr/bin/env python3
"""Gera TileSet (.tres) Godot 4 a partir dos PNGs em assets/tilesets/src."""

from __future__ import annotations

from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
SRC = ROOT / "assets" / "tilesets" / "src"
OUT = ROOT / "assets" / "tilesets"
TILE = 32

# Fonte única por arquivo (source_id no TileSet combinado)
SHEETS = [
    ("Outside_A5.png", "outside_a5", 0),
    ("Outside_A2.png", "outside_a2", 1),
    ("Outside_B.png", "outside_b", 2),
    ("Outside_C.png", "outside_c", 3),
    ("Outside_A1.png", "outside_a1", 4),
]


def atlas_entries(cols: int, rows: int) -> str:
    lines: list[str] = []
    for y in range(rows):
        for x in range(cols):
            lines.append(f"{x}:{y}/0 = 0")
    return "\n".join(lines)


def write_single(png_name: str, resource_stem: str) -> Path:
    png = SRC / png_name
    im = Image.open(png)
    w, h = im.size
    cols, rows = w // TILE, h // TILE
    uid = f"uid://ts{resource_stem.replace('_', '')}001"
    text = f"""[gd_resource type="TileSet" load_steps=3 format=3 uid="{uid}"]

[ext_resource type="Texture2D" path="res://assets/tilesets/src/{png_name}" id="1_tex"]

[sub_resource type="TileSetAtlasSource" id="TileSetAtlasSource_0"]
texture = ExtResource("1_tex")
texture_region_size = Vector2i({TILE}, {TILE})
{atlas_entries(cols, rows)}

[resource]
tile_size = Vector2i({TILE}, {TILE})
sources/0 = SubResource("TileSetAtlasSource_0")
"""
    out = OUT / f"{resource_stem}.tres"
    out.write_text(text, encoding="utf-8")
    print(f"wrote {out.relative_to(ROOT)} ({cols}x{rows} tiles)")
    return out


def write_village_combined() -> Path:
    """TileSet da vila com várias fontes (A5 chão, A2 terreno, B/C decorações)."""
    load_steps = 1 + len(SHEETS) * 2  # ext + sub per sheet roughly
    # Accurate: 1 resource + N ext + N sub = 1 + 2N, load_steps = 1+2N
    load_steps = 1 + 2 * len(SHEETS)

    parts: list[str] = [
        f'[gd_resource type="TileSet" load_steps={load_steps} format=3 uid="uid://tsvillageash001"]',
        "",
    ]
    for i, (png, _stem, _sid) in enumerate(SHEETS):
        parts.append(
            f'[ext_resource type="Texture2D" path="res://assets/tilesets/src/{png}" id="tex_{i}"]'
        )
    parts.append("")

    for i, (png, _stem, sid) in enumerate(SHEETS):
        im = Image.open(SRC / png)
        cols, rows = im.size[0] // TILE, im.size[1] // TILE
        parts.append(f'[sub_resource type="TileSetAtlasSource" id="atlas_{i}"]')
        parts.append(f'texture = ExtResource("tex_{i}")')
        parts.append(f"texture_region_size = Vector2i({TILE}, {TILE})")
        parts.append(atlas_entries(cols, rows))
        parts.append("")

    parts.append("[resource]")
    parts.append(f"tile_size = Vector2i({TILE}, {TILE})")
    for i, (_png, _stem, sid) in enumerate(SHEETS):
        parts.append(f"sources/{sid} = SubResource(\"atlas_{i}\")")
    parts.append("")

    out = OUT / "village.tres"
    out.write_text("\n".join(parts), encoding="utf-8")
    print(f"wrote {out.relative_to(ROOT)} (combined {len(SHEETS)} sources)")
    return out


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    for png, stem, _sid in SHEETS:
        if not (SRC / png).exists():
            raise SystemExit(f"missing {SRC / png}")
        write_single(png, stem)
    write_village_combined()


if __name__ == "__main__":
    main()
