# Como jogar — Dado & Lâmina (Godot 4.7) · MVP 0.3.0

## Abrir

1. Godot **4.7.2** → Import → pasta do projeto  
2. **F5** (`scenes/main.tscn`)

## Fluxo

```
Menu (Start Game / Continuar com save)
  → Vila de Cinzas (Mittelerd / lore Pot)
       → Magus (missão + recruta Mago)
       → Mira (recrute Druida)
       → Estalagem (cura)
       → Mylune (oeste) — Guard/Dodge/Counter
       → Trilha Sombria (leste) — Counterspell
       → Cripta dos Metais (norte) — dungeon
            → Ante-sala (Autômato) → Câmara do Golem (boss)
  → Magus encerra a fase após limpar os 3 caminhos
```

## Classes

| Classe | Personagem | Dado | Destaque |
|--------|------------|------|----------|
| Guerreiro | Otto | d10 | Lâmina Severa, Guard |
| Druida | Mira | d6 / d12 urso / d8 pantera | botão **Forma** |
| Mago | Magus | d8 | Contra-feitiço + reflexo d4 |

## Controles (combate)

| Ação | Tecla / UI |
|------|------------|
| Habilidade | botão central |
| Magia / Item / Forma | botões |
| Guardar | **G** ou botão (turno ou reação) |
| Esquivar | **H** |
| Contra-atacar | **J** |
| Contra-feitiço | **U** |
| Timing genérico | **Espaço** (também no telegraph) |
| Árvore de Skills | **Tab** / **T** |
| Pause / salvar | **Esc** |

## Save

- Slot único: `user://dado_lamina_slot0.json`
- Autosave: vitória, pause, entrar/sair da cripta, menu

## Lore / áudio / skills / diálogo

- `docs/lore-mittelerd.md`
- `docs/AUDIO.md`
- `docs/SKILL-TREE.md`
- `docs/DIALOGUE-VN.md`
- Changelog MVP: `docs/17-9-2026.md`
