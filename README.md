# Dungeon and Dices — Dado & Lâmina

RPG de turnos 2D (Godot **4.7.2**) — combate reativo, Dice Engine e recrutamento dinâmico.

**Versão:** 0.3.0 · **MVP Fase 1** jogável

## Jogar agora

1. Abra no Godot 4.7.2  
2. **F5** → menu → **Start Game** (ou **Continuar** com save)  
3. Explore a **Vila de Cinzas** → norte entra na **Cripta dos Metais**

Guia: [docs/COMO-TESTAR-MVP.md](docs/COMO-TESTAR-MVP.md) · Changelog MVP: [docs/17-9-2026.md](docs/17-9-2026.md)

## Documentação

- [Como testar / Fase 1](docs/COMO-TESTAR-MVP.md)
- [Proposta / GDD V2](docs/proposta-jogo-gdd-v2.md)
- [Skills instaladas](docs/skills-instaladas.md)

## Estrutura

```
autoload/     GameState (save) + SceneRouter + áudio/diálogo
assets/       sprites pixel art
scenes/
  main.tscn                 menu Start / Continuar
  exploration/village.tscn  Vila de Cinzas
  exploration/dungeon.tscn  Cripta dos Metais (MVP dungeon)
  combat/battle.tscn        combate reativo
  ui/phase_complete.tscn    fim da Fase 1
scripts/      combate, exploração, UI, sprites
.agents/      skills Godot
```

## Controles

| Ação | Tecla |
|---|---|
| Mover | WASD / setas |
| Interagir | E / Espaço |
| Reagir | G Guard · H Dodge · J Counter · U Counterspell |
| Árvore de skills | Tab |
| Pause / salvar | Esc |
