extends Node

## Loop de batalha: turnos + reações + classes de `docs/classes.md`.

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
var ritual_mode: bool = false ## mago: Magia como 1d20


func setup_encounter(p_id: String = "") -> void:
	rng.randomize()
	encounter_id = p_id if p_id != "" else GameState.pending_encounter
	if encounter_id == "":
		encounter_id = "trilha"
	combatants.clear()
	turn_number = 1
	ritual_mode = false
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
	var pool := ClassRules.pool_count(&"warrior", GameState.player_level)
	var c := Combatant.new(
		&"hero", GameState.player_name, true,
		GameState.max_hp, 12, pool, ClassRules.base_die(&"warrior"), 2, Color(0.85, 0.35, 0.3)
	)
	c.hp = clampi(GameState.current_hp, 1, GameState.max_hp)
	c.max_hp = GameState.max_hp
	c.level = GameState.player_level
	c.sprite_key = "otto"
	c.flat_bonus = 2 + GameState.player_level / 2
	c.configure_class(&"warrior")
	c.items = ["pocao"]
	GameState.apply_combatant_skills(c)
	return c


func _make_mira() -> Combatant:
	var pool := ClassRules.pool_count(&"druid", GameState.player_level)
	var c := Combatant.new(
		&"mira", "Mira", true, 28 + GameState.player_level * 2, 14,
		pool, ClassRules.base_die(&"druid"), 1, Color(0.35, 0.75, 0.4)
	)
	c.sprite_key = "lyra"
	c.level = GameState.player_level
	c.configure_class(&"druid")
	c.items = ["pocao", "semente"]
	GameState.apply_combatant_skills(c)
	return c


func _make_magus() -> Combatant:
	var pool := ClassRules.pool_count(&"mage", GameState.player_level)
	var c := Combatant.new(
		&"magus", "Magus", true, 24 + GameState.player_level, 11,
		pool, ClassRules.base_die(&"mage"), 2, Color(0.65, 0.45, 0.9)
	)
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
			## Power Defense / War Cry armadura expira no início do próprio turno
			actor.armor_bonus = 0
			if actor.stunned:
				actor.stunned = false
				battle_log.emit("%s está atordoado e perde o turno!" % actor.display_name)
				ui_refresh.emit()
				continue
			if actor.is_player_side:
				skill_preview.emit(actor.skill_name, actor.skill_formula)
			ui_refresh.emit()
			timeline_changed.emit(_timeline_payload())
			if actor.is_player_side:
				phase = Phase.PLAYER_TURN
				player_actions_enabled.emit(true)
				var form_txt := ""
				if actor.class_id == &"druid":
					form_txt = " · %s" % ClassRules.form_label(actor.form)
				battle_log.emit("Turno de %s (%s%s · %s)." % [
					actor.display_name, actor.class_label(), form_txt, actor.die_label()
				])
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


func _apply_hit_effects(attacker: Combatant, target: Combatant, roll: Dictionary) -> void:
	if bool(roll.get("crit", false)):
		var bonus := GameState.crit_ally_bonus(attacker.class_id)
		if bonus > 0:
			for ally in _alive(true):
				if ally.id != attacker.id:
					ally.next_die_bonus += bonus
			battle_log.emit("Crítico Brutal! Aliados +%d no próximo dado." % bonus)
	if bool(roll.get("max_face", false)) and attacker.class_id == &"warrior" and target.is_alive():
		target.stunned = true
		battle_log.emit("Máximo no d10! %s fica Atordoado." % target.display_name)
	if bool(roll.get("max_face", false)) and attacker.class_id == &"mage" and GameState.effect_sum("element_burn", &"mage") > 0:
		target.next_die_bonus -= 2 ## queimadura: piora próximo ataque do alvo
		battle_log.emit("Queimadura! %s sofre debuff." % target.display_name)
	if GameState.effect_sum("element_freeze", attacker.class_id) > 0 and attacker.class_id == &"mage":
		target.speed = maxi(1, target.speed - 2)


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
	dmg += _env_bonus_for(current)
	var stood := target.take_damage(dmg)
	if stood:
		battle_log.emit("Último Fôlego! %s se ergue com %d PV." % [target.display_name, target.hp])
	else:
		AudioManager.sfx_damage()
	last_roll_label = str(roll["label"])
	battle_log.emit(
		"ROLANDO DADOS… %s usa [%s] em %s — %s (+amb %d) = %d"
		% [current.display_name, current.skill_name, target.display_name, roll["label"], _env_bonus_for(current), dmg]
	)
	_apply_hit_effects(current, target, roll)
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
	var roll: Dictionary
	## Mago: elemental Nd4; Ritual 1d20 se armado
	if current.class_id == &"mage":
		if ritual_mode and GameState.has_ritual(&"mage"):
			roll = DiceEngine.roll_damage(1, 20, current.flat_bonus, rng, {"allow_crit": false})
			ritual_mode = false
			var raw: int = int(roll["total"])
			## Alto = explosão; baixo = risco (dano em si)
			if raw >= 15:
				battle_log.emit("Ritual ALTO (%s)! Explosão catastrófica." % roll["label"])
			elif raw <= 5:
				var backlash := maxi(1, raw)
				current.take_damage(backlash)
				battle_log.emit("Ritual FALHO (%s)! Backlash %d em Magus." % [roll["label"], backlash])
		else:
			roll = DiceEngine.roll_damage(
				current.dice_count, 4, current.flat_bonus + 2, rng,
				{"force_max_first": current.force_max_first}
			)
	elif current.class_id == &"druid":
		## Cura em aliado mais ferido se humana; dano em forma animal
		if current.form == &"human":
			var allies := _alive(true)
			allies.sort_custom(func(a: Combatant, b: Combatant) -> bool: return a.hp < b.hp)
			var heal_target: Combatant = allies[0] if not allies.is_empty() else current
			roll = DiceEngine.roll_damage(current.dice_count, 6, current.flat_bonus + GameState.heal_item_bonus(&"druid"), rng)
			heal_target.heal(int(roll["total"]))
			AudioManager.sfx_heal()
			last_roll_label = str(roll["label"])
			battle_log.emit("%s conjura MAGIA NATURAL — cura %s (%s, MP −%d)." % [
				current.display_name, heal_target.display_name, roll["label"], cost
			])
			ui_refresh.emit()
			busy = false
			notify_player_action_finished()
			return
		else:
			roll = DiceEngine.roll_damage(current.dice_count, current.dice_sides, current.flat_bonus + 2, rng, current.attack_opts())
	else:
		roll = DiceEngine.roll_damage(1, 10, current.flat_bonus + 2, rng, current.attack_opts())
		if GameState.warrior_magic_free():
			roll["total"] = int(roll["total"]) + 5
	var dmg: int = int(roll["total"]) + _env_bonus_for(current)
	target.take_damage(dmg)
	AudioManager.sfx_damage()
	last_roll_label = str(roll["label"])
	battle_log.emit("%s conjura MAGIA — %s (dano %d, MP −%d)." % [current.display_name, roll["label"], dmg, cost])
	_apply_hit_effects(current, target, roll)
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


func player_arm_power_attack() -> void:
	if phase != Phase.PLAYER_TURN or busy or current == null:
		return
	if not GameState.has_power_attack(current.class_id):
		battle_log.emit("Power Attack não desbloqueado.")
		return
	current.power_attack_armed = true
	battle_log.emit("%s arma Power Attack (+1 dado de dano no próximo golpe)." % current.display_name)
	ui_refresh.emit()


func player_power_defense() -> void:
	if phase != Phase.PLAYER_TURN or busy or current == null:
		return
	if not GameState.has_power_defense(current.class_id):
		battle_log.emit("Power Defense não desbloqueado.")
		return
	busy = true
	current.armor_bonus += current.dice_sides
	battle_log.emit(
		"%s Power Defense — armadura +%d até o próximo turno."
		% [current.display_name, current.dice_sides]
	)
	ui_refresh.emit()
	busy = false
	notify_player_action_finished()


func player_war_cry() -> void:
	if phase != Phase.PLAYER_TURN or busy or current == null:
		return
	if not GameState.has_war_cry(current.class_id):
		battle_log.emit("War Cry não desbloqueado.")
		return
	busy = true
	var bonus := current.dice_count * 2
	for ally in _alive(true):
		ally.armor_bonus += bonus
	battle_log.emit("%s War Cry! Defesa do grupo +%d (sacrifica o ataque do turno)." % [current.display_name, bonus])
	ui_refresh.emit()
	busy = false
	notify_player_action_finished()


func player_shift_form(form: StringName) -> void:
	if phase != Phase.PLAYER_TURN or busy or current == null:
		return
	if current.class_id != &"druid":
		return
	if current.set_form(form):
		battle_log.emit("%s assume Forma %s (%s)." % [current.display_name, ClassRules.form_label(form), current.die_label()])
		skill_preview.emit(current.skill_name, current.skill_formula)
		ui_refresh.emit()
	else:
		battle_log.emit("Forma bloqueada — desbloqueie na árvore (Metamorfose).")


func player_toggle_ritual() -> void:
	if phase != Phase.PLAYER_TURN or current == null:
		return
	if not GameState.has_ritual(&"mage") or current.class_id != &"mage":
		battle_log.emit("Ritual d20 não desbloqueado.")
		return
	ritual_mode = not ritual_mode
	battle_log.emit("Ritual d20: %s (próxima Magia)." % ("ARMADO" if ritual_mode else "desligado"))
	ui_refresh.emit()


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
	var dodge_bonus := GameState.dodge_window_bonus
	var parry_bonus := GameState.parry_window_bonus
	## Druida: pantera amplia esquiva; urso amplia aparo
	if target.class_id == &"druid":
		if target.form == &"panther":
			dodge_bonus += 0.12
		elif target.form == &"bear":
			parry_bonus += 0.12
	reaction.begin(
		0.85,
		parry_bonus,
		mode,
		dodge_bonus,
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


func _do_counter(from: Combatant, to: Combatant) -> void:
	var counter := from.attack_roll(rng)
	## Sinergia guerreiro: aparo perfeito concede +2 no próximo d10 — aplicado no counter
	if from.class_id == &"warrior":
		counter["total"] = int(counter["total"]) + 2
	var cdmg: int = int(float(counter["total"]) * GameState.counter_damage_mult(from.class_id))
	to.take_damage(cdmg)
	battle_log.emit("Contra-ataque! %s (%d) sem gastar turno." % [counter["label"], cdmg])


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
			if pending_target.take_damage(reduced):
				battle_log.emit("Último Fôlego! %s se ergue." % pending_target.display_name)
			battle_log.emit("Guardar! Dano reduzido para %d." % reduced)
		ReactionWindow.Result.PARRY:
			AudioManager.sfx_guard()
			var reduced := maxi(1, int(pending_damage * 0.35))
			pending_target.take_damage(reduced)
			battle_log.emit("Aparo! Dano %d." % reduced)
			if GameState.parry_heals(pending_target.class_id):
				var heal_roll := DiceEngine.roll(1, pending_target.dice_sides, rng)
				pending_target.heal(int(heal_roll["total"]))
				battle_log.emit("Defesa Sólida: +%s PV." % heal_roll["label"])
			if GameState.parry_allows_counter(pending_target.class_id) and pending_attack_kind == &"melee":
				AudioManager.sfx_counter()
				_do_counter(pending_target, pending_attacker)
		ReactionWindow.Result.PERFECT_PARRY:
			AudioManager.sfx_counter()
			var reduced := maxi(1, int(pending_damage * 0.15))
			pending_target.take_damage(reduced)
			if GameState.parry_heals(pending_target.class_id):
				var heal_roll := DiceEngine.roll(1, pending_target.dice_sides, rng)
				pending_target.heal(int(heal_roll["total"]))
				battle_log.emit("Defesa Sólida: +%s PV." % heal_roll["label"])
			pending_target.next_die_bonus += 2 ## sinergia guerreiro aparo perfeito
			_do_counter(pending_target, pending_attacker)
			battle_log.emit(
				"Aparo perfeito! Dano %d + retaliação. Próximo d10 +2."
				% reduced
			)
		ReactionWindow.Result.COUNTERSPELL:
			AudioManager.sfx_counterspell()
			battle_log.emit("Contra-feitiço! %s anula a magia." % pending_target.display_name)
			if pending_target.class_id == &"mage" or pending_target.id == &"magus":
				var reflect := DiceEngine.roll_damage(1, 4, 2 + GameState.reflect_bonus(pending_target.class_id), rng)
				var rdmg: int = int(reflect["total"])
				pending_attacker.take_damage(rdmg)
				var mp_gain := GameState.counterspell_mp_restore(pending_target.class_id)
				if mp_gain > 0:
					pending_target.restore_mp(mp_gain)
				battle_log.emit("Reflexo Arcano %s → %d no inimigo (+%d MP)." % [reflect["label"], rdmg, mp_gain])
				if GameState.effect_sum("silence_on_cspell", &"mage") > 0:
					pending_attacker.stunned = true
					battle_log.emit("%s silenciado!" % pending_attacker.display_name)
		_:
			AudioManager.sfx_miss()
			if pending_target.take_damage(pending_damage):
				battle_log.emit("Último Fôlego! %s se ergue com %d PV." % [pending_target.display_name, pending_target.hp])
			else:
				AudioManager.sfx_damage()
				battle_log.emit("Sem reação… %s sofre %d." % [pending_target.display_name, pending_damage])
	if pending_target.id == &"hero":
		GameState.current_hp = pending_target.hp
	pending_attacker = null
	pending_target = null
	pending_damage = 0
	phase = Phase.ENEMY_TURN
