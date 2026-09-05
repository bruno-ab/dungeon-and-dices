extends Control

## UI de batalha inspirada no mockup DADO & LÂMINA.

@onready var battle: Node = $BattleController
@onready var battleback: TextureRect = $Battleback
@onready var timeline_row: HBoxContainer = $UI/TopBar/TimelineRow
@onready var title_l: Label = $UI/TopBar/TitleLabel
@onready var stage: Control = $UI/Stage
@onready var env_l: Label = $UI/Dashboard/Margin/VBox/EnvStrip
@onready var class_l: Label = $UI/Dashboard/Margin/VBox/DashRow/LeftCol/ClassLabel
@onready var skill_l: Label = $UI/Dashboard/Margin/VBox/DashRow/CenterCol/SkillName
@onready var formula_l: Label = $UI/Dashboard/Margin/VBox/DashRow/CenterCol/SkillFormula
@onready var party_col: VBoxContainer = $UI/Dashboard/Margin/VBox/DashRow/PartyCol
@onready var log_box: RichTextLabel = $UI/Dashboard/Margin/VBox/LogBar
@onready var reaction_bar: ProgressBar = $UI/ReactionBar
@onready var reaction_hint: Label = $UI/ReactionHint
@onready var btn_guard: Button = $UI/Dashboard/Margin/VBox/DashRow/LeftCol/ReactRow/Guard
@onready var btn_dodge: Button = $UI/Dashboard/Margin/VBox/DashRow/LeftCol/ReactRow/Dodge
@onready var btn_counter: Button = $UI/Dashboard/Margin/VBox/DashRow/LeftCol/ReactRow/Counter
@onready var btn_cspell: Button = $UI/Dashboard/Margin/VBox/DashRow/LeftCol/ReactRow/Counterspell
@onready var btn_attack: Button = $UI/Dashboard/Margin/VBox/DashRow/CenterCol/AttackBtn
@onready var btn_magic: Button = $UI/Dashboard/Margin/VBox/DashRow/CenterCol/SubRow/Magic
@onready var btn_item: Button = $UI/Dashboard/Margin/VBox/DashRow/CenterCol/SubRow/Item
@onready var btn_flee: Button = $UI/Dashboard/Margin/VBox/DashRow/CenterCol/SubRow/Flee
@onready var targets_row: HBoxContainer = $UI/Dashboard/Margin/VBox/DashRow/CenterCol/Targets
@onready var end_panel: PanelContainer = $UI/EndPanel
@onready var end_label: Label = $UI/EndPanel/VBox/EndLabel
@onready var btn_return: Button = $UI/EndPanel/VBox/ReturnBtn

var _stage_sprites: Dictionary = {}
var _actions_on: bool = false


func _ready() -> void:
	end_panel.visible = false
	reaction_bar.visible = false
	reaction_hint.visible = false
	title_l.text = GameState.GAME_TITLE
	battle.battle_log.connect(_append_log)
	battle.ui_refresh.connect(_refresh)
	battle.player_actions_enabled.connect(_set_actions)
	battle.reaction_started.connect(_on_reaction_started)
	battle.reaction_ended.connect(_on_reaction_ended)
	battle.battle_finished.connect(_on_battle_finished)
	battle.timeline_changed.connect(_on_timeline)
	battle.skill_preview.connect(_on_skill_preview)
	battle.env_changed.connect(_on_env)
	battle.turn_index_changed.connect(func(n: int): env_l.text = _env_text(battle.env_dice, n))

	btn_attack.pressed.connect(func():
		AudioManager.sfx_ui_confirm()
		battle.player_attack()
	)
	btn_guard.pressed.connect(_on_guard_pressed)
	btn_dodge.pressed.connect(func():
		AudioManager.sfx_ui_confirm()
		battle.register_reaction_choice(&"dodge")
	)
	btn_counter.pressed.connect(func():
		AudioManager.sfx_ui_confirm()
		battle.register_reaction_choice(&"counter")
	)
	btn_cspell.pressed.connect(func():
		AudioManager.sfx_ui_confirm()
		battle.register_reaction_choice(&"counterspell")
	)
	btn_magic.pressed.connect(func():
		AudioManager.sfx_ui_confirm()
		battle.player_cast_magic()
	)
	btn_item.pressed.connect(func():
		AudioManager.sfx_ui_confirm()
		battle.player_use_item()
	)
	btn_flee.pressed.connect(_flee)
	btn_return.pressed.connect(func():
		AudioManager.sfx_ui_confirm()
		SceneRouter.go_hub()
	)

	_set_actions(false)
	battle.setup_encounter(GameState.pending_encounter)
	_apply_battleback()
	_build_stage()
	_refresh()
	battle.start()


func _process(_delta: float) -> void:
	if battle.phase == battle.Phase.REACTION and battle.reaction.open:
		reaction_bar.value = battle.reaction.progress() * 100.0


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("skill_tree") and battle.phase != battle.Phase.REACTION:
		SkillTreeUI.open_tree()
		get_viewport().set_input_as_handled()


func _apply_battleback() -> void:
	var meta: Dictionary = EncounterCatalog.meta(battle.encounter_id)
	var path: String = str(meta.get("battleback", ""))
	if path != "" and ResourceLoader.exists(path):
		battleback.texture = load(path) as Texture2D
	battleback.modulate = Color(0.75, 0.78, 0.85, 1)


func _env_text(env: Dictionary, turn: int = 1) -> String:
	return "FOGO: d%d, TERRA: d%d, GELO: d%d  |  TURNO %d" % [
		int(env.get("FOGO", 8)), int(env.get("TERRA", 10)), int(env.get("GELO", 6)), turn
	]


func _on_env(env: Dictionary) -> void:
	env_l.text = _env_text(env, battle.turn_number)


func _on_skill_preview(skill_name: String, formula: String) -> void:
	skill_l.text = "[%s]" % skill_name.to_upper()
	formula_l.text = formula


func _on_timeline(order: Array) -> void:
	for c in timeline_row.get_children():
		c.queue_free()
	var lbl := Label.new()
	lbl.text = "LINHA DO TEMPO"
	lbl.add_theme_color_override("font_color", Color(0.85, 0.75, 0.45))
	timeline_row.add_child(lbl)
	for i in order.size():
		var entry: Dictionary = order[i]
		var chip := Label.new()
		var mark := "★" if entry.get("side", false) else "◆"
		chip.text = "%s %s" % [mark, entry.get("name", "?")]
		if battle.current and String(battle.current.id) == String(entry.get("id", "")):
			chip.add_theme_color_override("font_color", Color(1.0, 0.85, 0.35))
			chip.text = "PRÓXIMO → " + chip.text
		else:
			chip.add_theme_color_override("font_color", Color(0.8, 0.82, 0.88) if entry.get("side", false) else Color(0.75, 0.55, 0.55))
		timeline_row.add_child(chip)


func _append_log(text: String) -> void:
	log_box.append_text("[color=#e8c56a]%s[/color]\n" % text)


func _on_guard_pressed() -> void:
	AudioManager.sfx_ui_confirm()
	if battle.phase == battle.Phase.REACTION:
		battle.register_reaction_choice(&"guard")
	else:
		battle.player_guard()


func _set_actions(enabled: bool) -> void:
	_actions_on = enabled
	btn_attack.disabled = not enabled
	btn_magic.disabled = not enabled
	btn_item.disabled = not enabled
	btn_flee.disabled = not enabled
	# reações ficam ativas só na janela; botões de turno também usam Guard
	btn_guard.disabled = false
	btn_dodge.disabled = false
	btn_counter.disabled = false
	btn_cspell.disabled = false
	_rebuild_targets()


func _rebuild_targets() -> void:
	for c in targets_row.get_children():
		c.queue_free()
	for foe in battle.combatants:
		if foe.is_player_side or not foe.is_alive():
			continue
		var b := Button.new()
		b.text = foe.display_name
		b.toggle_mode = true
		b.button_pressed = foe.id == battle.selected_target_id
		b.disabled = not _actions_on
		var fid: StringName = foe.id
		b.pressed.connect(func(): battle.set_selected_target(fid))
		targets_row.add_child(b)


func _build_stage() -> void:
	for child in stage.get_children():
		child.queue_free()
	_stage_sprites.clear()
	var foes_box := HBoxContainer.new()
	foes_box.add_theme_constant_override("separation", 28)
	foes_box.set_anchors_preset(Control.PRESET_CENTER_LEFT)
	foes_box.position = Vector2(40, 80)
	var allies_box := HBoxContainer.new()
	allies_box.add_theme_constant_override("separation", 28)
	allies_box.position = Vector2(620, 100)
	for c in battle.combatants:
		var holder := VBoxContainer.new()
		var sprite := AnimatedSprite2D.new()
		sprite.sprite_frames = SpriteCatalog.frames_for(c.sprite_key)
		if sprite.sprite_frames.has_animation(&"battle"):
			sprite.play(&"battle")
		elif sprite.sprite_frames.has_animation(&"idle"):
			sprite.play(&"idle")
		sprite.centered = true
		var scale_v := 0.85
		if c.sprite_key in ["serpent_green", "serpent_purple", "golem_corrupt", "trolling"]:
			scale_v = 0.55
		elif c.sprite_key in ["otto", "lyra", "kelvin"]:
			scale_v = 0.95
		elif c.sprite_key == "magus":
			scale_v = 0.45
		sprite.scale = Vector2(scale_v, scale_v)
		var canvas := Control.new()
		canvas.custom_minimum_size = Vector2(110, 120)
		canvas.add_child(sprite)
		sprite.position = Vector2(55, 70)
		var tag := Label.new()
		tag.text = c.display_name
		tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		tag.add_theme_font_size_override("font_size", 14)
		var hpbar := ProgressBar.new()
		hpbar.custom_minimum_size = Vector2(100, 10)
		hpbar.max_value = c.max_hp
		hpbar.value = c.hp
		hpbar.show_percentage = false
		holder.add_child(canvas)
		holder.add_child(hpbar)
		holder.add_child(tag)
		holder.set_meta("hpbar", hpbar)
		_stage_sprites[c.id] = holder
		if c.is_player_side:
			allies_box.add_child(holder)
		else:
			foes_box.add_child(holder)
	stage.add_child(foes_box)
	stage.add_child(allies_box)


func _refresh() -> void:
	for child in party_col.get_children():
		child.queue_free()
	for c in battle.combatants:
		if not c.is_player_side:
			continue
		party_col.add_child(_make_party_card(c))
	# update stage hp bars
	for c in battle.combatants:
		if _stage_sprites.has(c.id):
			var holder: Node = _stage_sprites[c.id]
			if holder.has_meta("hpbar"):
				var bar: ProgressBar = holder.get_meta("hpbar")
				bar.max_value = c.max_hp
				bar.value = c.hp
			holder.modulate = Color(1, 1, 1, 1) if c.is_alive() else Color(0.4, 0.4, 0.45, 0.55)
	if battle.current and battle.current.is_player_side:
		class_l.text = battle.current.class_label().to_upper()
		skill_l.text = "[%s]" % battle.current.skill_name.to_upper()
		formula_l.text = battle.current.skill_formula
	_rebuild_targets()
	_on_timeline(battle.timeline_order())


func _make_party_card(c: Combatant) -> PanelContainer:
	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.13, 0.16, 0.92)
	style.border_color = c.color
	style.set_border_width_all(2)
	style.set_content_margin_all(8)
	panel.add_theme_stylebox_override("panel", style)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	var tex := TextureRect.new()
	tex.custom_minimum_size = Vector2(52, 52)
	tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tex.texture = SpriteCatalog.portrait(c.sprite_key)
	if not c.is_alive():
		tex.modulate = Color(0.4, 0.4, 0.45, 0.7)
	var vb := VBoxContainer.new()
	var name_l := Label.new()
	name_l.text = "%s  ·  %s" % [c.display_name, c.class_label()]
	name_l.add_theme_color_override("font_color", c.color)
	var lvl := Label.new()
	lvl.text = "Nv.%d   %s" % [c.level, c.die_label()]
	var hp := ProgressBar.new()
	hp.custom_minimum_size = Vector2(160, 12)
	hp.max_value = c.max_hp
	hp.value = c.hp
	hp.show_percentage = false
	var hp_l := Label.new()
	hp_l.text = "HP %d/%d" % [c.hp, c.max_hp]
	hp_l.add_theme_font_size_override("font_size", 12)
	var mp := ProgressBar.new()
	mp.custom_minimum_size = Vector2(160, 10)
	mp.max_value = maxi(1, c.max_mp)
	mp.value = c.mp
	mp.show_percentage = false
	var mp_l := Label.new()
	mp_l.text = "MP %d/%d" % [c.mp, c.max_mp]
	mp_l.add_theme_font_size_override("font_size", 12)
	vb.add_child(name_l)
	vb.add_child(lvl)
	vb.add_child(hp)
	vb.add_child(hp_l)
	vb.add_child(mp)
	vb.add_child(mp_l)
	row.add_child(tex)
	row.add_child(vb)
	panel.add_child(row)
	return panel


func _on_reaction_started(window: ReactionWindow) -> void:
	reaction_bar.visible = true
	reaction_hint.visible = true
	AudioManager.play_sfx("Skill1", 1.1, -4.0)
	if window.mode == ReactionWindow.Mode.SPELL:
		reaction_hint.text = "FEITIÇO INIMIGO! Contra-feitiço (U / botão) na janela d4"
	else:
		reaction_hint.text = "GOLPE! Guardar (G) · Esquivar (H) · Contra-atacar (J) — ou ESPAÇO"
	reaction_bar.value = 0


func _on_reaction_ended(result: ReactionWindow.Result) -> void:
	reaction_bar.visible = false
	reaction_hint.visible = false
	var names := ["MISS", "DODGE", "PARRY", "PERFECT", "COUNTERSPELL", "GUARD"]
	_append_log("Janela: %s" % names[int(result)])


func _on_battle_finished(won: bool) -> void:
	_set_actions(false)
	end_panel.visible = true
	end_label.text = "Vitória!" if won else "Derrota…"
	if won:
		end_label.text += "\n%s" % GameState.quest_text()
		if GameState.skill_points > 0:
			end_label.text += "\nSP: %d — abra a árvore." % GameState.skill_points
	if not end_panel.get_node_or_null("VBox/SkillsBtn"):
		var skills_btn := Button.new()
		skills_btn.name = "SkillsBtn"
		skills_btn.text = "Árvore de Skills (Tab)"
		skills_btn.pressed.connect(func(): SkillTreeUI.open_tree())
		end_panel.get_node("VBox").add_child(skills_btn)
		end_panel.get_node("VBox").move_child(skills_btn, 1)


func _flee() -> void:
	AudioManager.sfx_flee()
	GameState.last_battle_result = "flee"
	GameState.current_hp = maxi(1, GameState.current_hp - 3)
	SceneRouter.go_hub()
