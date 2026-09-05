# Gráficos — onde melhorar

## Bug corrigido (Sep 2026)

Sheets de battler/retrato **288×192** (Pixel Champions) eram desenhados **inteiros** → “grade” de bonequinhos na vila/combate e nos cards da party.  
Agora o combate usa frames de overworld (`terra` / `mira` / `magus`) e retratos fatiam a 1ª célula quando ainda são sheet.

## Prioridades (maior impacto primeiro)

1. **Vila (TileMap)** — trocar ColorRects cinza por tileset (chão, paredes, poço, torre). Sem isso a cena continua “whitebox”.
2. **NPCs consistentes** — Mira/slime ok; Aldeão e portões ainda são `Polygon2D`. Usar sprites do mesmo estilo do Magus/Otto.
3. **HUD da vila** — painel semi-transparente + tipografia única; tirar labels flutuantes cruas (`→ Trilha`) e virar placas/sinais.
4. **Combate — layout** — Stage só na metade superior; dashboard não deve receber nomes de inimigos por cima. Battleback temático (floresta/cemitério) em vez de nebulosa genérica quando possível.
5. **UI de batalha** — Theme próprio (bordas, fontes pixel, barras HP/MP); botões de reação com ícone + dado.
6. **Diálogo VN** — portrait maior, caixa com 9-slice, tipografia de leitura.
7. **Atmosfera** — `CanvasModulate` / luz 2D leve na vila (cinzas, fogo da estalagem).

## Assets já no repo

- `assets/sprites/terra`, `magus`, `mira` — bons para overworld
- `assets/sprites/characters/Pixel_Champions_v3` — sheets; usar **só com AtlasTexture** (3×3 de 96×64)
- Battlebacks em `assets/sprites/...` / encounter meta

## Código

- `scripts/sprites/sprite_catalog.gd` — fonte de frames/retratos
- `scripts/combat/battle_ui.gd` — stage + party cards
- `scenes/exploration/village.tscn` — mapa
