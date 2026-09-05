extends Node2D

@onready var hud: Label = %Hud
@onready var quest: Label = %Quest
@onready var toast: Label = %Toast
@onready var player: CharacterBody2D = %Player


func _ready() -> void:
	AudioManager.bgm_village()
	GameState.log_message.connect(_on_log)
	GameState.party_changed.connect(_refresh_hud)
	GameState.xp_gained.connect(func(_a, _l): _refresh_hud())
	GameState.skill_points_changed.connect(func(_p): _refresh_hud())
	GameState.quest_updated.connect(_on_quest)
	_place_player()
	_refresh_hud()
	_on_quest(GameState.quest_text())
	_handle_return_from_battle()


func _place_player() -> void:
	var marker_name := "SpawnPlaza"
	match GameState.spawn_point:
		"gate":
			marker_name = "SpawnGate"
		"inn":
			marker_name = "SpawnInn"
		_:
			marker_name = "SpawnPlaza"
	var marker := get_node_or_null("World/Spawns/%s" % marker_name)
	if marker and player:
		player.global_position = marker.global_position
	GameState.spawn_point = "plaza"


func _handle_return_from_battle() -> void:
	match GameState.last_battle_result:
		"victory":
			AudioManager.play_ui("Bell1")
			_on_log("Você retorna à Vila de Cinzas. %s" % GameState.quest_text())
		"defeat":
			GameState.heal_full()
			_on_log("Você acordou na estalagem… HP cheio.")
			var inn := get_node_or_null("World/Spawns/SpawnInn")
			if inn and player:
				player.global_position = inn.global_position
		"flee":
			_on_log("Você recuou para a vila.")
	GameState.last_battle_result = ""


func _refresh_hud() -> void:
	hud.text = (
		"%s  |  Nv %d  HP %d/%d  |  %dd%d  |  SP %d  |  Vitórias %d\nParty: %s\nWASD mover · E falar/interagir · 1/2 skill points · Esc menu"
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


func _on_quest(text: String) -> void:
	quest.text = text


func _on_log(text: String) -> void:
	toast.text = text
	toast.modulate.a = 1.0
	var tw := create_tween()
	tw.tween_interval(2.4)
	tw.tween_property(toast, "modulate:a", 0.0, 0.5)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		var dialog := AcceptDialog.new()
		dialog.title = "Pause"
		dialog.dialog_text = "1 = ampliar Parry · 2 = +1 dado\nSkill points: %d\n\nOK fecha. Esc no menu principal via botão." % GameState.skill_points
		dialog.process_mode = Node.PROCESS_MODE_ALWAYS
		add_child(dialog)
		get_tree().paused = true
		dialog.popup_centered()
		dialog.confirmed.connect(func():
			get_tree().paused = false
			dialog.queue_free()
		)
		dialog.close_requested.connect(func():
			get_tree().paused = false
			dialog.queue_free()
		)
		var quit_btn := dialog.add_button("Menu principal", true, "quit")
		dialog.custom_action.connect(func(action: StringName):
			if action == &"quit":
				get_tree().paused = false
				SceneRouter.go_main()
		)
		quit_btn.visible = true


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_1:
			GameState.spend_skill_widen_parry()
			_refresh_hud()
		elif event.physical_keycode == KEY_2:
			GameState.spend_skill_extra_die()
			_refresh_hud()
