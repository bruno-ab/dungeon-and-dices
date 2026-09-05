extends Node

## DialogueManager — scripts JSON estilo visual novel + efeitos/flags.

signal dialogue_started(script_id: String)
signal line_shown(speaker: String, text: String)
signal choices_shown(choices: Array)
signal dialogue_finished(script_id: String)

const SCRIPT_DIR := "res://data/dialogue"

var _scripts: Dictionary = {} ## id -> Dictionary
var _active: Dictionary = {}
var _node_id: String = ""
var _script_id: String = ""
var _on_finished: Callable = Callable()
var _busy: bool = false
var _history: Array[Dictionary] = []
var _current_choices: Array = []


func get_current_choices() -> Array:
	return _current_choices


func _ready() -> void:
	_load_all_scripts()


func is_busy() -> bool:
	return _busy


func _load_all_scripts() -> void:
	_scripts.clear()
	var dir := DirAccess.open(SCRIPT_DIR)
	if dir == null:
		push_warning("Dialogue folder missing: %s" % SCRIPT_DIR)
		return
	dir.list_dir_begin()
	var fname := dir.get_next()
	while fname != "":
		if fname.ends_with(".json"):
			var path := "%s/%s" % [SCRIPT_DIR, fname]
			var file := FileAccess.open(path, FileAccess.READ)
			if file:
				var parsed: Variant = JSON.parse_string(file.get_as_text())
				if typeof(parsed) == TYPE_DICTIONARY and parsed.has("id"):
					_scripts[str(parsed["id"])] = parsed
				file.close()
		fname = dir.get_next()
	dir.list_dir_end()


func start(script_id: String, on_finished: Callable = Callable()) -> void:
	if _busy:
		return
	if not _scripts.has(script_id):
		_load_all_scripts()
	if not _scripts.has(script_id):
		push_warning("Dialogue script not found: %s" % script_id)
		if on_finished.is_valid():
			on_finished.call()
		return
	_busy = true
	_script_id = script_id
	_active = _scripts[script_id]
	_on_finished = on_finished
	_history.clear()
	var start_id := _resolve_start(_active)
	dialogue_started.emit(script_id)
	_goto(start_id)


func start_linear(speaker: String, lines: PackedStringArray, portrait: String = "", on_finished: Callable = Callable()) -> void:
	## Compat: sequência simples sem JSON.
	var nodes := {}
	for i in lines.size():
		var nid := "n%d" % i
		var node := {"speaker": speaker, "text": lines[i], "portrait": portrait}
		if i < lines.size() - 1:
			node["next"] = "n%d" % (i + 1)
		else:
			node["next"] = "end"
		nodes[nid] = node
	nodes["end"] = {"end": true}
	_scripts["__linear"] = {
		"id": "__linear",
		"speaker": speaker,
		"portrait": portrait,
		"default_start": "n0",
		"nodes": nodes,
	}
	start("__linear", on_finished)


func _resolve_start(script: Dictionary) -> String:
	var rules: Array = script.get("start_rules", [])
	for rule in rules:
		if typeof(rule) != TYPE_DICTIONARY:
			continue
		var cond: Dictionary = rule.get("if", {})
		if _eval_condition(cond, script.get("id", "")):
			return str(rule.get("goto", script.get("default_start", "hub")))
	return str(script.get("default_start", "hub"))


func _goto(node_id: String) -> void:
	_node_id = node_id
	if node_id == "" or node_id == "end":
		_finish()
		return
	var nodes: Dictionary = _active.get("nodes", {})
	if not nodes.has(node_id):
		push_warning("Missing dialogue node %s in %s" % [node_id, _script_id])
		_finish()
		return
	var node: Dictionary = nodes[node_id]
	if bool(node.get("end", false)):
		_apply_effects(node.get("effects", []))
		_finish()
		return
	_apply_effects(node.get("effects", []))
	var speaker := str(node.get("speaker", _active.get("speaker", "?")))
	var portrait := str(node.get("portrait", _active.get("portrait", "")))
	var text := _format_text(str(node.get("text", "…")))
	_history.append({"speaker": speaker, "text": text})
	var ui := _ui()
	if ui and ui.has_method("show_vn_line"):
		var choices := _filter_choices(node.get("choices", []))
		_current_choices = choices
		ui.show_vn_line(speaker, text, portrait, choices)
		line_shown.emit(speaker, text)
		if not choices.is_empty():
			choices_shown.emit(choices)
	elif node.has("next"):
		## Sem UI: avança automaticamente (fallback)
		_goto(str(node["next"]))
	else:
		_finish()


func continue_line() -> void:
	if not _busy:
		return
	var nodes: Dictionary = _active.get("nodes", {})
	if not nodes.has(_node_id):
		_finish()
		return
	var node: Dictionary = nodes[_node_id]
	if node.has("choices"):
		return ## precisa escolher
	if node.has("next"):
		_goto(str(node["next"]))
	else:
		_finish()


func select_choice(index: int) -> void:
	if not _busy:
		return
	var choices := _current_choices
	if index < 0 or index >= choices.size():
		return
	var choice: Dictionary = choices[index]
	_current_choices = []
	_apply_effects(choice.get("effects", []))
	_goto(str(choice.get("next", "end")))


func _filter_choices(raw: Variant) -> Array:
	var out: Array = []
	if typeof(raw) != TYPE_ARRAY:
		return out
	for c in raw:
		if typeof(c) != TYPE_DICTIONARY:
			continue
		var cond: Dictionary = c.get("if", {})
		if cond.is_empty() or _eval_condition(cond, _script_id):
			out.append(c)
	return out


func _eval_condition(cond: Dictionary, npc_id: String) -> bool:
	if cond.is_empty():
		return true
	if cond.has("flag_true") and not GameState.has_dialogue_flag(str(cond["flag_true"])):
		return false
	if cond.has("flag_false") and GameState.has_dialogue_flag(str(cond["flag_false"])):
		return false
	if cond.has("flags_true"):
		for f in cond["flags_true"]:
			if not GameState.has_dialogue_flag(str(f)):
				return false
	if cond.has("flags_false"):
		for f in cond["flags_false"]:
			if GameState.has_dialogue_flag(str(f)):
				return false
	if cond.has("met_elder") and GameState.met_elder != bool(cond["met_elder"]):
		return false
	if cond.has("recruited_mira") and GameState.recruited_mira != bool(cond["recruited_mira"]):
		return false
	if cond.has("recruited_magus") and GameState.recruited_magus != bool(cond["recruited_magus"]):
		return false
	if cond.has("all_cleared") and GameState.all_encounters_cleared() != bool(cond["all_cleared"]):
		return false
	if cond.has("cleared_mylune") and GameState.cleared_mylune != bool(cond["cleared_mylune"]):
		return false
	if cond.has("talk_count_gte") and GameState.npc_talk_count(npc_id) < int(cond["talk_count_gte"]):
		return false
	if cond.has("talk_count_lt") and GameState.npc_talk_count(npc_id) >= int(cond["talk_count_lt"]):
		return false
	return true


func _format_text(text: String) -> String:
	return text.replace("{quest_text}", GameState.quest_text()).replace("{party}", GameState.party_summary())


func _apply_effects(effects: Variant) -> void:
	if typeof(effects) != TYPE_ARRAY:
		return
	for e in effects:
		if typeof(e) != TYPE_DICTIONARY:
			continue
		match str(e.get("type", "")):
			"set_flag":
				GameState.set_dialogue_flag(str(e.get("flag", "")), true)
			"clear_flag":
				GameState.set_dialogue_flag(str(e.get("flag", "")), false)
			"mark_met_elder":
				GameState.mark_met_elder()
				GameState.set_dialogue_flag("met_elder", true)
			"recruit_mira":
				if not GameState.recruited_mira:
					GameState.recruited_mira = true
					GameState.grant_class_seed(&"druid")
					GameState.set_dialogue_flag("recruited_mira", true)
					GameState.party_changed.emit()
					GameState.quest_updated.emit(GameState.quest_text())
			"recruit_magus":
				if not GameState.recruited_magus:
					GameState.recruited_magus = true
					GameState.grant_class_seed(&"mage")
					GameState.set_dialogue_flag("recruited_magus", true)
					GameState.party_changed.emit()
					GameState.quest_updated.emit(GameState.quest_text())
			"heal_full":
				GameState.heal_full()
				GameState.log_message.emit("A estalagem restaurou seu HP.")
				AudioManager.sfx_heal()
			"play_me":
				AudioManager.play_me(str(e.get("track", "Fanfare1")))
			"play_sfx":
				AudioManager.play_sfx(str(e.get("track", "Decision1")))
			"go_phase_complete":
				## defer so UI can close first
				call_deferred("_deferred_phase_complete")
			"grant_sp":
				GameState.skill_points += int(e.get("amount", 1))
				GameState.skill_points_changed.emit(GameState.skill_points)


func _deferred_phase_complete() -> void:
	SceneRouter.go_phase_complete()


func _finish() -> void:
	_busy = false
	var sid := _script_id
	if sid != "" and sid != "__linear":
		GameState.inc_npc_talk(sid)
	var cb := _on_finished
	_script_id = ""
	_node_id = ""
	_active = {}
	_on_finished = Callable()
	var ui := _ui()
	if ui and ui.has_method("close_vn"):
		ui.close_vn()
	dialogue_finished.emit(sid)
	if cb.is_valid():
		cb.call()


func _ui() -> Node:
	return get_tree().get_first_node_in_group("dialogue_box")
