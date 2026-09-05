extends Area2D

## NPC / ponto de interação com diálogo ou ação.

@export var prompt_text: String = "E — Falar"
@export_enum("dialogue", "recruit", "heal", "battle", "elder", "complete") var mode: String = "dialogue"
@export var speaker_name: String = "Aldeão"
@export var dialogue_lines: PackedStringArray = PackedStringArray(["..."])

var _player_inside: bool = false
var _busy: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	monitoring = true


func _process(_delta: float) -> void:
	if not _player_inside or _busy:
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
		"heal":
			GameState.heal_full()
			GameState.log_message.emit("A estalagem restaurou seu HP.")
			_talk(speaker_name, dialogue_lines)
		"recruit":
			if GameState.recruited_mira:
				_talk("Mira", PackedStringArray(["Já estou com você. Vamos limpar a trilha."]))
			else:
				GameState.recruited_mira = true
				GameState.party_changed.emit()
				GameState.quest_updated.emit(GameState.quest_text())
				_talk("Mira", PackedStringArray([
					"Ouvi o Magus. Posso lutar ao seu lado.",
					"Meu dado é um d8 — mais ágil que forte.",
					"Mira entrou no grupo!",
				]))
		"battle":
			if GameState.phase1_trail_cleared:
				_talk("Trilha", PackedStringArray(["A trilha está calma por enquanto."]))
			else:
				SceneRouter.go_battle()
		"elder":
			_elder()
		"complete":
			if GameState.phase1_trail_cleared:
				SceneRouter.go_phase_complete()
			else:
				_talk(speaker_name, PackedStringArray(["Ainda há sombras na trilha a leste."]))
		_:
			_talk(speaker_name, dialogue_lines)


func _elder() -> void:
	var name := speaker_name if speaker_name != "" else "Magus"
	if GameState.phase1_trail_cleared:
		_talk(name, PackedStringArray([
			"Você afastou as sombras. A Vila de Cinzas respira de novo.",
			"Isso conclui a primeira fase da sua jornada.",
		]), func(): SceneRouter.go_phase_complete())
		return
	if not GameState.met_elder:
		GameState.mark_met_elder()
		_talk(name, PackedStringArray([
			"Forasteiro… bem-vindo à Vila de Cinzas.",
			"Sou Magus. Guardo o que resta de nossa magia antiga.",
			"Sombras tomaram a Trilha a leste. Ninguém volta inteiro.",
			"Recrute Mira perto do poço, se quiser companhia.",
			"Descanse na estalagem ao norte. Depois, limpe a trilha.",
		]))
	else:
		_talk(name, PackedStringArray([
			"Ainda esperamos notícias da Trilha Sombria.",
			GameState.quest_text(),
		]))


func _talk(speaker: String, lines: PackedStringArray, on_finished: Callable = Callable()) -> void:
	var box := get_tree().get_first_node_in_group("dialogue_box")
	if box == null:
		for line in lines:
			GameState.log_message.emit("%s: %s" % [speaker, line])
		if on_finished.is_valid():
			on_finished.call()
		return
	_busy = true
	box.show_dialogue(speaker, lines, func():
		_busy = false
		if on_finished.is_valid():
			on_finished.call()
	)
