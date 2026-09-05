# Diálogo Visual Novel

## Como funciona

NPCs usam scripts JSON em `data/dialogue/`. A UI (`dialogue_box`) mostra:

- Retrato do falante
- Nome + texto com typewriter (E/Espaço pula)
- **Escolhas** ramificadas
- Escurecimento de fundo (estilo VN)

Autoload: `DialogueManager`

## Abrir (código)

```gdscript
DialogueManager.start("magus")
DialogueManager.start_linear("Otto", PackedStringArray(["…"]))
```

## NPCs com múltiplas interações

| NPC | Script | Interações |
|-----|--------|------------|
| Magus | `magus.json` | Intro → hub com lore/quest/recruta/dicas → ending |
| Mira | `mira.json` | Convite (sim/não/saber mais) → hub de companheira |
| Estalajadeira | `innkeeper.json` | Cura, boatos, conversa |
| Aldeão | `aldeao.json` | Direções, Magus, novidades |

Cada conversa pode mudar por **flags** (`heard_vasta_lore`, `mira_refused`…) e estado de quest.

## Condições (`if`)

`flag_true`, `flag_false`, `flags_true`, `flags_false`, `all_cleared`, `talk_count_lt`, `recruited_mira`, etc.

## Efeitos

`set_flag`, `mark_met_elder`, `recruit_mira`, `recruit_magus`, `heal_full`, `play_me`, `go_phase_complete`, `grant_sp`
