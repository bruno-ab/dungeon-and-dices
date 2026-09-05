extends AnimatedSprite2D

@export_enum("gildesh", "warrior", "mira", "slime", "shade", "campfire") var catalog_id: String = "gildesh"
@export var animation_name: StringName = &"idle"


func _ready() -> void:
	match catalog_id:
		"gildesh", "warrior":
			sprite_frames = SpriteCatalog.gildesh()
		"mira":
			sprite_frames = SpriteCatalog.mira()
		"slime":
			sprite_frames = SpriteCatalog.slime()
		"shade":
			sprite_frames = SpriteCatalog.shade()
		"campfire":
			sprite_frames = SpriteCatalog.campfire()
		_:
			sprite_frames = SpriteCatalog.gildesh()
	if sprite_frames and sprite_frames.has_animation(animation_name):
		play(animation_name)
