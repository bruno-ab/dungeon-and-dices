extends Area2D

## NPC / ponto de interação com diálogo ou ação.

@export var prompt_text: String = "E — Falar"
@export_enum("dialogue", "recruit", "recruit_magus", "heal", "battle", "elder", "complete") var mode: String = "dialogue"
@export var speaker_name: String = "Aldeão"
@export var dialogue_lines: PackedStringArray = PackedStringArray(["..."])
@export var encounter_id: String = "trilha"

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
				_talk("Mira", PackedStringArray(["Já estou com você. Os dados da terra respondem."]))
			else:
				GameState.recruited_mira = true
				GameState.party_changed.emit()
				GameState.quest_updated.emit(GameState.quest_text())
				_talk("Mira", PackedStringArray([
					"Ouvi Magus. Posso lutar ao seu lado.",
					"Sou druida — meu dado é d6. Forma e cura clandestina.",
					"Mira entrou no grupo! (classe Druida)",
				]))
		"recruit_magus":
			_recruit_magus()
		"battle":
			_start_battle()
		"elder":
			_elder()
		"complete":
			if GameState.all_encounters_cleared():
				SceneRouter.go_phase_complete()
			else:
				_talk(speaker_name, PackedStringArray(["Ainda há caminhos perigosos ao redor da vila."]))
		_:
			_talk(speaker_name, dialogue_lines)


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
	if not GameState.met_elder:
		_talk("?", PackedStringArray(["Fale com Magus na praça antes de partir."]))
		return
	SceneRouter.go_battle(id)


func _recruit_magus() -> void:
	if GameState.recruited_magus:
		_talk("Magus", PackedStringArray(["Estou no grupo. Meu Contra-feitiço é d4 — timing curto."]))
		return
	if not GameState.met_elder:
		_elder()
		return
	GameState.recruited_magus = true
	GameState.party_changed.emit()
	GameState.quest_updated.emit(GameState.quest_text())
	_talk("Magus", PackedStringArray([
		"Levarei o Arcano à batalha — em silêncio, longe dos olhos de Vasta.",
		"Classe Mago: Magia e Contra-feitiço. Dados d8 / janela d4.",
		"Magus entrou no grupo!",
	]))


func _elder() -> void:
	var name := speaker_name if speaker_name != "" else "Magus"
	if GameState.all_encounters_cleared():
		_talk(name, PackedStringArray([
			"Mylune, a Trilha e o Cemitério… três feridas fechadas.",
			"A Rainha disse: em cinzas os que colhem o que não plantaram.",
			"Vocês plantaram esperança. Isso conclui esta fase.",
		]), func(): SceneRouter.go_phase_complete())
		return
	if not GameState.met_elder:
		GameState.mark_met_elder()
		_talk(name, PackedStringArray([
			"Forasteiro… bem-vindo à Vila de Cinzas, na fronteira de Vasta.",
			"Sou Magus. Fui Sentinela — hoje guardo o que resta do Arcano livre.",
			"Três caminhos sangram: Mylune a oeste, a Trilha a leste, o Cemitério ao norte.",
			"Recrute Mira (druida) no poço. Fale comigo de novo se quiser meu poder em combate.",
			"Otto… a Marreta de Vasta ainda ecoa em você. Use os dados com juízo.",
		]))
		return
	if not GameState.recruited_magus:
		GameState.recruited_magus = true
		GameState.party_changed.emit()
		GameState.quest_updated.emit(GameState.quest_text())
		_talk(name, PackedStringArray([
			"Levarei o Arcano à batalha — longe dos olhos de Vasta.",
			"Classe Mago: Magia e Contra-feitiço. Dados d8 / janela d4.",
			"Magus entrou no grupo!",
			GameState.quest_text(),
		]))
		return
	_talk(name, PackedStringArray([
		GameState.quest_text(),
		"Party: %s" % GameState.party_summary(),
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
