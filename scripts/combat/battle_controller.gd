extends Node

## Controla o loop de batalha: turnos + reações RT.

signal battle_log(text: String)
signal ui_refresh
signal player_actions_enabled(enabled: bool)
signal reaction_started(window: ReactionWindow)
signal reaction_ended(result: ReactionWindow.Result)
signal battle_finished(won: bool)

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
var busy: bool = false


func setup_mvp_encounter() -> void:
	rng.randomize()
	combatants.clear()
	var hero := Combatant.new(
		&"hero",
		GameState.player_name,
		true,
		GameState.current_hp if GameState.current_hp > 0 else GameState.max_hp,
		12,
		GameState.dice_count,
		GameState.dice_sides,
		2,
		Color(0.55, 0.42, 0.78)
	)
	hero.max_hp = GameState.max_hp
	hero.hp = clampi(GameState.current_hp, 1, GameState.max_hp)
	combatants.append(hero)

	if GameState.recruited_mira:
		combatants.append(
			Combatant.new(&"mira", "Mira", true, 28, 14, 1, 8, 1, Color(0.85, 0.65, 0.95))
		)

	combatants.append(
		Combatant.new(&"slime", "Lodo Sombrio", false, 22, 8, 1, 6, 0, Color(0.35, 0.7, 0.4))
	)
	combatants.append(
		Combatant.new(&"shade", "Sombra", false, 18, 11, 1, 8, 1, Color(0.45, 0.4, 0.55))
	)

	_rebuild_turn_queue()
	phase = Phase.BOOT
	battle_log.emit("Combate iniciado. Pool do herói: %dd%d." % [GameState.dice_count, GameState.dice_sides])
	ui_refresh.emit()


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


func _alive(side_player: bool) -> Array[Combatant]:
	var out: Array[Combatant] = []
	for c in combatants:
		if c.is_alive() and c.is_player_side == side_player:
			out.append(c)
	return out


func _check_end() -> bool:
	if _alive(true).is_empty():
		phase = Phase.END
		GameState.current_hp = 0
		GameState.last_battle_result = "defeat"
		battle_log.emit("Derrota… volte ao hub e tente de novo.")
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
		GameState.grant_xp(15)
		battle_log.emit("Vitória! +15 XP.")
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
		for actor in turn_queue:
			if phase == Phase.END:
				return
			if not actor.is_alive():
				continue
			current = actor
			ui_refresh.emit()
			if actor.is_player_side:
				phase = Phase.PLAYER_TURN
				player_actions_enabled.emit(true)
				battle_log.emit("Turno de %s — escolha uma ação." % actor.display_name)
				await _wait_player_action_done()
			else:
				phase = Phase.ENEMY_TURN
				player_actions_enabled.emit(false)
				await _enemy_act(actor)
			if _check_end():
				return
		battle_log.emit("--- fim da rodada ---")


var _player_action_done: bool = false


func _wait_player_action_done() -> void:
	_player_action_done = false
	while not _player_action_done and phase != Phase.END:
		await get_tree().process_frame


func notify_player_action_finished() -> void:
	_player_action_done = true
	player_actions_enabled.emit(false)


func player_attack(target_id: StringName) -> void:
	if phase != Phase.PLAYER_TURN or busy:
		return
	var target := _find(target_id)
	if target == null or not target.is_alive() or target.is_player_side:
		return
	busy = true
	var roll := current.attack_roll(rng)
	var dmg: int = int(roll["total"])
	target.take_damage(dmg)
	battle_log.emit("%s ataca %s — %s (dano %d)" % [current.display_name, target.display_name, roll["label"], dmg])
	ui_refresh.emit()
	busy = false
	notify_player_action_finished()


func player_guard() -> void:
	if phase != Phase.PLAYER_TURN or busy:
		return
	busy = true
	current.flat_bonus = maxi(0, current.flat_bonus) # placeholder
	# Guard: marca flag via flat temporary — usamos meta no combatant via speed hack: heal 2
	current.heal(2)
	battle_log.emit("%s se prepara (recupera 2 HP e aguarda reação)." % current.display_name)
	ui_refresh.emit()
	busy = false
	notify_player_action_finished()


func _enemy_act(enemy: Combatant) -> void:
	var targets := _alive(true)
	if targets.is_empty():
		return
	targets.sort_custom(func(a: Combatant, b: Combatant) -> bool: return a.hp < b.hp)
	var target: Combatant = targets[0]
	var roll := enemy.attack_roll(rng)
	pending_damage = int(roll["total"])
	pending_attacker = enemy
	pending_target = target
	battle_log.emit("%s prepara um golpe em %s! (%s)" % [enemy.display_name, target.display_name, roll["label"]])
	phase = Phase.REACTION
	reaction.begin(0.75, GameState.parry_window_bonus)
	reaction_started.emit(reaction)
	while reaction.open:
		if Input.is_action_just_pressed("react"):
			reaction.register_press()
		if reaction.tick(get_process_delta_time()):
			break
		await get_tree().process_frame
	var result := reaction.evaluate()
	reaction_ended.emit(result)
	_resolve_reaction(result)
	ui_refresh.emit()


func _resolve_reaction(result: ReactionWindow.Result) -> void:
	if pending_attacker == null or pending_target == null:
		return
	match result:
		ReactionWindow.Result.DODGE:
			battle_log.emit("Esquiva! %s evita todo o dano." % pending_target.display_name)
		ReactionWindow.Result.PARRY:
			var reduced := maxi(1, int(pending_damage * 0.35))
			pending_target.take_damage(reduced)
			battle_log.emit("Parry! Dano reduzido para %d." % reduced)
		ReactionWindow.Result.PERFECT_PARRY:
			var reduced := maxi(1, int(pending_damage * 0.15))
			pending_target.take_damage(reduced)
			var counter := pending_target.attack_roll(rng)
			var cdmg: int = int(counter["total"])
			pending_attacker.take_damage(cdmg)
			battle_log.emit(
				"Parry perfeito! Dano %d e contra-ataque %s (%d)."
				% [reduced, counter["label"], cdmg]
			)
		_:
			pending_target.take_damage(pending_damage)
			battle_log.emit("Sem reação… %s sofre %d." % [pending_target.display_name, pending_damage])
	if pending_target.id == &"hero":
		GameState.current_hp = pending_target.hp
	pending_attacker = null
	pending_target = null
	pending_damage = 0
	phase = Phase.ENEMY_TURN
