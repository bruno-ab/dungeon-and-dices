# Áudio — Dado & Lâmina

## Estrutura

```
assets/audio/
  bgm/   # músicas (loop)
  bgs/   # ambiente
  me/    # fanfarras / vitória / derrota
  se/    # efeitos e UI
```

Fonte: RTP RPG Maker (copiado de `assets/sprites/rtp/Audio/`).

## Autoload

`AudioManager` (`autoload/audio_manager.gd`)

- Buses runtime: **Master** (−10 dB), **Music** (−8), **SFX** (−6), **UI** (−10)
- Pool de SFX/UI + crossfade de BGM
- `PROCESS_MODE_ALWAYS` (continua com diálogo pausado)
- BGM faz fade para −6 dB (não 0) para manter o volume geral baixo

## Mapa rápido

| Momento | Áudio |
|---------|--------|
| Menu | BGM Theme1 |
| Vila | BGM Town2 + BGS Wind |
| Mylune | BGM Field2 |
| Trilha | BGM Battle3 |
| Cemitério | BGM Battle5 + BGS Darkness |
| Vitória / Derrota | ME Victory1 / Gameover1 |
| Ataque / Magia / Reações | SE Slash, Magic, Parry, Evasion… |
| Passos | SE Move (cooldown) |
| Diálogo / UI | SE Book1, Decision, Cursor |

## Uso

```gdscript
AudioManager.bgm_village()
AudioManager.sfx_attack()
AudioManager.me_victory()
```
