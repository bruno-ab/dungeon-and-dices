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
| mylune | Serpentes | `enemies/serpent/` |
| trilha | Slime + Shade | `slime/`, `shade/` |
| cemiterio | Golem + Trolling | `enemies/golem/`, `enemies/trolling/` |
