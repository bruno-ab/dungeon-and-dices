class_name Combatant
extends RefCounted

signal hp_changed(current: int, maximum: int)
signal mp_changed(current: int, maximum: int)
signal defeated

var id: StringName
var display_name: String
var is_player_side: bool
var class_id: StringName = &"warrior"
var sprite_key: String = "terra"
var max_hp: int
var hp: int
var max_mp: int = 0
var mp: int = 0
var speed: int
var dice_count: int
var dice_sides: int
var flat_bonus: int
var color: Color = Color.WHITE
var skill_name: String = "Ataque"
var skill_formula: String = "1d6"
var guarding: bool = false
var attack_kind: StringName = &"melee" ## melee | spell
var level: int = 1
var items: Array[String] = [] ## potion ids for Item menu


func _init(
	p_id: StringName = &"",
	p_name: String = "",
	p_player_side: bool = true,
	p_max_hp: int = 10,
	p_speed: int = 10,
	p_dice_count: int = 1,
	p_dice_sides: int = 6,
	p_flat_bonus: int = 0,
	p_color: Color = Color.WHITE
) -> void:
	id = p_id
	display_name = p_name
	is_player_side = p_player_side
	max_hp = p_max_hp
	hp = p_max_hp
	speed = p_speed
	dice_count = p_dice_count
	dice_sides = p_dice_sides
	flat_bonus = p_flat_bonus
	color = p_color
	skill_formula = "%dd%d" % [dice_count, dice_sides]


func configure_class(p_class: StringName) -> void:
	class_id = p_class
	match String(p_class):
		"warrior":
			dice_sides = 10
			skill_name = "Lâmina Severa"
			skill_formula = "%dd%d + %d" % [dice_count, dice_sides, flat_bonus]
			max_mp = 8
			color = Color(0.85, 0.35, 0.3)
		"druid":
			dice_sides = 6
			skill_name = "Raiz de Mylune"
			skill_formula = "%dd%d + %d" % [dice_count, dice_sides, flat_bonus]
			max_mp = 18
			color = Color(0.35, 0.75, 0.4)
		"mage":
			dice_sides = 8
			skill_name = "Contra-Véu"
			skill_formula = "%dd%d + %d" % [dice_count, dice_sides, flat_bonus]
			max_mp = 24
			color = Color(0.65, 0.45, 0.9)
		_:
			pass
	mp = max_mp
	skill_formula = "%dd%d + %d" % [dice_count, dice_sides, flat_bonus]


func is_alive() -> bool:
	return hp > 0


func take_damage(amount: int) -> void:
	if guarding:
		amount = maxi(1, int(amount * 0.5))
		guarding = false
	hp = maxi(0, hp - amount)
	hp_changed.emit(hp, max_hp)
	if hp <= 0:
		defeated.emit()


func heal(amount: int) -> void:
	hp = mini(max_hp, hp + amount)
	hp_changed.emit(hp, max_hp)


func spend_mp(cost: int) -> bool:
	if mp < cost:
		return false
	mp -= cost
	mp_changed.emit(mp, max_mp)
	return true


func restore_mp(amount: int) -> void:
	mp = mini(max_mp, mp + amount)
	mp_changed.emit(mp, max_mp)


func attack_roll(rng: RandomNumberGenerator) -> Dictionary:
	return DiceEngine.roll_damage(dice_count, dice_sides, flat_bonus, rng)


func class_label() -> String:
	match String(class_id):
		"warrior":
			return "Guerreiro"
		"druid":
			return "Druida"
		"mage":
			return "Mago"
		_:
			return String(class_id)


func die_label() -> String:
	return "d%d" % dice_sides
