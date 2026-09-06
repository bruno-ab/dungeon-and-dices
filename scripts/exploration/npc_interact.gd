extends Area2D

## NPC / ponto de interação — diálogos VN ou ações de exploração.

@export var prompt_text: String = "E — Falar"
@export_enum("vn", "dialogue", "recruit", "heal", "battle", "elder", "complete") var mode: String = "vn"
@export var speaker_name: String = "Aldeão"
@export var dialogue_id: String = "" ## JSON em data/dialogue/
@export var dialogue_lines: PackedStringArray = PackedStringArray(["..."])
@export var encounter_id: String = "trilha"

var _player_inside: bool = false
var _busy: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	monitoring = true
	if dialogue_id == "" and mode in ["vn", "elder", "recruit", "heal"]:
		match mode:
			"elder":
				dialogue_id = "magus"
			"recruit":
				dialogue_id = "mira"
			"heal":
				dialogue_id = "innkeeper"


func _process(_delta: float) -> void:
	if not _player_inside or _busy or DialogueManager.is_busy():
		return
	if Input.is_action_just_pressed("interact"):
		_activate()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_inside = true
		if body.has_method("show_prompt"):
			body.show_prompt(prompt_text)


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_inside = false
		if body.has_method("hide_prompt"):
			body.hide_prompt()


func _activate() -> void:
	match mode:
		"vn", "elder", "recruit", "heal":
			_start_vn()
		"battle":
			_start_battle()
		"complete":
			if GameState.all_encounters_cleared():
				SceneRouter.go_phase_complete()
			else:
				_talk(speaker_name, PackedStringArray(["Ainda há caminhos perigosos ao redor da vila."]))
		"dialogue":
			if dialogue_id != "":
				_start_vn()
			else:
				_talk(speaker_name, dialogue_lines)
		_:
			_talk(speaker_name, dialogue_lines)


func _start_vn() -> void:
	var id := dialogue_id
	if id == "":
		id = speaker_name.to_lower()
	_busy = true
	DialogueManager.start(id, func():
		_busy = false
	)


func _start_battle() -> void:
	var id := encounter_id if encounter_id != "" else "trilha"
	if id == "mylune" and GameState.cleared_mylune:
		_talk("Trilha", PackedStringArray(["Mylune está quieta. As serpentes sumiram."]))
		return
	if id == "trilha" and GameState.cleared_trilha:
		_talk("Trilha", PackedStringArray(["A trilha está calma por enquanto."]))
		return
	if id == "cemiterio" and GameState.cleared_cemiterio:
		_talk("Ruínas", PackedStringArray(["O golem jaz entre as sucatas."]))
		return
	if not GameState.met_elder and id != "mylune":
		_talk("?", PackedStringArray(["Fale com Magus na praça antes de partir."]))
		return
	var spawn := "combat" if id == "mylune" else "gate"
	SceneRouter.go_battle(id, spawn)


func _talk(speaker: String, lines: PackedStringArray, on_finished: Callable = Callable()) -> void:
	_busy = true
	DialogueManager.start_linear(speaker, lines, "", func():
		_busy = false
		if on_finished.is_valid():
			on_finished.call()
	)
