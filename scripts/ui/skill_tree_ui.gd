extends CanvasLayer

## Árvore de skills por classe — gasta skill points com pré-requisitos.

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
	points_l.text = "Skill Points: %d  ·  Nv.%d" % [GameState.skill_points, GameState.player_level]
	for c in tree_box.get_children():
		c.queue_free()
	var by_tier: Dictionary = {}
	for def in SkillCatalog.defs_for(_class):
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
		if int(tier) < int(tiers[tiers.size() - 1]):
			var arrow := Label.new()
			arrow.text = "↓"
			arrow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			tree_box.add_child(arrow)
	_update_detail()


func _make_node_button(def: SkillDef) -> Button:
	var b := Button.new()
	b.custom_minimum_size = Vector2(160, 64)
	var unlocked := GameState.has_skill(def.id)
	var can := GameState.can_unlock_skill(def.id)
	var prereq_txt := ""
	if not def.prerequisites.is_empty():
		var names: PackedStringArray = []
		for p in def.prerequisites:
			var pd := SkillCatalog.get_def(p)
			names.append(pd.display_name if pd else String(p))
		prereq_txt = "\n← %s" % ", ".join(names)
	b.text = "%s\n(%d SP)%s" % [def.display_name, def.cost, prereq_txt]
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
		detail_body.text = "Selecione um nó. Amarelo = pode desbloquear. Verde = já aprendido."
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
	detail_body.text = (
		"[b]%s[/b]\nNv. mín %d · Custo %d SP\n\n%s\n\nEfeitos:\n%s"
		% [status, def.level_req, def.cost, def.description, "\n".join(fx_lines)]
	)
	unlock_btn.disabled = not GameState.can_unlock_skill(def.id)


func _on_unlock() -> void:
	if _selected == &"":
		return
	if GameState.unlock_skill(_selected):
		AudioManager.sfx_ui_confirm()
		_refresh()
