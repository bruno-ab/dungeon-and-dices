extends AnimatedSprite2D

@export_enum("terra", "gildesh", "warrior", "magus", "mira", "slime", "shade", "campfire", "rune_frog") var catalog_id: String = "terra"
@export var animation_name: StringName = &"idle"


func _ready() -> void:
	match catalog_id:
		"terra", "gildesh", "warrior":
			sprite_frames = SpriteCatalog.terra()
			if animation_name == &"idle" and sprite_frames.has_animation(&"idle_front"):
				animation_name = &"idle_front"
		"magus":
			sprite_frames = SpriteCatalog.magus()
		"mira":
			sprite_frames = SpriteCatalog.mira()
		"slime":
			sprite_frames = SpriteCatalog.slime()
		"shade":
			sprite_frames = SpriteCatalog.shade()
		"campfire":
			sprite_frames = SpriteCatalog.campfire()
		"rune_frog":
			sprite_frames = SpriteCatalog.rune_frog()
		_:
			sprite_frames = SpriteCatalog.terra()
			if animation_name == &"idle" and sprite_frames.has_animation(&"idle_front"):
				animation_name = &"idle_front"
	if sprite_frames and sprite_frames.has_animation(animation_name):
		play(animation_name)
