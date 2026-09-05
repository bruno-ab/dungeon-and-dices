extends CharacterBody2D

@export var speed: float = 180.0

@onready var prompt: Label = $Prompt
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var _facing: StringName = &"front" ## front | back | left
var _foot_cd: float = 0.0


func _ready() -> void:
	motion_mode = MOTION_MODE_FLOATING
	prompt.visible = false
	anim.sprite_frames = SpriteCatalog.terra()
	anim.play("idle_front")


func _physics_process(delta: float) -> void:
	var dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = dir * speed
	move_and_slide()
	_update_anim(dir)
	_foot_cd = maxf(0.0, _foot_cd - delta)
	if dir.length() > 0.1 and _foot_cd <= 0.0:
		AudioManager.sfx_footstep()
		_foot_cd = 0.28


func _update_anim(dir: Vector2) -> void:
	if anim == null or anim.sprite_frames == null:
		return
	var moving := dir.length() > 0.1
	if moving:
		if absf(dir.x) > absf(dir.y):
			_facing = &"left"
			anim.flip_h = dir.x > 0.0 ## direita = esquerda espelhada
		elif dir.y < 0.0:
			_facing = &"back"
			anim.flip_h = false
		else:
			_facing = &"front"
			anim.flip_h = false
	var prefix := "walk" if moving else "idle"
	var anim_name := "%s_%s" % [prefix, String(_facing)]
	if anim.animation != anim_name or not anim.is_playing():
		if anim.sprite_frames.has_animation(anim_name):
			anim.play(anim_name)


func show_prompt(text: String) -> void:
	prompt.text = text
	prompt.visible = true


func hide_prompt() -> void:
	prompt.visible = false
