extends CharacterBody2D

@export var speed: float = 180.0

@onready var prompt: Label = $Prompt


func _ready() -> void:
	motion_mode = MOTION_MODE_FLOATING
	prompt.visible = false


func _physics_process(_delta: float) -> void:
	var dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = dir * speed
	move_and_slide()


func show_prompt(text: String) -> void:
	prompt.text = text
	prompt.visible = true


func hide_prompt() -> void:
	prompt.visible = false
