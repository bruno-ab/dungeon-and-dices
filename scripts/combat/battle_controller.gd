extends Node

## Loop de batalha: turnos + reações + 3 classes + encontros data-driven.

signal battle_log(text: String)
signal ui_refresh
signal player_actions_enabled(enabled: bool)
signal reaction_started(window: ReactionWindow)
signal reaction_ended(result: ReactionWindow.Result)
signal battle_finished(won: bool)
signal timeline_changed(order: Array)
signal skill_preview(name: String, formula: String)
signal env_changed(env: Dictionary)
signal turn_index_changed(index: int)

enum Phase { BOOT, PLAYER_TURN, ENEMY_TURN, REACTION, RESOLVE, END }

var phase: Phase = Phase.BOOT
var combatants: Array[Combatant] = []
var turn_queue: Array[Combatant] = []
var current: Combatant
var rng := RandomNumberGenerator.new()
var reaction := ReactionWindow.new()
var pending_attacker: Combatant
var pending_target: Combatant
var pending_damage: int = 0
var pending_attack_kind: StringName = &"melee"
var busy: bool = false
var encounter_id: String = "trilha"
var env_dice: Dictionary = {}
var turn_number: int = 1
var selected_target_id: StringName = &""
var last_roll_label: String = ""


func setup_encounter(p_id: String = "") -> void:
	rng.randomize()
	encounter_id = p_id if p_id != "" else GameState.pending_encounter
	if encounter_id == "":
		encounter_id = "trilha"
	combatants.clear()
	turn_number = 1
	var meta: Dictionary = EncounterCatalog.meta(encounter_id)
	env_dice = meta.get("env", {"FOGO": 8, "TERRA": 10, "GELO": 6})
	env_changed.emit(env_dice)
	AudioManager.bgm_battle(encounter_id)
	AudioManager.sfx_battle_start()

	combatants.append(_make_otto())
	if GameState.recruited_mira:
		combatants.append(_make_mira())
	if GameState.recruited_magus:
		combatants.append(_make_magus())

	for e in EncounterCatalog.build_enemies(encounter_id):
		combatants.append(e)

	_pick_default_target()
	_rebuild_turn_queue()
	phase = Phase.BOOT
	battle_log.emit("— %s —" % meta.get("title", encounter_id))
	battle_log.emit(str(meta.get("blurb", "")))
	battle_log.emit("Ambiente: FOGO d%d · TERRA d%d · GELO d%d" % [
		int(env_dice.get("FOGO", 8)), int(env_dice.get("TERRA", 10)), int(env_dice.get("GELO", 6))
	])
	ui_refresh.emit()
	timeline_changed.emit(_timeline_payload())


func setup_mvp_encounter() -> void:
	setup_encounter(GameState.pending_encounter)


func _make_otto() -> Combatant:
	var c := Combatant.new(
		&"hero", GameState.player_name, true,
		GameState.max_hp, 12, GameState.dice_count, 10, 2, Color(0.85, 0.35, 0.3)
	)
	c.hp = clampi(GameState.current_hp, 1, GameState.max_hp)
	c.max_hp = GameState.max_hp
	c.level = GameState.player_level
	c.sprite_key = "otto"
	c.configure_class(&"warrior")
	c.items = ["pocao"]
	c.flat_bonus = 2 + GameState.player_level / 2
	c.configure_class(&"warrior")
	GameState.apply_combatant_skills(c)
	return c


func _make_mira() -> Combatant:
	var c := Combatant.new(&"mira", "Mira", true, 28 + GameState.player_level * 2, 14, 1, 6, 1, Color(0.35, 0.75, 0.4))
	c.sprite_key = "lyra"
	c.level = GameState.player_level
	c.configure_class(&"druid")
	c.items = ["pocao", "semente"]
	GameState.apply_combatant_skills(c)
	return c


func _make_magus() -> Combatant:
	var c := Combatant.new(&"magus", "Magus", true, 24 + GameState.player_level, 11, 1, 8, 2, Color(0.65, 0.45, 0.9))
	c.sprite_key = "kelvin"
	c.level = GameState.player_level
	c.configure_class(&"mage")
	c.items = ["pocao"]
	GameState.apply_combatant_skills(c)
	return c


func start() -> void:
	busy = false
	await _advance_turns()


func _rebuild_turn_queue() -> void:
	turn_queue = combatants.filter(func(c: Combatant) -> bool: return c.is_alive())
	turn_queue.sort_custom(
		func(a: Combatant, b: Combatant) -> bool:
			if a.speed == b.speed:
				return String(a.id) < String(b.id)
			return a.speed > b.speed
	)
	timeline_changed.emit(_timeline_payload())


func timeline_order() -> Array:
	return _timeline_payload()


func _timeline_payload() -> Array:
	var arr: Array = []
	for c in turn_queue:
		arr.append({"id": c.id, "name": c.display_name, "side": c.is_player_side, "sprite": c.sprite_key})
	return arr


func _alive(side_player: bool) -> Array[Combatant]:
	var out: Array[Combatant] = []
	for c in combatants:
		if c.is_alive() and c.is_player_side == side_player:
			out.append(c)
	return out


func _foes_alive() -> Array[Combatant]:
	return _alive(false)


func _pick_default_target() -> void:
	var foes := _foes_alive()
	if foes.is_empty():
		selected_target_id = &""
		return
	selected_target_id = foes[0].id


func set_selected_target(id: StringName) -> void:
	var t := _find(id)
	if t and t.is_alive() and not t.is_player_side:
		selected_target_id = id
		ui_refresh.emit()


func _check_end() -> bool:
	if _alive(true).is_empty():
		phase = Phase.END
		GameState.current_hp = 0
		GameState.last_battle_result = "defeat"
		AudioManager.stop_bgs()
		AudioManager.me_defeat()
		battle_log.emit("Derrota… a Vila de Cinzas ainda espera.")
		battle_finished.emit(false)
		ui_refresh.emit()
		return true
	if _alive(false).is_empty():
		phase = Phase.END
		var hero := _find(&"hero")
		if hero:
			GameState.current_hp = hero.hp
		GameState.battles_won += 1
		GameState.last_battle_result = "victory"
		GameState.mark_encounter_cleared(encounter_id)
		var xp := EncounterCatalog.xp_reward(encounter_id)
		GameState.grant_xp(xp)
		AudioManager.stop_bgs()
		AudioManager.bgm_victory_stinger()
		AudioManager.me_victory()
		battle_log.emit("Vitória! +%d XP." % xp)
		battle_finished.emit(true)
		ui_refresh.emit()
		return true
	return false


func find_combatant(id: StringName) -> Combatant:
	for c in combatants:
		if c.id == id:
			return c
	return null


func _find(id: StringName) -> Combatant:
	return find_combatant(id)


func _advance_turns() -> void:
	while phase != Phase.END and not _check_end():
		_rebuild_turn_queue()
		turn_index_changed.emit(turn_number)
		for actor in turn_queue:
			if phase == Phase.END:
				return
			if not actor.is_alive():
				continue
			current = actor
			actor.guarding = false
			if actor.is_player_side:
				skill_preview.emit(actor.skill_name, actor.skill_formula)
			ui_refresh.emit()
			timeline_changed.emit(_timeline_payload())
			if actor.is_player_side:
				phase = Phase.PLAYER_TURN
				player_actions_enabled.emit(true)
				battle_log.emit("Turno de %s (%s)." % [actor.display_name, actor.class_label()])
				await _wait_player_action_done()
			else:
				phase = Phase.ENEMY_TURN
				player_actions_enabled.emit(false)
				await _enemy_act(actor)
			if _check_end():
				return
		turn_number += 1
		battle_log.emit("--- fim da rodada %d ---" % (turn_number - 1))


var _player_action_done: bool = false


func _wait_player_action_done() -> void:
	_player_action_done = false
	while not _player_action_done and phase != Phase.END:
		await get_tree().process_frame


func notify_player_action_finished() -> void:
	_player_action_done = true
	player_actions_enabled.emit(false)


func player_attack(target_id: StringName = &"") -> void:
	if phase != Phase.PLAYER_TURN or busy or current == null:
		return
	var tid := target_id if target_id != &"" else selected_target_id
	var target := _find(tid)
	if target == null or not target.is_alive() or target.is_player_side:
		_pick_default_target()
		target = _find(selected_target_id)
	if target == null:
		return
	busy = true
	AudioManager.sfx_attack()
	var roll := current.attack_roll(rng)
	var dmg: int = int(roll["total"])
	# ambiente: TERRA reforça guerreiro, FOGO mago, GELO druida
	dmg += _env_bonus_for(current)
	target.take_damage(dmg)
	AudioManager.sfx_damage()
	last_roll_label = str(roll["label"])
	battle_log.emit(
		"ROLANDO DADOS… %s usa [%s] em %s — %s (+amb %d) = %d"
		% [current.display_name, current.skill_name, target.display_name, roll["label"], _env_bonus_for(current), dmg]
	)
	ui_refresh.emit()
	busy = false
	notify_player_action_finished()


func player_guard() -> void:
	if phase != Phase.PLAYER_TURN or busy or current == null:
		return
	busy = true
	AudioManager.sfx_guard()
	current.guarding = true
	current.guard_mitigation = clampf(0.5 - GameState.guard_extra_mitigation(current.class_id), 0.25, 0.5)
	var heal_amt := 2 + GameState.guard_heal_bonus(current.class_id)
	current.heal(heal_amt)
	var roll := DiceEngine.roll(1, 6, rng)
	battle_log.emit(
		"%s GUARDA (janela d6 → %s). Próximo dano reduzido. +%d HP."
		% [current.display_name, roll["label"], heal_amt]
	)
	ui_refresh.emit()
	busy = false
	notify_player_action_finished()


func player_cast_magic() -> void:
	if phase != Phase.PLAYER_TURN or busy or current == null:
		return
	var cost := GameState.magic_cost_for(current.class_id, 4)
	if current.class_id == &"warrior" and GameState.warrior_magic_free():
		cost = 0
	if not current.spend_mp(cost):
		AudioManager.sfx_miss()
		battle_log.emit("%s sem MP suficiente (custo %d)." % [current.display_name, cost])
		return
	var target := _find(selected_target_id)
	if target == null or not target.is_alive():
		_pick_default_target()
		target = _find(selected_target_id)
	if target == null:
		current.restore_mp(cost)
		return
	busy = true
	AudioManager.sfx_magic()
	var sides := 8 if current.class_id == &"mage" else 6
	if current.class_id == &"warrior":
		sides = 10
	var roll := DiceEngine.roll_damage(1, sides, current.flat_bonus + 2, rng)
	var dmg: int = int(roll["total"]) + _env_bonus_for(current)
	if current.class_id == &"warrior" and GameState.warrior_magic_free():
		dmg += 5
	target.take_damage(dmg)
	AudioManager.sfx_damage()
	last_roll_label = str(roll["label"])
	battle_log.emit("%s conjura MAGIA — %s (dano %d, MP −%d)." % [current.display_name, roll["label"], dmg, cost])
	ui_refresh.emit()
	busy = false
	notify_player_action_finished()


func player_use_item(item_id: String = "pocao") -> void:
	if phase != Phase.PLAYER_TURN or busy or current == null:
		return
	if item_id not in current.items and not current.items.is_empty():
		item_id = current.items[0]
	if current.items.is_empty():
		battle_log.emit("%s não tem itens." % current.display_name)
		return
	busy = true
	AudioManager.sfx_item()
	current.items.erase(item_id)
	var heal_extra := GameState.heal_item_bonus(current.class_id)
	match item_id:
		"pocao":
			current.heal(12 + heal_extra)
			AudioManager.sfx_heal()
			battle_log.emit("%s usa Poção (+%d HP)." % [current.display_name, 12 + heal_extra])
		"semente":
			current.restore_mp(8)
			current.heal(4 + heal_extra)
			AudioManager.sfx_heal()
			battle_log.emit("%s usa Semente de Mylune (+%d HP, +8 MP)." % [current.display_name, 4 + heal_extra])
		_:
			current.heal(6 + heal_extra)
			battle_log.emit("%s usa %s." % [current.display_name, item_id])
	ui_refresh.emit()
	busy = false
	notify_player_action_finished()


func _env_bonus_for(c: Combatant) -> int:
	var base := 0
	match String(c.class_id):
		"warrior":
			base = maxi(0, int(env_dice.get("TERRA", 10)) / 5 - 1)
		"druid":
			base = maxi(0, int(env_dice.get("GELO", 6)) / 5)
		"mage":
			base = maxi(0, int(env_dice.get("FOGO", 8)) / 4 - 1)
		_:
			base = 0
	var elem := "TERRA"
	match String(c.class_id):
		"druid":
			elem = "GELO"
		"mage":
			elem = "FOGO"
	return int(round(float(base) * GameState.env_mult(c.class_id, elem)))


func _enemy_act(enemy: Combatant) -> void:
	var targets := _alive(true)
	if targets.is_empty():
		return
	targets.sort_custom(func(a: Combatant, b: Combatant) -> bool: return a.hp < b.hp)
	var target: Combatant = targets[0]
	# Golem troca melee/spell
	var kind := enemy.attack_kind
	if enemy.id == &"golem" and turn_number % 2 == 0:
		kind = &"spell"
		enemy.skill_name = "Descarga Corrompida"
	elif enemy.id == &"golem":
		enemy.skill_name = "Punho de Sucata"
		kind = &"melee"
	var roll := enemy.attack_roll(rng)
	pending_damage = int(roll["total"])
	pending_attacker = enemy
	pending_target = target
	pending_attack_kind = kind
	last_roll_label = str(roll["label"])
	var kind_txt := "golpe" if kind == &"melee" else "feitiço"
	if kind == &"spell":
		AudioManager.play_sfx("Magic4", 0.95, -2.0)
	else:
		AudioManager.play_sfx("Blow5", 0.9, -2.0)
	battle_log.emit(
		"%s prepara %s [%s] em %s! (%s)"
		% [enemy.display_name, kind_txt, enemy.skill_name, target.display_name, roll["label"]]
	)
	phase = Phase.REACTION
	var mode := ReactionWindow.Mode.SPELL if kind == &"spell" else ReactionWindow.Mode.MELEE
	reaction.begin(
		0.85,
		GameState.parry_window_bonus,
		mode,
		GameState.dodge_window_bonus,
		GameState.spell_window_bonus
	)
	reaction_started.emit(reaction)
	while reaction.open:
		if Input.is_action_just_pressed("react"):
			reaction.register_press(&"auto")
		if Input.is_action_just_pressed("react_guard"):
			reaction.register_press(&"guard")
		if Input.is_action_just_pressed("react_dodge"):
			reaction.register_press(&"dodge")
		if Input.is_action_just_pressed("react_counter"):
			reaction.register_press(&"counter")
		if Input.is_action_just_pressed("react_counterspell"):
			reaction.register_press(&"counterspell")
		if reaction.tick(get_process_delta_time()):
			break
		await get_tree().process_frame
	var result := reaction.evaluate()
	reaction_ended.emit(result)
	_resolve_reaction(result)
	ui_refresh.emit()


func register_reaction_choice(action: StringName) -> void:
	if phase == Phase.REACTION and reaction.open:
		reaction.register_press(action)


func _resolve_reaction(result: ReactionWindow.Result) -> void:
	if pending_attacker == null or pending_target == null:
		return
	match result:
		ReactionWindow.Result.DODGE:
			AudioManager.sfx_dodge()
			battle_log.emit("Esquiva! %s evita todo o dano." % pending_target.display_name)
		ReactionWindow.Result.GUARD:
			AudioManager.sfx_guard()
			var mit := 0.4 - GameState.guard_extra_mitigation(pending_target.class_id)
			mit = clampf(mit, 0.2, 0.5)
			var reduced := maxi(1, int(pending_damage * mit))
			pending_target.take_damage(reduced)
			battle_log.emit("Guardar! Dano reduzido para %d." % reduced)
		ReactionWindow.Result.PARRY:
			AudioManager.sfx_guard()
			var reduced := maxi(1, int(pending_damage * 0.35))
			pending_target.take_damage(reduced)
			battle_log.emit("Aparo! Dano %d." % reduced)
		ReactionWindow.Result.PERFECT_PARRY:
			AudioManager.sfx_counter()
			var reduced := maxi(1, int(pending_damage * 0.15))
			pending_target.take_damage(reduced)
			var counter := pending_target.attack_roll(rng)
			var cdmg: int = int(float(counter["total"]) * GameState.counter_damage_mult(pending_target.class_id))
			pending_attacker.take_damage(cdmg)
			battle_log.emit(
				"Contra-ataque! Dano %d + retaliação %s (%d) sem gastar turno."
				% [reduced, counter["label"], cdmg]
			)
		ReactionWindow.Result.COUNTERSPELL:
			AudioManager.sfx_counterspell()
			battle_log.emit("Contra-feitiço! %s anula a magia." % pending_target.display_name)
			if pending_target.class_id == &"mage" or pending_target.id == &"magus":
				var reflect := DiceEngine.roll_damage(1, 4, 2 + GameState.reflect_bonus(pending_target.class_id), rng)
				var rdmg: int = int(reflect["total"])
				pending_attacker.take_damage(rdmg)
				battle_log.emit("Reflexo Arcano %s → %d no inimigo." % [reflect["label"], rdmg])
		_:
			AudioManager.sfx_miss()
			pending_target.take_damage(pending_damage)
			AudioManager.sfx_damage()
			battle_log.emit("Sem reação… %s sofre %d." % [pending_target.display_name, pending_damage])
	if pending_target.id == &"hero":
		GameState.current_hp = pending_target.hp
	pending_attacker = null
	pending_target = null
	pending_damage = 0
	phase = Phase.ENEMY_TURN
