extends Node

## Estado da run — Vila de Cinzas / Mittelerd (lore Pot).

signal party_changed
signal xp_gained(amount: int, new_level: int)
signal skill_points_changed(points: int)
signal log_message(text: String)
signal quest_updated(text: String)

var player_name: String = "Otto"
var player_level: int = 1
var player_xp: int = 0
var skill_points: int = 0
var max_hp: int = 42
var current_hp: int = 42
var dice_count: int = 1
var dice_sides: int = 10
var parry_window_bonus: float = 0.0
var recruited_mira: bool = false
var recruited_magus: bool = false
var battles_won: int = 0
var last_battle_result: String = ""
var pending_encounter: String = "trilha"

## Progresso
var phase: int = 1
var met_elder: bool = false
var phase1_trail_cleared: bool = false
var cleared_mylune: bool = false
var cleared_trilha: bool = false
var cleared_cemiterio: bool = false
var spawn_point: String = "plaza"

const XP_PER_LEVEL := 20
const GAME_TITLE := "Dado & Lâmina"


func reset_run() -> void:
	player_name = "Otto"
	player_level = 1
	player_xp = 0
	skill_points = 0
	max_hp = 42
	current_hp = 42
	dice_count = 1
	dice_sides = 10
	parry_window_bonus = 0.0
	recruited_mira = false
	recruited_magus = false
	battles_won = 0
	last_battle_result = ""
	pending_encounter = "trilha"
	phase = 1
	met_elder = false
	phase1_trail_cleared = false
	cleared_mylune = false
	cleared_trilha = false
	cleared_cemiterio = false
	spawn_point = "plaza"
	party_changed.emit()
	quest_updated.emit(quest_text())


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
	var party := "%s (Guerreiro)" % player_name
	if recruited_mira:
		party += " · Mira (Druida)"
	if recruited_magus:
		party += " · Magus (Mago)"
	return party


func quest_text() -> String:
	if cleared_cemiterio:
		return "Os três caminhos foram limpos. Fale com Magus na praça."
	if not met_elder:
		return "Objetivo: fale com Magus na praça da Vila de Cinzas."
	var parts: PackedStringArray = []
	if not recruited_mira:
		parts.append("recrute Mira")
	if not recruited_magus:
		parts.append("recrute Magus para a party")
	if not cleared_mylune:
		parts.append("limpe Mylune (oeste)")
	if not cleared_trilha:
		parts.append("limpe a Trilha Sombria (leste)")
	if not cleared_cemiterio:
		parts.append("derrote o Golem no Cemitério (norte)")
	if parts.is_empty():
		return "Fale com Magus para encerrar a fase."
	return "Objetivo: " + ", ".join(parts) + "."


func mark_met_elder() -> void:
	met_elder = true
	quest_updated.emit(quest_text())


func mark_trail_cleared() -> void:
	## Compat legado
	cleared_trilha = true
	phase1_trail_cleared = true
	quest_updated.emit(quest_text())
	log_message.emit("A Trilha Sombria foi limpa.")


func mark_encounter_cleared(id: String) -> void:
	match id:
		"mylune":
			cleared_mylune = true
			log_message.emit("Mylune está calma — por agora.")
		"trilha":
			mark_trail_cleared()
			return
		"cemiterio":
			cleared_cemiterio = true
			phase1_trail_cleared = true
			log_message.emit("O Golem caiu no Cemitério dos Metais.")
	quest_updated.emit(quest_text())


func all_encounters_cleared() -> bool:
	return cleared_mylune and cleared_trilha and cleared_cemiterio
