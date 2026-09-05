# Sprites (MVP)

Pixel art 16×16 gerado em código e escalado ×4 (64×64), paleta sóbria.

| Personagem | Pasta | Frames |
|---|---|---|
| Guerreiro / **Gildesh** | `gildesh/` | idle + walk (4) + back (2) |
| Mira | `mira/` | idle (2) |
| Lodo | `slime/` | idle (2) |
| Sombra | `shade/` | idle (2) |
| Fogueira | `campfire/` | idle (3) |
| Retratos | `portraits/` | 1 por personagem |

Regenerar:

```bash
python scripts/tools/generate_sprites.py
python scripts/tools/generate_gildesh.py
```

Concept de referência: `assets/references/gildesh-concept.png`