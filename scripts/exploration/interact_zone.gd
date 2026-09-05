extends Area2D

@export var prompt_text: String = "E — Entrar em combate"
@export var mode: String = "battle" ## battle | recruit | heal

var _player_inside: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _process(_delta: float) -> void:
	if not _player_inside:
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
		"battle":
			SceneRouter.go_battle()
		"recruit":
			if GameState.recruited_mira:
				GameState.log_message.emit("Mira já está no grupo.")
			else:
				GameState.recruited_mira = true
				GameState.party_changed.emit()
				GameState.log_message.emit("Mira se juntou ao grupo!")
		"heal":
			GameState.heal_full()
			GameState.log_message.emit("HP restaurado no fogueira.")
		_:
			pass
