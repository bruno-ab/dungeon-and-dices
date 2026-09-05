# Sprites (MVP)

Pixel art 16×16 gerado em código e escalado ×4 (64×64), paleta sóbria.

| Personagem | Pasta | Frames |
|---|---|---|
| Guerreiro | `warrior/` | idle + walk (4) |
| Mira | `mira/` | idle (2) |
| Lodo | `slime/` | idle (2) |
| Sombra | `shade/` | idle (2) |
| Fogueira | `campfire/` | idle (3) |
| Retratos | `portraits/` | 1 por personagem |

Regenerar:

```bash
python scripts/tools/generate_sprites.py
```

`SpriteCatalog` (`scripts/sprites/sprite_catalog.gd`) monta `SpriteFrames` em runtime para o Godot.
