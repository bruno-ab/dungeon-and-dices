# Dungeon and Dices

RPG de turnos 2D (Godot **4.7.2**) — combate reativo, Dice Engine e recrutamento dinâmico.

## Documentação

- [Como testar o MVP](docs/COMO-TESTAR-MVP.md)
- [Proposta / GDD V2](docs/proposta-jogo-gdd-v2.md)
- [Skills instaladas](docs/skills-instaladas.md)

## Rodar

1. Abra a pasta no **Godot 4.7.2**
2. Play (`F5`) → `scenes/main.tscn`

## Estrutura

```
autoload/     GameState + SceneRouter
scenes/       main, hub, battle
scripts/      combate (dados, turnos, reação) + exploração
docs/         GDD e guia de teste
.agents/      skills Godot para o agente
```

## Repo

https://github.com/bruno-ab/dungeon-and-dices
