# Dungeon and Dices

RPG de turnos 2D (Godot **4.7.2**) — combate reativo, Dice Engine e recrutamento dinâmico.

## Jogar agora

1. Abra no Godot 4.7.2  
2. **F5** → menu → **Start Game**  
3. Explore a **Vila de Cinzas** (Fase 1)

Guia: [docs/COMO-TESTAR-MVP.md](docs/COMO-TESTAR-MVP.md)

## Documentação

- [Como testar / Fase 1](docs/COMO-TESTAR-MVP.md)
- [Proposta / GDD V2](docs/proposta-jogo-gdd-v2.md)
- [Skills instaladas](docs/skills-instaladas.md)

## Estrutura

```
autoload/     GameState + SceneRouter
assets/       sprites pixel art
scenes/
  main.tscn              menu Start Game
  exploration/village.tscn   Vila de Cinzas
  combat/battle.tscn         combate reativo
  ui/phase_complete.tscn     fim da Fase 1
scripts/      combate, exploração, UI, sprites
.agents/      skills Godot
```

## Repo

https://github.com/bruno-ab/dungeon-and-dices
