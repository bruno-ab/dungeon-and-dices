# Como jogar — Dado & Lâmina (Godot 4.7)

## Abrir

1. Godot **4.7.2** → Import → pasta do projeto  
2. **F5** (`scenes/main.tscn`)

## Fluxo

```
Menu (Start Game)
  → Intro (lore)
  → Floresta de Mylune (mapa inicial)
       → Clareira das Serpentes (combate Mylune)
       → Trilha → Vila de Cinzas
            → Magus / Mira / Estalagem
            → Trilha Sombria / Cemitério
  → Magus encerra a fase após os 3 combates
```

## Classes

| Classe | Personagem | Dado | Destaque |
|--------|------------|------|----------|
| Guerreiro | Otto | d10 (pool Nv.5/10) | Aparo / Contra / Power Attack |
| Druida | Mira | d6 / d12 / d8 | Formas + cura / esquiva |
| Mago | Magus | Nd4 / Ritual d20 | Contra-feitiço |

Regras completas: `docs/classes.md`. Árvore: Tab.

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

## Diálogo (Visual Novel)

Ver `docs/DIALOGUE-VN.md`. Fale várias vezes com Magus, Mira, Estalajadeira e o Aldeão — há escolhas e ramos.
