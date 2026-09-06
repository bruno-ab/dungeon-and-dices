# Tilesets (Godot TileSet)

Fontes RTP copiadas de `assets/sprites/rtp/Graphics/Tilesets` → `assets/tilesets/src/`.

## Recursos

| Arquivo | Conteúdo | Uso |
|---------|----------|-----|
| `village.tres` | A5+A2+B+C+A1 combinados | Mapa da Vila de Cinzas |
| `outside_a5.tres` | Chão simples (meadow, dirt, cobble…) | Terreno base |
| `outside_a2.tres` | Autotile fatiado em 32×32 | Estradas / bordas |
| `outside_b.tres` / `outside_c.tres` | Props / vegetação | Decorações |
| `outside_a1.tres` | Água / animações | Futuro |

Tile size: **32×32** (VX Ace).

## Source IDs em `village.tres`

| ID | Sheet |
|----|--------|
| 0 | Outside_A5 |
| 1 | Outside_A2 |
| 2 | Outside_B |
| 3 | Outside_C |
| 4 | Outside_A1 |

## Regenerar

```bash
python scripts/tools/generate_tilesets.py
```

No editor Godot: abra `village.tres` → painel TileSet para pintar no `TileMapLayer` da vila.

## Camadas do mapa (importante)

Cada `TileMapLayer` guarda **um tile por célula**. Se pintar árvore no mesmo layer do chão, o chão some.

Nas cenas `mylune_forest.tscn` e `village.tscn`:

| Nó | Uso |
|----|-----|
| `World/TileMap` | Só terreno (A5 / A2) |
| `World/Props` | Árvores, pedras, cercas (Outside_B / C) |

Fluxo: selecione o nó **Props** → Paint → source 2 ou 3 → pinte a árvore. O chão em `TileMap` permanece.
