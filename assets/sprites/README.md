# Sprites

## Herói — Terra (`terra/`)

Pack usado pelo personagem jogável (Gildesh).

- GIFs originais em `terra/*.gif`
- Frames PNG em `terra/frames/` (idle/walk 3 direções, battle, cast, etc.)

```bash
python scripts/tools/extract_terra_frames.py
```

`SpriteCatalog.terra()` monta as animações no Godot.

## Outros

| Personagem | Pasta |
|---|---|
| Mira | `mira/` |
| Lodo | `slime/` |
| Sombra | `shade/` |
| Fogueira | `campfire/` |
| Gildesh gerado (legado) | `gildesh/` |
