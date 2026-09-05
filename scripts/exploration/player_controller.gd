extends CharacterBody2D

@export var speed: float = 180.0

@onready var prompt: Label = $Prompt
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	motion_mode = MOTION_MODE_FLOATING
	prompt.visible = false
	anim.sprite_frames = SpriteCatalog.warrior()
	anim.play("idle")


func _physics_process(_delta: float) -> void:
	var dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = dir * speed
	move_and_slide()
	_update_anim(dir)


func _update_anim(dir: Vector2) -> void:
	if anim == null or anim.sprite_frames == null:
		return
	if dir.length() > 0.1:
		anim.flip_h = dir.x < 0.0
		if anim.animation != "walk" or not anim.is_playing():
			anim.play("walk")
	else:
		if anim.animation != "idle" or not anim.is_playing():
			anim.play("idle")


func show_prompt(text: String) -> void:
	prompt.text = text
	prompt.visible = true


func hide_prompt() -> void:
	prompt.visible = false
