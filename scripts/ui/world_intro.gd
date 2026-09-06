extends Control

## Intro de mundo: StarlitSky + Mountains, fade e texto subindo.
## Pular: botão «Pular história», E / Espaço / Esc.

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
@onready var skip_btn: Button = %SkipBtn

var _skipped: bool = false
var _done: bool = false
var _active_tween: Tween


func _ready() -> void:
	AudioManager.play_bgm("Scene1")
	sky.texture = load("res://assets/sprites/rtp/Graphics/Parallaxes/StarlitSky.png") as Texture2D
	mountains.texture = load("res://assets/sprites/rtp/Graphics/Titles2/Mountains.png") as Texture2D
	lore.text = LORE_TEXT
	lore.modulate.a = 0.0
	fade.color = Color(0, 0, 0, 1)
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	skip_btn.visible = true
	skip_btn.pressed.connect(_skip)
	RtpUi.apply_button_styles(skip_btn)
	skip_btn.grab_focus()
	_run_sequence()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("interact") or event.is_action_pressed("ui_cancel"):
		_skip()
		get_viewport().set_input_as_handled()


func _kill_tween() -> void:
	if _active_tween and _active_tween.is_valid():
		_active_tween.kill()
	_active_tween = null


func _skip() -> void:
	if _skipped or _done:
		return
	_skipped = true
	AudioManager.sfx_ui_confirm()
	_kill_tween()
	_finish()


func _run_sequence() -> void:
	_active_tween = create_tween()
	_active_tween.tween_property(fade, "color:a", 0.0, 1.4)
	await _active_tween.finished
	if _skipped:
		return

	var view_h := get_viewport_rect().size.y
	lore.position.y = view_h * 0.58
	lore.modulate.a = 0.0
	_active_tween = create_tween()
	_active_tween.set_parallel(true)
	_active_tween.tween_property(lore, "modulate:a", 1.0, 1.2)
	_active_tween.tween_property(lore, "position:y", view_h * 0.10, 10.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	await get_tree().create_timer(7.5).timeout
	if _skipped:
		return

	_active_tween = create_tween()
	_active_tween.tween_property(lore, "modulate:a", 0.0, 2.0)
	await _active_tween.finished
	if _skipped:
		return

	_active_tween = create_tween()
	_active_tween.tween_property(fade, "color:a", 1.0, 1.2)
	await _active_tween.finished
	if _skipped:
		return
	_finish()


func _finish() -> void:
	if _done:
		return
	_done = true
	_kill_tween()
	SceneRouter.go_mylune()
