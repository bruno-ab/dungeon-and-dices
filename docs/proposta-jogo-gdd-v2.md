# Dungeon and Dices — Documento de Concepção do Jogo (GDD V2)

**Título de trabalho:** Dungeon and Dices  
**Gênero:** RPG de turnos 2D (Pixel Art HD)  
**Engine alvo:** Godot 4.x  
**Versão do documento:** 2.0  
**Status:** Concepção / pré-protótipo  

---

## 1. Visão Geral

RPG de turnos em **2D Pixel Art** que combina:

| Inspiração | O que entra no jogo |
|---|---|
| **Final Fantasy** (clássico) | Estrutura narrativa em capítulos, party, magias e turnos claros |
| **Clair Obscur: Expedition 33** | Estética melancólica/sóbrica + combate reativo (timing windows) |
| **Valkyrie Profile** | Dinamismo de combate e exploração com sensação de “peso” nas ações |

### Fantasia central do jogador

> “Eu comando um grupo de aventureiros em batalhas de turnos — mas cada golpe, defesa e feitiço exige reflexo e leitura do inimigo. Cada classe joga com o seu dado, como num RPG de mesa vivo.”

### Mecânicas centrais (4 pilares)

1. **Dice Engine** — motor de dados estilo RPG de mesa (d4–d20 por classe + pool por nível)  
2. **Turnos reativos** — janelas de Dodge / Parry / Counter / Counterspell em tempo real  
3. **Skill Tree** — progressão ramificada por classe (habilidades, dados, janelas de reação)  
4. **Recrutamento dinâmico** — aliados jogáveis dependem de escolhas narrativas e rotas no mapa  

---

## 2. Pilares Mecânicos e Direção de Arte

### 2.1 Estética e atmosfera

- **Pixel Art 2D HD:** personagens com animações fluidas; cenários detalhados (não “tile flat” genérico).  
- **Iluminação e tom:** iluminação 2D dinâmica + shaders modernos; paleta sóbria, melancólica (neblina, contraste alto, sombras longas — referência Clair Obscur).  
- **Batalha cinematográfica:** câmeras/ângulos dinâmicos em técnicas e feitiços (zoom, pan, foco no conjurador / no impacto).  

### 2.2 Loop de jogo (alto nível)

```
Exploração de mapa → Evento / Encontro
        ↓
  Combate por turnos + reações RT
        ↓
  Loot / XP / dados / skill points
        ↓
  Escolhas → recrutamento / rotas bloqueadas
        ↓
  Volta à exploração / próximo arco
```

### 2.3 Combate: turnos reativos

O combate é **por turnos**, mas o jogador permanece engajado em **janelas de tempo real** de ataque e defesa.

| Mecânica | Gatilho (Timing Window) | Efeito / Resultado |
|---|---|---|
| **Esquiva (Dodge)** | Pressionar no momento do impacto | Evita 100% do dano de ataques diretos e projéteis |
| **Aparo (Parry)** | Janela curta e precisa antes do golpe conectar | Reduz dano drasticamente e gera postura/recurso |
| **Contra-ataque (Counter)** | Parry perfeito em golpe corpo a corpo | Retaliação imediata **sem consumir** o turno do personagem |
| **Contra-feitiço (Counterspell)** | Janela de conjuração inimiga | Interrompe o feitiço; pode refletir dano ou silenciar |

**Notas de design:**

- Janelas devem ser **justas e legíveis** (telegraph visual + áudio).  
- Falhar não deve parecer “RNG injusto”; acertar deve parecer maestria.  
- Skill Tree pode **alargar** janelas de Parry/Dodge ou **aumentar** reward de Counter.  
- Inimigos elite/boss usam falsos telegraph e multi-hit para elevar skill ceiling.  

---

## 3. Sistema de Dados (Dice Engine)

Cada classe possui um **dado característico** (d4, d6, d8, d10, d12, d20) usado em dano, acertos e efeitos.

### 3.1 Exemplos de classes e comportamento

| Classe | Dado base | Comportamento |
|---|---|---|
| **Guerreiro** | **d10** | Dano, chance de atordoamento, bônus de investida |
| **Druida** | **d6** (dinâmico) | Muda com formas: Urso → d12; Pantera → d8 |

> Classes adicionais (Mago, Ladino, Clerigo, etc.) devem seguir a mesma regra: **identidade = dado + fantasia de mesa**.

### 3.2 Progressão do pool de dados

- Ao subir de nível, a classe ganha **dados extras do tipo característico**.  
  - Ex.: Guerreiro — `1d10` (Nv1) → `2d10` (Nv5) → `3d10` (Nv10).  
- Aplicação dos dados:
  - potência numérica (dano/cura);
  - escalonamento de bônus/debuffs;
  - sucesso em testes de efeito secundário (stun, bleed, silence…).  

### 3.3 Regras sugeridas (para implementação)

- Separar **roll de acerto** vs **roll de potência** quando fizer sentido (evita “tudo ou nada” chato).  
- Mostrar dados na UI de batalha (transparência tipo mesa).  
- Critical / fumble raros e espetaculares (não frustrantes).  
- Formas do Druida: troca de dado deve ser **imediata e legível** (ícone + SFX).  

---

## 4. Progressão e Narrativa Dinâmica

### 4.1 Skill Tree

- Cada classe tem árvore própria com ramificações estratégicas.  
- Desbloqueia:
  - habilidades ativas;
  - passivas de combate;
  - melhorias no **pool de dados**;
  - aprimoramento de **janelas de reação** (ex.: Parry mais largo).  

**Diretriz:** evitar “tree só de +1% dano”. Cada nó deve mudar *como* se joga.

### 4.2 Recrutamento dinâmico

- Personagens jogáveis dependem de **escolhas** e **rotas de mapa**.  
- Eventos de história podem integrar ou **bloquear** aliados.  
- Exploração estilo Valkyrie Profile: atalhos, áreas opcionais, “você chegou tarde / cedo demais”.  

**Implicação de produção:** party não é fixa; saves e balanço precisam considerar composições variáveis.

---

## 5. Escopo de Conteúdo (MVP sugerido)

### MVP (vertical slice jogável)

1. 1 região explorável + 1 dungeon curta  
2. 2–3 classes (ex.: Guerreiro, Druida + 1 suporte)  
3. Combate com Dodge/Parry funcionais (Counter e Counterspell em v1.1 ok)  
4. Dice Engine básico (pool por nível)  
5. Skill Tree mínima (1 ramo por classe, ~6–8 nós)  
6. 1 evento de recrutamento com 2 outcomes  
7. Direção de arte: 1 tileset + 2 inimigos + 1 boss + UI de batalha  

### Pós-MVP

- Counterspell polido, boss patterns avançados  
- Mais classes e dados  
- Sistema de quests / diálogos ramificados  
- Inventário + crafting leve  
- Mais rotas e recrutamentos  
- Apresentação cinematográfica de câmera em skills  

---

## 6. Sistemas Godot (mapeamento técnico)

| Sistema do jogo | Skills / foco Godot no repo |
|---|---|
| Arquitetura geral | `godot-master`, `godot-development`, `godot-project-templates`, `godot-nodes-scenes` |
| Combate por turnos | `godot-turn-system`, `godot-ability-system`, `godot-rpg-stats` |
| Reações RT / input frames | `godot-2d-animation`, `godot-animation`, `godot-camera-systems` |
| Exploração 2D | `godot-2d-movement`, `godot-genre-open-world` (áreas semi-abertas) |
| Diálogo / narrativa | `godot-dialogue-system`, `godot-quest-system`, `godot-genre-visual-novel` |
| Inventário / loot | `godot-inventory-system` |
| UI de batalha / menus | `godot-ui`, `godot-ui-control` |
| Look melancólico / FX | `godot-shaders` |
| Performance | `godot-optimization`, `godot-gdscript-patterns` |

> **Nota:** `godot-asset-generator` (jwynia) não está mais disponível no repositório fonte. Alternativas futuras: pipeline próprio de assets ou skills de assets (ex. SpriteCook).

---

## 7. Prompt de Contexto (para agentes / implementação)

```text
[CONTEXTO DE PROMPT]
Objetivo: Criar sistemas / GDD detalhado / código Godot 4 para um RPG 2D Pixel Art.
Projeto: Dungeon and Dices
Inspirações: Final Fantasy (narrativa/turnos) + Clair Obscur (estética melancólica e combate reativo) + Valkyrie Profile (dinamismo e exploração).
Mecânicas Principais:
1. Turnos com reações em tempo real (Esquiva, Parry, Counter Attack, Counterspell).
2. Dice Engine: cada classe possui um dado próprio (Guerreiro = d10, Druida = d6 mutável) e ganha mais dados ao subir de nível.
3. Skill Tree: árvore de habilidades para progressão de classes (ativas, passivas, pool de dados, janelas de reação).
4. Recrutamento Dinâmico: personagens jogáveis obtidos por eventos de história e decisões de navegação no mapa.
Direção de arte: Pixel Art 2D HD, iluminação dinâmica, tom sóbrio, câmeras cinematográficas em batalha.
```

---

## 8. Riscos e Decisões em Aberto

| Risco | Mitigação |
|---|---|
| Timing windows injustas em plataformas diferentes | Input buffering + calibração por dificuldade + telegraphs claros |
| Dice Engine “RNG frustrante” | Separar acerto/potência; pity leve; feedback visual forte |
| Escopo de recrutamento explode o conteúdo | MVP com 1 ramo binário; documentar “personagens fantasma” |
| Pixel Art HD + shaders caros | Budget de draw calls; atlases; perfil com skill de optimization |
| Nome / IP vibe vs. originalidade | Universo próprio; referências só como “feeling”, não como cópia |

### Decisões pendentes

- [ ] Nome definitivo do jogo e do mundo  
- [ ] Tom narrativo (tragédia esperançosa? fatalismo? humor seco?)  
- [ ] Tamanho da party em batalha (3 vs 4)  
- [ ] Controles: teclado/gamepad first  
- [ ] Godot 4.3 vs 4.4+ como versão mínima  

---

## 9. Próximos Passos

1. Congelar MVP vertical slice (seção 5).  
2. Criar projeto Godot 4 com estrutura de pastas (`scenes/`, `scripts/`, `resources/`, `assets/`).  
3. Prototipar **só** combate: turno + Dodge/Parry + 1 dado (Guerreiro d10).  
4. Prototipar exploração mínima + 1 evento de recrutamento.  
5. Expandir Dice Engine e Skill Tree quando o feeling de combate estiver certo.  

---

*Documento gerado a partir da concepção V2 do time. Atualizar este arquivo conforme o protótipo validar (ou invalidar) hipóteses.*
