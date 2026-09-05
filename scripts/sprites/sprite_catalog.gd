class_name SpriteCatalog
extends RefCounted

## Monta SpriteFrames a partir dos PNGs em assets/sprites.


static func warrior() -> SpriteFrames:
	var sf := SpriteFrames.new()
	_add_anim(sf, &"idle", 3.0, [
		"res://assets/sprites/warrior/warrior_00.png",
		"res://assets/sprites/warrior/warrior_02.png",
	])
	_add_anim(sf, &"walk", 8.0, [
		"res://assets/sprites/warrior/warrior_00.png",
		"res://assets/sprites/warrior/warrior_01.png",
		"res://assets/sprites/warrior/warrior_02.png",
		"res://assets/sprites/warrior/warrior_03.png",
	])
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
	var path := "res://assets/sprites/portraits/%s.png" % id
	if ResourceLoader.exists(path):
		return load(path) as Texture2D
	return null


static func _add_anim(sf: SpriteFrames, anim: StringName, fps: float, paths: Array) -> void:
	if sf.has_animation(anim):
		sf.remove_animation(anim)
	sf.add_animation(anim)
	sf.set_animation_speed(anim, fps)
	sf.set_animation_loop(anim, true)
	for path in paths:
		var tex: Texture2D = load(path)
		if tex:
			sf.add_frame(anim, tex)
