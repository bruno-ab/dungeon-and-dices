extends Node2D

@onready var hud: Label = $CanvasLayer/Hud
@onready var toast: Label = $CanvasLayer/Toast


func _ready() -> void:
	GameState.log_message.connect(_on_log)
	GameState.party_changed.connect(_refresh_hud)
	GameState.xp_gained.connect(func(_a, _l): _refresh_hud())
	GameState.skill_points_changed.connect(func(_p): _refresh_hud())
	_refresh_hud()
	if GameState.last_battle_result == "victory":
		_on_log("Você voltou da batalha vitorioso.")
	elif GameState.last_battle_result == "defeat":
		GameState.heal_full()
		_on_log("Você acordou na fogueira… HP cheio.")
	GameState.last_battle_result = ""


func _refresh_hud() -> void:
	hud.text = (
		"%s  |  Nv %d  HP %d/%d  |  %dd%d  |  SP %d  |  Vitórias %d\nParty: %s\nWASD mover · E interagir · Esc menu skills"
		% [
			GameState.player_name,
			GameState.player_level,
			GameState.current_hp,
			GameState.max_hp,
			GameState.dice_count,
			GameState.dice_sides,
			GameState.skill_points,
			GameState.battles_won,
			GameState.party_summary(),
		]
	)


func _on_log(text: String) -> void:
	toast.text = text
	toast.modulate.a = 1.0
	var tw := create_tween()
	tw.tween_interval(2.2)
	tw.tween_property(toast, "modulate:a", 0.0, 0.6)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_open_skills_popup()


func _open_skills_popup() -> void:
	var dialog := AcceptDialog.new()
	dialog.title = "Skill points (%d)" % GameState.skill_points
	dialog.dialog_text = "1) Ampliar janela de Parry\n2) +1 dado no pool\n(feche e pressione 1 ou 2)"
	add_child(dialog)
	dialog.popup_centered()
	dialog.confirmed.connect(dialog.queue_free)
	dialog.close_requested.connect(dialog.queue_free)


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_1:
			GameState.spend_skill_widen_parry()
			_refresh_hud()
		elif event.physical_keycode == KEY_2:
			GameState.spend_skill_extra_die()
			_refresh_hud()
