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
var guard_mitigation: float = 0.5
var attack_kind: StringName = &"melee" ## melee | spell
var level: int = 1
var items: Array[String] = [] ## potion ids for Item menu
var form: StringName = &"human" ## human | bear | panther (druida)
var armor_class: int = 12
var attack_bonus: int = 0


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
	attack_bonus = flat_bonus
	armor_class = 11 + level / 2


func configure_class(p_class: StringName) -> void:
	class_id = p_class
	match String(p_class):
		"warrior":
			dice_sides = 10
			skill_name = "Lâmina Severa"
			max_mp = 8
			color = Color(0.85, 0.35, 0.3)
			armor_class = 13
		"druid":
			dice_sides = 6
			skill_name = "Raiz de Mylune"
			max_mp = 18
			color = Color(0.35, 0.75, 0.4)
			armor_class = 12
			form = &"human"
		"mage":
			dice_sides = 8
			skill_name = "Contra-Véu"
			max_mp = 24
			color = Color(0.65, 0.45, 0.9)
			armor_class = 11
		_:
			armor_class = 12
	mp = max_mp
	attack_bonus = flat_bonus + level / 3
	_refresh_formula()


func set_form(p_form: StringName) -> String:
	if class_id != &"druid":
		return "Só a druida troca de forma."
	form = p_form
	var msg := ""
	match String(p_form):
		"bear":
			dice_sides = 12
			skill_name = "Garra do Urso"
			armor_class = 14
			msg = "Mira assume Forma de Urso (d12)."
		"panther":
			dice_sides = 8
			skill_name = "Presa da Pantera"
			armor_class = 12
			msg = "Mira assume Forma de Pantera (d8)."
		_:
			form = &"human"
			dice_sides = 6
			skill_name = "Raiz de Mylune"
			armor_class = 12
			msg = "Mira volta à forma humana (d6)."
	_refresh_formula()
	return msg


func cycle_form() -> String:
	match String(form):
		"human":
			return set_form(&"bear")
		"bear":
			return set_form(&"panther")
		_:
			return set_form(&"human")


func _refresh_formula() -> void:
	skill_formula = "%dd%d + %d" % [dice_count, dice_sides, flat_bonus]


func is_alive() -> bool:
	return hp > 0


func take_damage(amount: int) -> void:
	if guarding:
		amount = maxi(1, int(amount * guard_mitigation))
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


func attack_roll(rng: RandomNumberGenerator, target_ac: int = 12) -> Dictionary:
	return DiceEngine.full_attack(
		dice_count, dice_sides, flat_bonus, attack_bonus, target_ac, rng
	)


func class_label() -> String:
	match String(class_id):
		"warrior":
			return "Guerreiro"
		"druid":
			match String(form):
				"bear":
					return "Druida · Urso"
				"panther":
					return "Druida · Pantera"
				_:
					return "Druida"
		"mage":
			return "Mago"
		_:
			return String(class_id)


func die_label() -> String:
	return "d%d" % dice_sides
