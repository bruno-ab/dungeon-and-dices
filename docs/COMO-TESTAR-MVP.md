# Como testar o MVP (Godot 4.7.2)

## Abrir o projeto

1. Instale **Godot 4.7.2** (Standard ou .NET — este MVP é GDScript puro).
2. Em Godot: **Import** → selecione a pasta `F:\projetos\dungeon-and-dices` (arquivo `project.godot`).
3. Pressione **F5** (Play). A cena principal é `scenes/main.tscn`.

## Loop de gameplay do MVP

```
Menu → Hub (explorar) → Recrutar / Curar / Combate → Batalha → Hub de novo
```

### Hub

| Zona | Cor | Ação (E) |
|---|---|---|
| Fogueira | laranja | Cura HP total |
| Mira | roxo | Recruta aliada (entra na próxima batalha) |
| Trilha Sombria | vermelho | Inicia combate |

**Controles hub:** WASD mover · E interagir · Esc abre dica de skills · **1** amplia Parry · **2** +1 dado

### Combate

1. Turno do herói (e Mira, se recrutada): botões **Atacar** / **Preparar** / **Fugir**.
2. Ataque rola o **Dice Engine** (`Nd10` do Guerreiro) e aplica dano.
3. No turno inimigo aparece a **barra de reação**:
   - pressione **Espaço / J / K**
   - **cedo** ≈ Parry / Perfect Parry (contra-ataque)
   - **mais tarde** ≈ Dodge (0 dano)
   - fora da janela = MISS (dano cheio)
4. Vitória: +15 XP (sobe de nível a cada 20 XP, ganha skill point).
5. Volte ao hub e continue o loop.

## O que este MVP valida

- Exploração top-down + triggers
- Turnos com fila por Speed
- Dados por classe / pool (`GameState.dice_count`)
- Dodge / Parry / Perfect Parry
- Recrutamento dinâmico (Mira)
- Progressão curta (XP → SP → melhorar Parry ou dados)

## Ainda não incluso (pós-MVP)

- Pixel art / animação / shaders cinematográficos
- Counterspell
- Skill tree visual completa
- Mapa com rotas que bloqueiam recrutamento
- Save em disco (progresso só na sessão)
