extends Area2D

## Porta entre mapas de exploração (ex.: Mylune ↔ Vila).

@export var prompt_text: String = "E — Seguir a trilha"
@export_enum("village", "mylune") var destination: String = "village"
@export var spawn_on_arrive: String = "plaza"


func _ready() -> void:
	body_entered.connect(_on_enter)
	body_exited.connect(_on_exit)
	monitoring = true


var _inside: bool = false


func _process(_delta: float) -> void:
	if not _inside or DialogueManager.is_busy():
		return
	if Input.is_action_just_pressed("interact"):
		_travel()


func _on_enter(body: Node2D) -> void:
	if body.is_in_group("player"):
		_inside = true
		if body.has_method("show_prompt"):
			body.show_prompt(prompt_text)


func _on_exit(body: Node2D) -> void:
	if body.is_in_group("player"):
		_inside = false
		if body.has_method("hide_prompt"):
			body.hide_prompt()


func _travel() -> void:
	AudioManager.sfx_ui_confirm()
	GameState.spawn_point = spawn_on_arrive
	match destination:
		"village":
			SceneRouter.go_village()
		"mylune":
			SceneRouter.go_mylune()
		_:
			SceneRouter.go_mylune()
