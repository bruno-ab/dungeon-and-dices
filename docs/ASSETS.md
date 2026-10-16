# Organização de assets

## Estrutura ativa (jogo)

```
assets/
├── archive/                 # zips/7z originais
├── references/              # concept art
└── sprites/
    ├── battlers/            # party em combate (otto, lyra, kelvin)
    ├── battlebacks/         # fundos de batalha
    ├── enemies/             # serpent, golem, trolling (+ slime/shade legado)
    ├── magus/ mira/ terra/  # overworld / frames
    ├── portraits/           # bustos UI
    ├── props/ (campfire)
    ├── characters/          # vendor Pixel Champions (fonte)
    ├── Monster Pack 1/      # vendor (fonte)
    └── rtp/                 # RPG Maker pack (fonte; não referenciado direto)
```

## Mapeamento de classes

| Classe | Nome | Battler | Overworld |
|--------|------|---------|-----------|
| Guerreiro | Otto | `battlers/otto/` | terra frames |
| Druida | Mira | `battlers/lyra/` | mira |
| Mago | Magus | `battlers/kelvin/` | magus frames |

## Combates

| ID | Criaturas | Assets |
|----|-----------|--------|
| mylune | Serpentes + Sapo Rúnico | `enemies/serpent/`, `enemies/rune_frog/` (do Monster Pack 1) |
| trilha | Slime + Shade | `slime/`, `shade/` |
| cemiterio | Golem + Trolling | `enemies/golem/`, `enemies/trolling/` |

## Demos de arte (15-10-2026)

- **Pack:** `enemies/rune_frog/` veio de `archive/Monster Pack 1.7z` (RUNE FROGS Brown_1/2). Entra em Mylune como terceiro inimigo.
- **Mira overworld:** composta do Mana Seed Demo (`humn` + `undi` + `fstr_v03` + `bob1` tingido de roxo) via `scripts/tools/build_mira_frames.py` → `mira/mira_sheet.png` e `mira/frames/{front,back,left,right}/00..04.png` (mesmo padrão do Magus). Placeholders procedurais em `mira/_legacy/`.
