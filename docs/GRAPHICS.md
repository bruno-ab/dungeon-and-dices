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

## Retratos de diálogo (placeholders RTP)

Fonte: `assets/sprites/rtp/Graphics/Faces` (sheets 384×192 → 4×2 faces de 96×96).

| Personagem | Sheet | Índice |
|------------|-------|--------|
| Otto | Actor1 | 0 |
| Mira | Actor3 | 1 |
| Magus | Spiritual | 0 |
| Estalajadeira | People3 | 2 |
| Aldeão | People1 | 0 |

Mapeamento em `SpriteCatalog.portrait()` — rostos não precisam coincidir; só placeholder VN.

## Intro de mundo

`scenes/ui/world_intro.tscn` — `Parallaxes/StarlitSky` + `Titles2/Mountains`, fade e texto subindo (lore Mittelerd). Start Game → intro → vila.

## UI System (RTP)

`scripts/ui/rtp_ui.gd` aplica `Graphics/System/Window.png` em painéis/botões (menu + diálogo).

## Mapa da vila / floresta

- **Mapa inicial:** `scenes/exploration/mylune_forest.tscn` (após intro)
- Vila: `village.tscn` — portal oeste ↔ Mylune
- TileSets: `assets/tilesets/village.tres`

## Código

- `scripts/sprites/sprite_catalog.gd` — fonte de frames/retratos
- `scripts/combat/battle_ui.gd` — stage + party cards
- `scenes/exploration/village.tscn` — mapa
- `scripts/exploration/village_tile_layer.gd` — pintura procedural da vila
- `scripts/world/rtp_tileset.gd` — atalhos `RtpTileset.village()` etc.
