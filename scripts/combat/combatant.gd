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

## Estado de combate (classes.md)
var form: StringName = &"human" ## human | bear | panther
var armor_bonus: int = 0 ## reduz dano até o próximo turno próprio
var next_die_bonus: int = 0 ## +flat no próximo ataque
var stunned: bool = false
var last_stand_ready: bool = false
var last_stand_used: bool = false
var power_attack_armed: bool = false
var force_max_first: bool = false
var reroll_low: int = 0
var unlock_bear: bool = false
var unlock_panther: bool = false
var form_keep_bonus: int = 0
var ally_crit_bonus_pending: int = 0 ## Crítico Brutal


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
	form = &"human"
	match String(p_class):
		"warrior":
			dice_sides = ClassRules.base_die(&"warrior")
			skill_name = ClassRules.skill_name_default(&"warrior")
			max_mp = 8
			color = Color(0.85, 0.35, 0.3)
		"druid":
			dice_sides = ClassRules.die_for_form(form)
			skill_name = ClassRules.skill_name_default(&"druid")
			max_mp = 18
			color = Color(0.35, 0.75, 0.4)
		"mage":
			dice_sides = ClassRules.base_die(&"mage")
			skill_name = ClassRules.skill_name_default(&"mage")
			max_mp = 24
			color = Color(0.65, 0.45, 0.9)
		_:
			pass
	mp = max_mp
	refresh_formula()


func refresh_formula() -> void:
	skill_formula = "%dd%d + %d" % [dice_count, dice_sides, flat_bonus]
	if class_id == &"druid":
		skill_formula = "%s · %s" % [ClassRules.form_label(form), skill_formula]


func set_form(p_form: StringName) -> bool:
	if class_id != &"druid":
		return false
	if p_form == &"bear" and not unlock_bear:
		return false
	if p_form == &"panther" and not unlock_panther:
		return false
	if form_keep_bonus > 0 and form != p_form:
		flat_bonus += form_keep_bonus
	form = p_form
	dice_sides = ClassRules.die_for_form(form)
	match String(form):
		"bear":
			skill_name = "Garra de Urso"
		"panther":
			skill_name = "Salto da Pantera"
		_:
			skill_name = ClassRules.skill_name_default(&"druid")
	refresh_formula()
	return true


func is_alive() -> bool:
	return hp > 0


func take_damage(amount: int) -> bool:
	## Retorna true se Último Fôlego acabou de ativar.
	amount = maxi(0, amount - armor_bonus)
	if guarding:
		amount = maxi(1, int(amount * guard_mitigation)) if amount > 0 else 0
		guarding = false
	hp = maxi(0, hp - amount)
	if hp <= 0 and last_stand_ready and not last_stand_used:
		last_stand_used = true
		var revive := dice_sides
		hp = mini(max_hp, revive)
		hp_changed.emit(hp, max_hp)
		return true
	hp_changed.emit(hp, max_hp)
	if hp <= 0:
		defeated.emit()
	return false


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


func attack_opts() -> Dictionary:
	return {
		"reroll_low": reroll_low,
		"force_max_first": force_max_first,
		"allow_crit": class_id != &"mage",
		"crit_chance": 0.08 if form == &"panther" else 0.05,
	}


func attack_roll(rng: RandomNumberGenerator) -> Dictionary:
	var count := dice_count
	var flat := flat_bonus + next_die_bonus
	next_die_bonus = 0
	if power_attack_armed:
		count += 1
		power_attack_armed = false
	var result := DiceEngine.roll_damage(count, dice_sides, flat, rng, attack_opts())
	return result


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
	if class_id == &"druid":
		return "d%d (%s)" % [dice_sides, ClassRules.form_label(form)]
	if class_id == &"mage":
		return "%dd4 / d20" % dice_count
	return "d%d" % dice_sides
