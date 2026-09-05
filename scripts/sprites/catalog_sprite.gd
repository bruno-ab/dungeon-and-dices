extends AnimatedSprite2D

@export_enum("warrior", "mira", "slime", "shade", "campfire") var catalog_id: String = "mira"
@export var animation_name: StringName = &"idle"


func _ready() -> void:
	match catalog_id:
		"warrior":
			sprite_frames = SpriteCatalog.warrior()
		"mira":
			sprite_frames = SpriteCatalog.mira()
		"slime":
			sprite_frames = SpriteCatalog.slime()
		"shade":
			sprite_frames = SpriteCatalog.shade()
		"campfire":
			sprite_frames = SpriteCatalog.campfire()
		_:
			sprite_frames = SpriteCatalog.mira()
	if sprite_frames and sprite_frames.has_animation(animation_name):
		play(animation_name)
