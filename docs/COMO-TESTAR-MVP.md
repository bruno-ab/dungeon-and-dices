# Como jogar — Dado & Lâmina (Godot 4.7)

## Abrir

1. Godot **4.7.2** → Import → pasta do projeto  
2. **F5** (`scenes/main.tscn`)

## Fluxo

```
Menu (Start Game)
  → Vila de Cinzas (Mittelerd / lore Pot)
       → Magus (missão + recruta Mago)
       → Mira (recruta Druida)
       → Estalagem (cura)
       → Mylune (oeste) — Guard/Dodge/Counter
       → Trilha Sombria (leste) — Counterspell
       → Cemitério dos Metais (norte) — combate misto
  → Magus encerra a fase após os 3 combates
```

## Classes

| Classe | Personagem | Dado | Destaque |
|--------|------------|------|----------|
| Guerreiro | Otto | d10 | Lâmina Severa, Guard |
| Druida | Mira | d6 | Magia / Semente |
| Mago | Magus | d8 / janela d4 | Contra-feitiço |

## Controles (combate)

| Ação | Tecla / UI |
|------|------------|
| Habilidade | botão central |
| Magia / Item | botões |
| Guardar | **G** ou botão (turno ou reação) |
| Esquivar | **H** |
| Contra-atacar | **J** |
| Contra-feitiço | **U** |
| Timing genérico | **Espaço** |
| Árvore de Skills | **Tab** / **T** |

## Lore

Ver `docs/lore-mittelerd.md` (adaptado do projeto Pot).

## Áudio

Ver `docs/AUDIO.md`. BGM muda por cena; combate tem SFX de ataque, magia e reações.

## Skills

Ver `docs/SKILL-TREE.md`. Gaste SP na árvore (não mais nas teclas 1/2).
