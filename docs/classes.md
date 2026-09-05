# Sistema de Classes e Dados (Dice Engine)

## Visão Geral

O sistema de classes é estruturado em torno do **Dice Engine** (Motor de Dados de RPG de Mesa). Cada classe possui uma identidade distinta baseada em:

- categoria de dado utilizada (`d4`, `d6`, `d8`, `d10`, `d12` ou `d20`);
- comportamento desse dado (fixo, dinâmico ou acumulativo);
- Árvore de Habilidades (*Skill Tree*) própria;
- interação com as janelas de reação em tempo real: Esquiva, Aparo, Contra-Ataque e Contra-Feitiço.

## 1. Mecânicas Gerais do Dice Engine

### 1.1. Atribuição de Dados e Rolagens

#### Dado Característico

Cada classe inicia com uma categoria de dado base que rege a potência de suas ações, incluindo dano, cura, eficácia de buffs/debuffs e testes de efeito.

#### Crescimento do Pool de Dados

À medida que os personagens sobem de nível e progridem na *Skill Tree*, a quantidade de dados rolados simultaneamente aumenta.

Exemplo: `Nível 1 = 1d10` → `Nível 5 = 2d10` → `Nível 10 = 3d10`.

#### Aprimoramento de Dado (*Die Upgrade*)

Habilidades passivas e nós da *Skill Tree* podem elevar permanentemente a categoria do dado base de uma classe.

Exemplo: `d6` → `d8`.

### 1.2. Interação com Janelas de Reação

| Mecânica | Gatilho de reação | Efeito base |
| --- | --- | --- |
| **Esquiva (Dodge)** | Instante do impacto do ataque físico ou projétil. | Anula 100% do dano recebido. |
| **Aparo (Parry)** | Janela precisa imediatamente anterior ao golpe. | Reduz drasticamente o dano e gera postura ou recurso de classe. |
| **Contra-Ataque (Counter Attack)** | Aparo perfeito contra ataques corpo a corpo. | Dispara uma retaliação física imediata sem gastar o turno. |
| **Contra-Feitiço (Counterspell)** | Janela de carregamento ou conjuração de magias inimigas. | Interrompe o feitiço, podendo refletir dano ou silenciar o conjurador. |
| **Acerto-Crítico (Critical Hit)** | Todo ataque físico tem uma janela de 5% de oportunidade de causar o dobro do dano. |
## 2. Detalhamento das Classes Principais

### 2.1. Guerreiro (Lutador de Linha de Frente)

- **Dado característico base:** `d10`.
- **Especialidade:** dano físico consistente, alto HP, controle de postura e Aparo/Contra-Ataque.
- **Comportamento de dado:** rola `d10` para determinar o dano direto de suas habilidades de corte e contusão.
- **Efeito crítico de dado:** tirar o valor máximo no `d10` (por exemplo, 10) aplica o status Atordoamento (*Stun*) ou Sangramento Severo ao alvo.
- **Progressão de pool:** começa com `1d10`, evolui para `2d10` no Nível 5 e `3d10` no Nível 10.
- **Sinergia com reações:** é especialista em Parry e Contra-Ataque. Executar um Aparo perfeito estende a janela do próximo Contra-Ataque e concede um bônus de `+2` no próximo resultado do `d10`.
### 2.1.2 Progressão do Guerreiro
    1 - skill: passiva (Força bruta) - Ao rolar 1 ou 2 no dano o guerreiro rola o dado novamente.
    2 - skill: passiva (Defesa Sólida) - Ao realizar um aparo bem sucedido recupera 1 dado de PV
    3 - skill: passiva (Crítico Brutal) - Ao realizar um ataque crítico ganha seus aliados ganham 1 dado de bonus para acertar até o fim do turno
    4 - skill passiva: permite equipar 2 armas
    5 - Recebe +1 dado / skill: Power Attack = Guerreiro pode sacrificar 1 dado de acerto para aumentar 1 dado de dano 
    6 - skill: Power Defense = Pode sacrificar 1 dado de acerto para receber esse bonus na armadura até o inicio do seu proximo turno
    7 - skill passiva: Ao atingir 0 pv no combate recupera 1 dado de PV (uso de 1x por combate)
    8 - skill Ativa: War Cry Sacrifica seus dados de ataque no turno para aumentar a defesa dos aliados
    9 - skill: passiva Parry agora permite contra atacar.
    10 - A primeira rolagem do dado de de acerto e de dano do guerreiro é sempre máximo.
#### Ramos da Skill Tree

- **Ramo Vanguarda:** aumenta a vida, reduz o dano passivamente e amplia as janelas de Aparo.
- **Ramo Executor:** aumenta o pool de `d10` e aplica acertos críticos devastadores.

### 2.2. Druida (Conjurador Dinâmico / Transmorfo)

- **Dado característico base:** `d6`, modificável por habilidades e formas.
- **Especialidade:** flexibilidade tática, curas periódicas, suporte e adaptação a diferentes papéis no combate.
- **Comportamento de dado:** começa na forma humana usando `d6` para feitiços de regeneração e controle da natureza. Ao utilizar habilidades de Morfismo (Transmorfomação), seu dado característico se altera em tempo real.
- **Progressão de pool:** aumenta o número de dados conforme o nível. Exemplo: `1d6/1d12/1d8` → `2d6/2d12/2d8`.
- **Sinergia com reações:** é especialista em Esquiva na Forma de Pantera e Aparo com Absorção na Forma de Urso.

#### Formas e Dados Característicos

| Forma | Papel | Dado | Foco |
| --- | --- | --- | --- |
| **Humana (Base)** | Cura e suporte | `d6` | Feitiços de regeneração e controle da natureza. |
| **Urso (Tanque/Resistência)** | Absorção de dano | `d12` | Absorção de dano, provocações e atordoamentos. |
| **Pantera (Agilidade/Dano Rápido)** | Dano e mobilidade | `d8` | Taxa crítica, rolagem rápida e mobilidade de esquiva. |

#### Ramos da Skill Tree

- **Ramo Restauração:** aprimora a eficácia do `d6` para curas e escudos de proteção de grupo.
- **Ramo Metamorfose:** desbloqueia novas formas animais e permite manter bônus de dados acumulados ao alternar de forma.

### 2.3. Mago Arcano (Conjurador de Alta Explosão)

- **Dado característico base:** `d4` ou `d20`, dependendo do tipo de feitiço.
- **Especialidade:** dano elemental em área (AoE), manipulação de feitiços inimigos e controle do campo de batalha.
- **Sinergia com reações:** é especialista em Contra-Feitiço (*Counterspell*). Ao identificar um feitiço inimigo sendo carregado, acionar o Counterspell no tempo correto cancela a magia e converte a energia arcana em Mana ou em um feitiço de retaliação imediata.

#### Comportamento de Dado

- **Feitiços Elementais Avançados:** utiliza múltiplos `d4` (por exemplo, `3d4` no Nível 1 → `6d4` no Nível 8) para criar um dano base consistente e estável.
- **Ritual de Alto Risco:** utiliza `1d20` para testes de feitiços de destruição em massa. Rolagens altas desencadeiam explosões de dano catastróficas.

#### Ramos da Skill Tree

- **Ramo Elemental:** amplia a quantidade de dados `d4` rolados e adiciona efeitos de queimadura, congelamento ou choque.
- **Ramo Anulação:** maximiza as janelas de tempo do Counterspell e concede a capacidade de refletir magias de volta aos conjuradores.

## 3. Estrutura da Árvore de Habilidades (*Skill Tree*)

Cada classe possui uma interface de árvore de habilidades dedicada, ramificada em caminhos de especialização:

| Tipo de nó | Função |
| --- | --- |
| **Nós de Atributo e Pool (Dados)** | Aumentam a quantidade de dados rolados por habilidade (por exemplo, `+1d10`) ou promovem a categoria do dado. |
| **Nós de Habilidades Ativas** | Desbloqueiam novas técnicas de combate, transmutações e magias de reação. |
| **Nós de Ampliação de Janela (Timing Boost)** | Aumentam o tempo disponível, em milissegundos, para executar Esquiva, Aparo e Counterspell com sucesso. |
| **Nós Mestres (Capstones)** | Habilidades definitivas no final da árvore que alteram radicalmente as regras de combate da classe. |
