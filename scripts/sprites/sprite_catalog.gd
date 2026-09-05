class_name SpriteCatalog
extends RefCounted

## Monta SpriteFrames a partir dos assets (Terra = herói jogável).

const TERRA := "res://assets/sprites/terra/frames"


static func gildesh() -> SpriteFrames:
	## Herói usa sprites da pasta terra.
	return terra()


static func terra() -> SpriteFrames:
	var sf := SpriteFrames.new()
	_add_anim(sf, &"idle_front", 1.0, _seq("%s/idle_front" % TERRA, 1))
	_add_anim(sf, &"idle_back", 1.0, _seq("%s/idle_back" % TERRA, 1))
	_add_anim(sf, &"idle_left", 1.0, _seq("%s/idle_left" % TERRA, 1))
	_add_anim(sf, &"walk_front", 8.0, _seq("%s/walk_front" % TERRA, 4))
	_add_anim(sf, &"walk_back", 8.0, _seq("%s/walk_back" % TERRA, 4))
	_add_anim(sf, &"walk_left", 8.0, _seq("%s/walk_left" % TERRA, 4))
	_add_anim(sf, &"battle", 1.0, _seq("%s/battle" % TERRA, 1))
	_add_anim(sf, &"cast", 6.0, _seq("%s/cast" % TERRA, 2))
	_add_anim(sf, &"hit", 1.0, _seq("%s/hit" % TERRA, 1))
	_add_anim(sf, &"victory", 4.0, _seq("%s/victory" % TERRA, 2))
	_add_anim(sf, &"dead", 1.0, _seq("%s/dead" % TERRA, 1))
	# aliases usados pelo player antigo
	_add_anim(sf, &"idle", 1.0, _seq("%s/idle_front" % TERRA, 1))
	_add_anim(sf, &"walk", 8.0, _seq("%s/walk_front" % TERRA, 4))
	return sf


static func warrior() -> SpriteFrames:
	return terra()


static func magus() -> SpriteFrames:
	## NPC mago (spritesheet magus.png → frames/).
	const M := "res://assets/sprites/magus/frames"
	var sf := SpriteFrames.new()
	_add_anim(sf, &"idle", 1.0, ["%s/front/00.png" % M])
	_add_anim(sf, &"idle_front", 1.0, ["%s/front/00.png" % M])
	_add_anim(sf, &"idle_back", 1.0, ["%s/back/00.png" % M])
	_add_anim(sf, &"idle_left", 1.0, ["%s/left/00.png" % M])
	_add_anim(sf, &"idle_right", 1.0, ["%s/right/00.png" % M])
	_add_anim(sf, &"walk_front", 6.0, _seq("%s/front" % M, 5))
	_add_anim(sf, &"walk_back", 6.0, _seq("%s/back" % M, 5))
	_add_anim(sf, &"walk_left", 6.0, _seq("%s/left" % M, 5))
	_add_anim(sf, &"walk_right", 6.0, _seq("%s/right" % M, 5))
	_add_anim(sf, &"attack", 8.0, _seq("%s/attack" % M, 4))
	_add_anim(sf, &"cast", 7.0, _seq("%s/cast" % M, 5))
	_add_anim(sf, &"hurt", 5.0, _seq("%s/hurt" % M, 5))
	_add_anim(sf, &"walk", 6.0, _seq("%s/front" % M, 5))
	return sf


static func mira() -> SpriteFrames:
	var sf := SpriteFrames.new()
	_add_anim(sf, &"idle", 3.0, [
		"res://assets/sprites/mira/mira_00.png",
		"res://assets/sprites/mira/mira_01.png",
	])
	return sf


static func slime() -> SpriteFrames:
	var sf := SpriteFrames.new()
	_add_anim(sf, &"idle", 4.0, [
		"res://assets/sprites/slime/slime_00.png",
		"res://assets/sprites/slime/slime_01.png",
	])
	return sf


static func shade() -> SpriteFrames:
	var sf := SpriteFrames.new()
	_add_anim(sf, &"idle", 3.5, [
		"res://assets/sprites/shade/shade_00.png",
		"res://assets/sprites/shade/shade_01.png",
	])
	return sf


static func campfire() -> SpriteFrames:
	var sf := SpriteFrames.new()
	_add_anim(sf, &"idle", 6.0, [
		"res://assets/sprites/campfire/campfire_00.png",
		"res://assets/sprites/campfire/campfire_01.png",
		"res://assets/sprites/campfire/campfire_02.png",
	])
	return sf


static func portrait(id: String) -> Texture2D:
	var resolved := id
	if id == "warrior" or id == "hero" or id == "gildesh":
		resolved = "terra"
	elif id == "ancião" or id == "anciao" or id == "elder":
		resolved = "magus"
	var path := "res://assets/sprites/portraits/%s.png" % resolved
	if ResourceLoader.exists(path):
		return load(path) as Texture2D
	for fallback in ["terra", "gildesh", "warrior"]:
		var p := "res://assets/sprites/portraits/%s.png" % fallback
		if ResourceLoader.exists(p):
			return load(p) as Texture2D
	return null


static func _seq(folder: String, count: int) -> Array:
	var paths: Array = []
	for i in count:
		paths.append("%s/%02d.png" % [folder, i])
	return paths


static func _add_anim(sf: SpriteFrames, anim: StringName, fps: float, paths: Array) -> void:
	if sf.has_animation(anim):
		sf.remove_animation(anim)
	sf.add_animation(anim)
	sf.set_animation_speed(anim, fps)
	sf.set_animation_loop(anim, true)
	for path in paths:
		if ResourceLoader.exists(path):
			var tex: Texture2D = load(path)
			if tex:
				sf.add_frame(anim, tex)
