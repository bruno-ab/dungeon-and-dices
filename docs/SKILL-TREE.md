# Árvore de Skills

## Abrir

- **Tab** ou **T** na vila (e fora da janela de reação no combate)
- Pause (Esc) → “Árvore de Skills”
- Após vitória → botão na tela de fim

## Classes (7 nós cada)

| Classe | Personagem | Destaques |
|--------|------------|-----------|
| Guerreiro | Otto | Parry largo, +dados, contra brutal, Marreta |
| Druida | Mira | Esquiva, seiva, GELO×2, Florescer |
| Mago | Magus | Contra-feitiço largo, FOGO×2, Espelho |

Árvores de Mira/Magus só aparecem após recrutamento.

## Regras

- 1 SP no início da run; +1 SP por nível
- Pré-requisitos por tier; nós finais custam 2 SP
- Efeitos aplicados em `GameState.apply_combatant_skills` e janelas de reação

## Código

- `scripts/progression/skill_def.gd`
- `scripts/progression/skill_catalog.gd`
- `scenes/ui/skill_tree.tscn` (autoload `SkillTreeUI`)
