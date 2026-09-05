# Árvore de Skills

Fonte de verdade das regras: [`docs/classes.md`](classes.md).

## Abrir

- **Tab** ou **T** na vila (e fora da janela de reação no combate)
- Pause (Esc) → “Árvore de Skills”
- Após vitória → botão na tela de fim

## Classes e ramos

| Classe | Personagem | Dado | Ramos |
|--------|------------|------|-------|
| Guerreiro | Otto | d10 (1→2→3 nos Nv.5/10) | Núcleo · Vanguarda · Executor |
| Druida | Mira | d6 / d12 Urso / d8 Pantera | Núcleo · Restauração · Metamorfose |
| Mago | Magus | Nd4 elemental · 1d20 ritual | Núcleo · Elemental · Anulação |

Árvores de Mira/Magus só aparecem após recrutamento. Nós núcleo (Força Bruta / Forma Humana / Faísca) vêm gratuitos ao iniciar ou recrutar.

## Regras

- 1 SP no início da run; +1 SP por nível
- Pré-requisitos e Nv. mínimo por nó; capstones custam 2 SP
- Pool base por nível via `ClassRules`; skills adicionam `extra_dice`, janelas e efeitos
- Combate: crítico ~5%, máximo no d10 = stun, formas da druida, Power Attack/Defense/War Cry, Ritual d20

## Código

- `scripts/progression/class_rules.gd`
- `scripts/progression/skill_def.gd`
- `scripts/progression/skill_catalog.gd`
- `scenes/ui/skill_tree.tscn` (autoload `SkillTreeUI`)
