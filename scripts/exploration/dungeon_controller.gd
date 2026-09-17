extends Node2D

## Cripta dos Metais — dungeon curta do MVP (ante-sala + boss).

@onready var hud: Label = %Hud
@onready var quest: Label = %Quest
@onready var toast: Label = %Toast
@onready var player: CharacterBody2D = %Player


func _ready() -> void:
	GameState.location = "dungeon"
	AudioManager.bgm_village()
	GameState.log_message.connect(_on_log)
	GameState.quest_updated.connect(_on_quest)
	_place_player()
	_refresh_hud()
	_on_quest(GameState.quest_text())
	_handle_return_from_battle()


func _place_player() -> void:
	var marker_name := "SpawnEntrance"
	match GameState.spawn_point:
		"dungeon_boss":
			marker_name = "SpawnBoss"
		"dungeon_mid":
			marker_name = "SpawnMid"
		_:
			marker_name = "SpawnEntrance"
	var marker := get_node_or_null("World/Spawns/%s" % marker_name)
	if marker and player:
		player.global_position = marker.global_position
	GameState.spawn_point = "dungeon_entrance"


func _handle_return_from_battle() -> void:
	match GameState.last_battle_result:
		"victory":
			AudioManager.play_ui("Bell1")
			_on_log("Vitória na cripta. Ouro: %d · Poções: %d" % [
				GameState.gold, GameState.item_count("pocao")
			])
			if GameState.cleared_cemiterio:
				_on_log("O Golem caiu. Saia pela entrada sul ou fale com Magus na vila.")
		"defeat":
			GameState.heal_full()
			GameState.location = "village"
			GameState.spawn_point = "inn"
			GameState.last_battle_result = ""
			SceneRouter.go_village()
			return
		"flee":
			_on_log("Você recuou na cripta.")
	GameState.last_battle_result = ""


func _refresh_hud() -> void:
	hud.text = (
		"%s  |  Nv %d  HP %d/%d  |  Ouro %d  |  Poções %d\nCripta dos Metais · E interagir · Esc pause / salvar"
		% [
			GameState.player_name,
			GameState.player_level,
			GameState.current_hp,
			GameState.max_hp,
			GameState.gold,
			GameState.item_count("pocao"),
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
	if event.is_action_pressed("skill_tree"):
		SkillTreeUI.open_tree()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("ui_cancel"):
		GameState.save_game()
		var dialog := AcceptDialog.new()
		dialog.title = "Pause · Cripta"
		dialog.dialog_text = "Jogo salvo.\nOK continua · Menu volta ao título."
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
		dialog.add_button("Menu principal", true, "quit")
		dialog.custom_action.connect(func(action: StringName):
			if action == &"quit":
				get_tree().paused = false
				SceneRouter.go_main()
		)
