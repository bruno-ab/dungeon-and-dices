#!/usr/bin/env python3
"""Extrai frames PNG dos GIFs da Terra para uso no Godot."""

from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
SRC = ROOT / "assets" / "sprites" / "terra"
OUT = ROOT / "assets" / "sprites" / "terra" / "frames"
PORTRAITS = ROOT / "assets" / "sprites" / "portraits"

# Mapeia arquivos GIF -> pasta de animação
MAP = {
    "Terra (Front).gif": "idle_front",
    "Terra (Back).gif": "idle_back",
    "Terra (Left).gif": "idle_left",
    "Terra - Walk (Front).gif": "walk_front",
    "Terra - Walk (Back).gif": "walk_back",
    "Terra - Walk (Left).gif": "walk_left",
    "Terra - Battle.gif": "battle",
    "Terra - Cast.gif": "cast",
    "Terra - Hit.gif": "hit",
    "Terra - Victory (Left).gif": "victory",
    "Terra - Dead.gif": "dead",
    "Terra - Wounded.gif": "wounded",
    "Terra - Action.gif": "action",
    "Terra - Angry.gif": "angry",
    "Terra - Sad (Front).gif": "sad_front",
    "Terra - Sad (Back).gif": "sad_back",
    "Terra - Sad (Left).gif": "sad_left",
    "Terra - Shock.gif": "shock",
    "Terra - Shocked.gif": "shocked",
    "Terra - Laugh.gif": "laugh",
    "Terra - Finger.gif": "finger",
    "Terra - Steal.gif": "steal",
}


def extract_gif(gif_path: Path, out_dir: Path) -> list[Path]:
    out_dir.mkdir(parents=True, exist_ok=True)
    im = Image.open(gif_path)
    n = getattr(im, "n_frames", 1)
    written: list[Path] = []
    for i in range(n):
        im.seek(i)
        frame = im.convert("RGBA")
        # remove near-black mattes that some GIFs use
        datas = frame.getdata()
        new = []
        for item in datas:
            if item[0] < 8 and item[1] < 8 and item[2] < 8 and item[3] > 200:
                # keep true black outline pixels if surrounded — keep as-is for now
                new.append(item)
            else:
                new.append(item)
        frame.putdata(list(datas))
        dest = out_dir / f"{i:02d}.png"
        frame.save(dest)
        written.append(dest)
    return written


def main() -> None:
    print("Terra GIFs:")
    for gif in sorted(SRC.glob("*.gif")):
        im = Image.open(gif)
        n = getattr(im, "n_frames", 1)
        print(f"  {gif.name}: {im.size} x{n}")

    all_paths: dict[str, list[Path]] = {}
    for filename, anim in MAP.items():
        src = SRC / filename
        if not src.exists():
            print("missing", filename)
            continue
        paths = extract_gif(src, OUT / anim)
        all_paths[anim] = paths
        print(f"extracted {anim}: {len(paths)} frames")

    # Portrait = first frame of idle front (or battle)
    portrait_src = None
    for key in ("idle_front", "battle", "idle_left"):
        if key in all_paths and all_paths[key]:
            portrait_src = all_paths[key][0]
            break
    if portrait_src:
        PORTRAITS.mkdir(parents=True, exist_ok=True)
        img = Image.open(portrait_src).convert("RGBA")
        img.save(PORTRAITS / "gildesh.png")
        img.save(PORTRAITS / "terra.png")
        img.save(PORTRAITS / "warrior.png")
        print("wrote portraits/gildesh.png (+ terra/warrior aliases)")


if __name__ == "__main__":
    main()
