class_name Combatant
extends RefCounted

signal hp_changed(current: int, maximum: int)
signal defeated

var id: StringName
var display_name: String
var is_player_side: bool
var max_hp: int
var hp: int
var speed: int
var dice_count: int
var dice_sides: int
var flat_bonus: int
var color: Color


func _init(
	p_id: StringName,
	p_name: String,
	p_player_side: bool,
	p_max_hp: int,
	p_speed: int,
	p_dice_count: int,
	p_dice_sides: int,
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


func is_alive() -> bool:
	return hp > 0


func take_damage(amount: int) -> void:
	hp = maxi(0, hp - amount)
	hp_changed.emit(hp, max_hp)
	if hp <= 0:
		defeated.emit()


func heal(amount: int) -> void:
	hp = mini(max_hp, hp + amount)
	hp_changed.emit(hp, max_hp)


func attack_roll(rng: RandomNumberGenerator) -> Dictionary:
	return DiceEngine.roll_damage(dice_count, dice_sides, flat_bonus, rng)
