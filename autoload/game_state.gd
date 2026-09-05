extends Node

## Estado persistente do MVP entre cenas.

signal party_changed
signal xp_gained(amount: int, new_level: int)
signal skill_points_changed(points: int)
signal log_message(text: String)

var player_name: String = "Guerreiro"
var player_level: int = 1
var player_xp: int = 0
var skill_points: int = 0
var max_hp: int = 40
var current_hp: int = 40
var dice_count: int = 1 ## 1d10 → 2d10 etc.
var dice_sides: int = 10
var parry_window_bonus: float = 0.0 ## segundos extras na janela
var recruited_mira: bool = false
var battles_won: int = 0
var last_battle_result: String = ""

const XP_PER_LEVEL := 20


func reset_run() -> void:
	player_level = 1
	player_xp = 0
	skill_points = 0
	max_hp = 40
	current_hp = 40
	dice_count = 1
	dice_sides = 10
	parry_window_bonus = 0.0
	recruited_mira = false
	battles_won = 0
	last_battle_result = ""
	party_changed.emit()


func heal_full() -> void:
	current_hp = max_hp


func apply_damage_to_player(amount: int) -> void:
	current_hp = maxi(0, current_hp - amount)


func grant_xp(amount: int) -> void:
	player_xp += amount
	var leveled := false
	while player_xp >= XP_PER_LEVEL:
		player_xp -= XP_PER_LEVEL
		player_level += 1
		skill_points += 1
		max_hp += 8
		current_hp = max_hp
		# Pool de dados cresce a cada 5 níveis (MVP simplificado: +1 dado no nível 5 e 10)
		if player_level == 5 or player_level == 10:
			dice_count += 1
		leveled = true
		skill_points_changed.emit(skill_points)
	xp_gained.emit(amount, player_level)
	if leveled:
		log_message.emit("Subiu para o nível %d! Skill points: %d" % [player_level, skill_points])


func spend_skill_widen_parry() -> bool:
	if skill_points <= 0:
		return false
	skill_points -= 1
	parry_window_bonus += 0.08
	skill_points_changed.emit(skill_points)
	log_message.emit("Janela de Parry ampliada (+0.08s).")
	return true


func spend_skill_extra_die() -> bool:
	if skill_points <= 0:
		return false
	skill_points -= 1
	dice_count += 1
	skill_points_changed.emit(skill_points)
	log_message.emit("Pool de dados: agora %dd%d." % [dice_count, dice_sides])
	return true


func party_summary() -> String:
	var party := player_name
	if recruited_mira:
		party += " + Mira"
	return party
