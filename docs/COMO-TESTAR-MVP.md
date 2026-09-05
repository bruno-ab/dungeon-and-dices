# Como jogar a Fase 1 (Godot 4.7.2)

## Abrir

1. Godot **4.7.2** → Import → pasta do projeto
2. **F5** (cena `scenes/main.tscn`)

## Fluxo

```
Menu (Start Game)
   → Vila de Cinzas
      → Ancião (missão)
      → Estalagem (cura)
      → Mira (recruta, opcional)
      → Trilha Sombria (combate reativo)
   → Volta à vila
   → Ancião (encerra Fase 1)
```

## Controles

| Onde | Teclas |
|---|---|
| Menu | Enter / clique em **Start Game** |
| Vila | **WASD** andar · **E** falar |
| Combate | botões de ação · **Espaço/J/K** reagir |
| Skills | **1** Parry maior · **2** +1 dado |
| Pause | **Esc** |

## Objetivo da Fase 1

1. Falar com o **Ancião** na praça  
2. (Opcional) Recrutar **Mira** no poço  
3. Entrar na **Trilha Sombria** e vencer o combate  
4. Voltar e falar com o Ancião → tela de conclusão  

## Sistemas ativos

- Exploração top-down (`CharacterBody2D` + colisão com prédios)
- Diálogos (UI pausa a árvore)
- Dice Engine + turnos + Dodge/Parry/Perfect
- Progressão XP / skill points
- Recrutamento dinâmico
