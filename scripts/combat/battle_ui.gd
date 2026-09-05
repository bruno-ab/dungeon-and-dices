extends Control

@onready var battle: Node = $BattleController
@onready var log_box: RichTextLabel = $UI/Log
@onready var status: Label = $UI/Status
@onready var reaction_bar: ProgressBar = $UI/ReactionBar
@onready var reaction_hint: Label = $UI/ReactionHint
@onready var btn_attack_a: Button = $UI/Actions/AttackA
@onready var btn_attack_b: Button = $UI/Actions/AttackB
@onready var btn_guard: Button = $UI/Actions/Guard
@onready var btn_flee: Button = $UI/Actions/Flee
@onready var portraits: HBoxContainer = $UI/Portraits
@onready var end_panel: PanelContainer = $UI/EndPanel
@onready var end_label: Label = $UI/EndPanel/VBox/EndLabel
@onready var btn_return: Button = $UI/EndPanel/VBox/ReturnBtn


func _ready() -> void:
	end_panel.visible = false
	reaction_bar.visible = false
	reaction_hint.visible = false
	battle.battle_log.connect(_append_log)
	battle.ui_refresh.connect(_refresh)
	battle.player_actions_enabled.connect(_set_actions)
	battle.reaction_started.connect(_on_reaction_started)
	battle.reaction_ended.connect(_on_reaction_ended)
	battle.battle_finished.connect(_on_battle_finished)
	btn_attack_a.pressed.connect(func(): battle.player_attack(&"slime"))
	btn_attack_b.pressed.connect(func(): battle.player_attack(&"shade"))
	btn_guard.pressed.connect(battle.player_guard)
	btn_flee.pressed.connect(_flee)
	btn_return.pressed.connect(SceneRouter.go_hub)
	_set_actions(false)
	battle.setup_mvp_encounter()
	_refresh()
	battle.start()


func _process(_delta: float) -> void:
	if battle.phase == battle.Phase.REACTION and battle.reaction.open:
		reaction_bar.value = battle.reaction.progress() * 100.0


func _append_log(text: String) -> void:
	log_box.append_text(text + "\n")


func _set_actions(enabled: bool) -> void:
	btn_attack_a.disabled = not enabled
	btn_attack_b.disabled = not enabled
	btn_guard.disabled = not enabled
	btn_flee.disabled = not enabled
	# Desabilita botões se o alvo morreu
	if enabled:
		var slime = battle.find_combatant(&"slime")
		var shade = battle.find_combatant(&"shade")
		btn_attack_a.disabled = slime == null or not slime.is_alive()
		btn_attack_b.disabled = shade == null or not shade.is_alive()


func _refresh() -> void:
	for child in portraits.get_children():
		child.queue_free()
	for c in battle.combatants:
		var panel := PanelContainer.new()
		var vb := VBoxContainer.new()
		var name_l := Label.new()
		name_l.text = "%s%s" % [c.display_name, " ★" if c.is_player_side else ""]
		name_l.add_theme_color_override("font_color", c.color)
		var hp_l := Label.new()
		hp_l.text = "HP %d/%d  SPD %d  %dd%d" % [c.hp, c.max_hp, c.speed, c.dice_count, c.dice_sides]
		if not c.is_alive():
			hp_l.text += " (derrotado)"
		vb.add_child(name_l)
		vb.add_child(hp_l)
		panel.add_child(vb)
		portraits.add_child(panel)
	if battle.current:
		status.text = "Fase: %s | Ativo: %s" % [battle.Phase.keys()[battle.phase], battle.current.display_name]
	else:
		status.text = "Preparando…"


func _on_reaction_started(_window: ReactionWindow) -> void:
	reaction_bar.visible = true
	reaction_hint.visible = true
	reaction_hint.text = "REAÇÃO! Pressione ESPAÇO / J / K no timing (Parry cedo · Dodge no impacto)"
	reaction_bar.value = 0


func _on_reaction_ended(result: ReactionWindow.Result) -> void:
	reaction_bar.visible = false
	reaction_hint.visible = false
	var names := ["MISS", "DODGE", "PARRY", "PERFECT"]
	_append_log("Resultado da janela: %s" % names[int(result)])


func _on_battle_finished(won: bool) -> void:
	_set_actions(false)
	end_panel.visible = true
	end_label.text = "Vitória!" if won else "Derrota…"
	if won and GameState.skill_points > 0:
		end_label.text += "\nSkill points disponíveis: %d (gaste no hub com 1/2)." % GameState.skill_points


func _flee() -> void:
	GameState.last_battle_result = "flee"
	GameState.current_hp = maxi(1, GameState.current_hp - 3)
	SceneRouter.go_hub()
