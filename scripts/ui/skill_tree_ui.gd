extends CanvasLayer

## Árvore de skills por classe/ramos — `docs/classes.md`.

signal closed

@onready var points_l: Label = %PointsLabel
@onready var class_tabs: HBoxContainer = %ClassTabs
@onready var tree_box: VBoxContainer = %TreeBox
@onready var detail_title: Label = %DetailTitle
@onready var detail_body: RichTextLabel = %DetailBody
@onready var unlock_btn: Button = %UnlockBtn
@onready var close_btn: Button = %CloseBtn

var _class: StringName = &"warrior"
var _selected: StringName = &""


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	close_btn.pressed.connect(hide_tree)
	unlock_btn.pressed.connect(_on_unlock)
	GameState.skill_points_changed.connect(func(_p): _refresh())
	GameState.skills_changed.connect(_refresh)
	GameState.party_changed.connect(_rebuild_tabs)


func open_tree(preferred_class: StringName = &"") -> void:
	visible = true
	get_tree().paused = true
	AudioManager.sfx_ui_confirm()
	if preferred_class != &"" and preferred_class in GameState.available_classes():
		_class = preferred_class
	else:
		var classes := GameState.available_classes()
		_class = classes[0] if not classes.is_empty() else &"warrior"
	_rebuild_tabs()
	_refresh()
	close_btn.grab_focus()


func hide_tree() -> void:
	AudioManager.sfx_ui_cancel()
	visible = false
	get_tree().paused = false
	closed.emit()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("skill_tree"):
		hide_tree()
		get_viewport().set_input_as_handled()


func _rebuild_tabs() -> void:
	for c in class_tabs.get_children():
		c.queue_free()
	for cid in GameState.available_classes():
		var b := Button.new()
		b.text = SkillCatalog.class_label(cid)
		b.toggle_mode = true
		b.button_pressed = cid == _class
		var captured: StringName = cid
		b.pressed.connect(func():
			_class = captured
			_selected = &""
			AudioManager.sfx_ui_cursor()
			_rebuild_tabs()
			_refresh()
		)
		class_tabs.add_child(b)


func _refresh() -> void:
	points_l.text = "Skill Points: %d  ·  Nv.%d  ·  %s" % [
		GameState.skill_points, GameState.player_level, ClassRules.class_blurb(_class)
	]
	for c in tree_box.get_children():
		c.queue_free()

	## Agrupa por ramo, depois por tier
	var by_branch: Dictionary = {}
	for def in SkillCatalog.defs_for(_class):
		var bkey := String(def.branch)
		if not by_branch.has(bkey):
			by_branch[bkey] = []
		by_branch[bkey].append(def)

	var branch_order: PackedStringArray = ["core", "vanguard", "executor", "restoration", "metamorph", "elemental", "nullify"]
	var ordered_keys: PackedStringArray = []
	for key in branch_order:
		if by_branch.has(key):
			ordered_keys.append(key)
	for key in by_branch.keys():
		if key not in ordered_keys:
			ordered_keys.append(key)

	for bkey in ordered_keys:
		var branch_title := Label.new()
		branch_title.text = "▸ %s" % ClassRules.branch_label(StringName(bkey))
		branch_title.add_theme_color_override("font_color", Color(0.85, 0.75, 0.45))
		tree_box.add_child(branch_title)

		var by_tier: Dictionary = {}
		for def in by_branch[bkey]:
			if not by_tier.has(def.tier):
				by_tier[def.tier] = []
			by_tier[def.tier].append(def)
		var tiers: Array = by_tier.keys()
		tiers.sort()
		for tier in tiers:
			var row := HBoxContainer.new()
			row.alignment = BoxContainer.ALIGNMENT_CENTER
			row.add_theme_constant_override("separation", 10)
			var tier_l := Label.new()
			tier_l.text = "T%d" % int(tier)
			tier_l.custom_minimum_size = Vector2(36, 0)
			row.add_child(tier_l)
			for def in by_tier[tier]:
				row.add_child(_make_node_button(def))
			tree_box.add_child(row)

	_update_detail()


func _make_node_button(def: SkillDef) -> Button:
	var b := Button.new()
	b.custom_minimum_size = Vector2(168, 68)
	var unlocked := GameState.has_skill(def.id)
	var can := GameState.can_unlock_skill(def.id)
	var cost_txt := "grátis" if def.cost <= 0 else "%d SP" % def.cost
	b.text = "%s\n(%s · Nv.%d)" % [def.display_name, cost_txt, def.level_req]
	if unlocked:
		b.modulate = Color(0.55, 0.95, 0.65)
		b.disabled = false
	elif can:
		b.modulate = Color(0.95, 0.88, 0.45)
	else:
		b.modulate = Color(0.55, 0.55, 0.6)
	b.button_pressed = def.id == _selected
	b.toggle_mode = true
	var sid: StringName = def.id
	b.pressed.connect(func():
		_selected = sid
		AudioManager.sfx_ui_cursor()
		_refresh()
	)
	return b


func _update_detail() -> void:
	if _selected == &"":
		detail_title.text = SkillCatalog.class_label(_class)
		detail_body.text = (
			"%s\n\nSelecione um nó. Amarelo = pode desbloquear. Verde = já aprendido.\nRamos conforme docs/classes.md."
			% ClassRules.class_blurb(_class)
		)
		unlock_btn.disabled = true
		return
	var def := SkillCatalog.get_def(_selected)
	if def == null:
		return
	detail_title.text = def.display_name
	var status := "BLOQUEADO"
	if GameState.has_skill(def.id):
		status = "DESBLOQUEADO"
	elif GameState.can_unlock_skill(def.id):
		status = "DISPONÍVEL"
	var fx_lines: PackedStringArray = []
	for k in def.effects.keys():
		fx_lines.append("• %s: %s" % [k, str(def.effects[k])])
	var prereq := "—"
	if not def.prerequisites.is_empty():
		var names: PackedStringArray = []
		for p in def.prerequisites:
			var pd := SkillCatalog.get_def(p)
			names.append(pd.display_name if pd else String(p))
		prereq = ", ".join(names)
	detail_body.text = (
		"[b]%s[/b] · Ramo %s\nNv. mín %d · Custo %d SP\nPré: %s\n\n%s\n\nEfeitos:\n%s"
		% [status, ClassRules.branch_label(def.branch), def.level_req, def.cost, prereq, def.description, "\n".join(fx_lines)]
	)
	unlock_btn.disabled = not GameState.can_unlock_skill(def.id)


func _on_unlock() -> void:
	if _selected == &"":
		return
	if GameState.unlock_skill(_selected):
		AudioManager.sfx_ui_confirm()
		_refresh()
