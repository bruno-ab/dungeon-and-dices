extends CanvasLayer

## UI Visual Novel: retrato, typewriter, escolhas.

signal closed

@onready var dim: ColorRect = $Dim
@onready var portrait: TextureRect = $Portrait
@onready var name_l: Label = $Panel/Margin/VBox/NameRow/Speaker
@onready var body_l: RichTextLabel = $Panel/Margin/VBox/Body
@onready var continue_btn: Button = $Panel/Margin/VBox/ContinueBtn
@onready var choices_box: VBoxContainer = $Panel/Margin/VBox/Choices

var _typing: bool = false
var _full_text: String = ""
var _tween: Tween
var _has_choices: bool = false


func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	continue_btn.pressed.connect(_on_continue_pressed)
	add_to_group("dialogue_box")


## Compat legado (linhas simples)
func show_dialogue(speaker: String, lines: PackedStringArray, on_finished: Callable = Callable()) -> void:
	DialogueManager.start_linear(speaker, lines, "", on_finished)


func show_vn_line(speaker: String, text: String, portrait_id: String, choices: Array) -> void:
	visible = true
	get_tree().paused = true
	name_l.text = speaker
	_full_text = text
	_has_choices = not choices.is_empty()
	_set_portrait(portrait_id if portrait_id != "" else _guess_portrait(speaker))
	_clear_choices()
	continue_btn.visible = not _has_choices
	continue_btn.text = "Continuar (E / Espaço)"
	AudioManager.sfx_dialogue()
	_start_typewriter(text)
	if _has_choices:
		# escolhas aparecem após typewriter ou skip
		pass
	else:
		continue_btn.grab_focus()


func close_vn() -> void:
	_kill_tween()
	_clear_choices()
	visible = false
	get_tree().paused = false
	closed.emit()


func _guess_portrait(speaker: String) -> String:
	match speaker:
		"Magus":
			return "magus"
		"Mira":
			return "mira"
		"Otto", "Gildesh":
			return "otto"
		"Estalajadeira":
			return "innkeeper"
		"Aldeão", "Aldeao":
			return "aldeao"
		_:
			return "otto"


func _set_portrait(id: String) -> void:
	var tex := SpriteCatalog.portrait(id)
	portrait.texture = tex
	portrait.visible = tex != null


func _start_typewriter(text: String) -> void:
	_kill_tween()
	body_l.text = text
	body_l.visible_ratio = 0.0
	_typing = true
	_tween = create_tween()
	_tween.tween_property(body_l, "visible_ratio", 1.0, clampf(text.length() * 0.018, 0.25, 1.8))
	_tween.finished.connect(func():
		_typing = false
		if _has_choices:
			_show_choice_buttons()
	)


func _kill_tween() -> void:
	if _tween and _tween.is_valid():
		_tween.kill()
	_tween = null
	_typing = false


func _skip_or_advance() -> void:
	if _typing:
		_kill_tween()
		body_l.visible_ratio = 1.0
		if _has_choices:
			_show_choice_buttons()
		return
	if _has_choices:
		return
	AudioManager.sfx_ui_cursor()
	DialogueManager.continue_line()


func _on_continue_pressed() -> void:
	_skip_or_advance()


func _show_choice_buttons() -> void:
	_clear_choices()
	continue_btn.visible = false
	var node_choices: Array = []
	## pega do manager via último signal — melhor ler do manager state
	## Re-filter from current node through a helper
	node_choices = _current_choices()
	for i in node_choices.size():
		var c: Dictionary = node_choices[i]
		var b := Button.new()
		b.text = str(c.get("text", "…"))
		b.custom_minimum_size = Vector2(0, 36)
		var idx := i
		b.pressed.connect(func():
			AudioManager.sfx_ui_confirm()
			DialogueManager.select_choice(idx)
		)
		choices_box.add_child(b)
		if i == 0:
			b.grab_focus()


func _current_choices() -> Array:
	## Acessa estado interno via método público auxiliar
	return DialogueManager.get_current_choices()


func _clear_choices() -> void:
	for c in choices_box.get_children():
		c.queue_free()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
		if _has_choices and not _typing:
			return
		_skip_or_advance()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel") and _has_choices and not _typing:
		## não fecha VN no meio de escolha
		get_viewport().set_input_as_handled()
