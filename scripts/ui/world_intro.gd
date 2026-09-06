extends Control

## Intro de mundo: StarlitSky + Mountains, fade e texto subindo.

const LORE_TEXT := """No Império de Vasta, o Arcano é monopólio da Sentinela da Providência.

Quem nasce marcado é confiscado.
A liturgia da Rainha ecoa nas praças e nas forcas:

“Sagrados os que floresceram sob meu toque;
em cinzas os que ousam colher o que não plantaram.”

Nas fronteiras, a Vila de Cinzas abriga desertados,
mercadores mudos e magos exilados.

Otto chega com a Marreta e uma dívida de sangue.
As trilhas ao redor sussurram — Mylune, a Trilha Sombria,
o Cemitério dos Metais.

O dado ainda não rolou.
A lâmina ainda não escolheu."""

@onready var sky: TextureRect = %Sky
@onready var mountains: TextureRect = %Mountains
@onready var fade: ColorRect = %Fade
@onready var lore: RichTextLabel = %LoreText
@onready var skip_l: Label = %SkipLabel

var _busy: bool = false
var _skipped: bool = false
var _done: bool = false


func _ready() -> void:
	AudioManager.play_bgm("Scene1")
	sky.texture = load("res://assets/sprites/rtp/Graphics/Parallaxes/StarlitSky.png") as Texture2D
	mountains.texture = load("res://assets/sprites/rtp/Graphics/Titles2/Mountains.png") as Texture2D
	lore.text = LORE_TEXT
	lore.modulate.a = 0.0
	fade.color = Color(0, 0, 0, 1)
	skip_l.visible = true
	_run_sequence()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("interact") or event.is_action_pressed("ui_cancel"):
		_skip()
		get_viewport().set_input_as_handled()


func _skip() -> void:
	if _skipped:
		return
	_skipped = true
	AudioManager.sfx_ui_confirm()
	_finish()


func _run_sequence() -> void:
	_busy = true
	## Fade in
	var tw := create_tween()
	tw.tween_property(fade, "color:a", 0.0, 1.4)
	await tw.finished
	if _skipped:
		return
	## Texto sobe e some
	var view_h := get_viewport_rect().size.y
	lore.position.y = view_h * 0.58
	lore.modulate.a = 0.0
	var scroll := create_tween()
	scroll.set_parallel(true)
	scroll.tween_property(lore, "modulate:a", 1.0, 1.2)
	scroll.tween_property(lore, "position:y", view_h * 0.10, 10.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	await get_tree().create_timer(7.5).timeout
	if _skipped:
		return
	var fade_text := create_tween()
	fade_text.tween_property(lore, "modulate:a", 0.0, 2.0)
	await fade_text.finished
	if _skipped:
		return
	## Fade out
	var out := create_tween()
	out.tween_property(fade, "color:a", 1.0, 1.2)
	await out.finished
	if _skipped:
		return
	_finish()


func _finish() -> void:
	if _done:
		return
	_done = true
	_busy = false
	SceneRouter.go_mylune()
