extends Node

## Estado da run — Vila de Cinzas / Mittelerd (lore Pot).

signal party_changed
signal xp_gained(amount: int, new_level: int)
signal skill_points_changed(points: int)
signal skills_changed
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
var dodge_window_bonus: float = 0.0
var spell_window_bonus: float = 0.0
var recruited_mira: bool = false
var recruited_magus: bool = false
var battles_won: int = 0
var last_battle_result: String = ""
var pending_encounter: String = "trilha"

## skill_id -> true
var unlocked_skills: Dictionary = {}

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
const BASE_MAX_HP := 42


func reset_run() -> void:
	player_name = "Otto"
	player_level = 1
	player_xp = 0
	skill_points = 1 ## um ponto inicial para experimentar a árvore
	max_hp = BASE_MAX_HP
	current_hp = BASE_MAX_HP
	dice_count = 1
	dice_sides = 10
	parry_window_bonus = 0.0
	dodge_window_bonus = 0.0
	spell_window_bonus = 0.0
	unlocked_skills.clear()
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
	_recompute_from_skills()
	party_changed.emit()
	skill_points_changed.emit(skill_points)
	skills_changed.emit()
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
		AudioManager.sfx_level_up()
		log_message.emit("Subiu para o nível %d! Skill points: %d — abra a Árvore (Tab)." % [player_level, skill_points])
		_recompute_from_skills()


func has_skill(skill_id: StringName) -> bool:
	return unlocked_skills.has(String(skill_id))


func unlocked_list_for(class_id: StringName) -> Array[StringName]:
	var out: Array[StringName] = []
	for d in SkillCatalog.defs_for(class_id):
		if has_skill(d.id):
			out.append(d.id)
	return out


func can_unlock_skill(skill_id: StringName) -> bool:
	var def := SkillCatalog.get_def(skill_id)
	if def == null:
		return false
	if has_skill(skill_id):
		return false
	if skill_points < def.cost:
		return false
	if player_level < def.level_req:
		return false
	if not _class_available(def.class_id):
		return false
	for pre in def.prerequisites:
		if not has_skill(pre):
			return false
	return true


func unlock_skill(skill_id: StringName) -> bool:
	if not can_unlock_skill(skill_id):
		return false
	var def := SkillCatalog.get_def(skill_id)
	skill_points -= def.cost
	unlocked_skills[String(skill_id)] = true
	_recompute_from_skills()
	skill_points_changed.emit(skill_points)
	skills_changed.emit()
	AudioManager.sfx_level_up()
	log_message.emit("Skill desbloqueada: %s (%s)." % [def.display_name, SkillCatalog.class_label(def.class_id)])
	return true


func _class_available(class_id: StringName) -> bool:
	match String(class_id):
		"warrior":
			return true
		"druid":
			return recruited_mira
		"mage":
			return recruited_magus
		_:
			return false


func available_classes() -> Array[StringName]:
	var out: Array[StringName] = [&"warrior"]
	if recruited_mira:
		out.append(&"druid")
	if recruited_magus:
		out.append(&"mage")
	return out


func effect_sum(key: String, class_id: StringName = &"") -> float:
	var total := 0.0
	for sid in unlocked_skills.keys():
		var def := SkillCatalog.get_def(StringName(sid))
		if def == null:
			continue
		if class_id != &"" and def.class_id != class_id:
			continue
		if def.effects.has(key):
			total += float(def.effects[key])
	return total


func _recompute_from_skills() -> void:
	## HP base = BASE + levels*8 + skills (levels already applied on level-up into max_hp)
	## Recompute windows from skills only (level dice stays separate)
	parry_window_bonus = effect_sum("parry_window")
	dodge_window_bonus = effect_sum("dodge_window")
	spell_window_bonus = effect_sum("spell_window")
	var hp_from_skills := int(effect_sum("max_hp"))
	var level_hp := BASE_MAX_HP + (player_level - 1) * 8
	var new_max := level_hp + hp_from_skills
	if new_max != max_hp:
		var diff := new_max - max_hp
		max_hp = new_max
		if diff > 0:
			current_hp = mini(max_hp, current_hp + diff)
		else:
			current_hp = mini(current_hp, max_hp)


func apply_combatant_skills(c: Combatant) -> void:
	var cid := c.class_id
	c.dice_count += int(effect_sum("extra_dice", cid))
	c.flat_bonus += int(effect_sum("flat_bonus", cid))
	c.speed += int(effect_sum("speed", cid))
	c.max_mp += int(effect_sum("max_mp", cid))
	c.mp = c.max_mp
	c.skill_formula = "%dd%d + %d" % [c.dice_count, c.dice_sides, c.flat_bonus]


func magic_cost_for(class_id: StringName, base_cost: int = 4) -> int:
	return maxi(0, base_cost - int(effect_sum("magic_cost_reduce", class_id)))


func guard_heal_bonus(class_id: StringName) -> int:
	return int(effect_sum("guard_heal", class_id))


func guard_extra_mitigation(class_id: StringName) -> float:
	return effect_sum("guard_mitigation", class_id)


func counter_damage_mult(class_id: StringName) -> float:
	return 1.0 + effect_sum("counter_mult", class_id)


func reflect_bonus(class_id: StringName) -> int:
	return int(effect_sum("reflect_bonus", class_id))


func heal_item_bonus(class_id: StringName) -> int:
	return int(effect_sum("heal_bonus", class_id))


func env_mult(class_id: StringName, element: String) -> float:
	match element:
		"FOGO":
			return 1.0 + effect_sum("env_fogo_mult", class_id)
		"GELO":
			return 1.0 + effect_sum("env_gelo_mult", class_id)
		"TERRA":
			return 1.0 + effect_sum("env_terra_mult", class_id)
		_:
			return 1.0


func warrior_magic_free() -> bool:
	return effect_sum("warrior_magic_free", &"warrior") > 0.0


## Compat legado (atalhos 1/2 redirecionam para skills da árvore)
func spend_skill_widen_parry() -> bool:
	if has_skill(&"w_parry"):
		log_message.emit("Aparo Largo já desbloqueado na árvore (Tab).")
		return false
	return unlock_skill(&"w_parry") if can_unlock_skill(&"w_parry") else _legacy_fail()


func spend_skill_extra_die() -> bool:
	if has_skill(&"w_die"):
		log_message.emit("Segundo Dado já desbloqueado na árvore (Tab).")
		return false
	return unlock_skill(&"w_die") if can_unlock_skill(&"w_die") else _legacy_fail()


func _legacy_fail() -> bool:
	log_message.emit("Abra a Árvore de Skills (Tab) para gastar pontos.")
	return false


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
