extends Node2D

## Floresta de Mylune — mapa inicial de exploração.

@onready var hud: Label = %Hud
@onready var quest: Label = %Quest
@onready var toast: Label = %Toast
@onready var player: CharacterBody2D = %Player


func _ready() -> void:
	AudioManager.play_bgm("Field2")
	AudioManager.play_bgs("Wind", -16.0)
	GameState.log_message.connect(_on_log)
	GameState.party_changed.connect(_refresh_hud)
	GameState.xp_gained.connect(func(_a, _l): _refresh_hud())
	GameState.skill_points_changed.connect(func(_p): _refresh_hud())
	GameState.skills_changed.connect(_refresh_hud)
	GameState.quest_updated.connect(_on_quest)
	_place_player()
	_refresh_hud()
	_on_quest(GameState.quest_text())
	_handle_return_from_battle()


func _place_player() -> void:
	var marker_name := "SpawnStart"
	match GameState.spawn_point:
		"gate", "combat":
			marker_name = "SpawnCombat"
		"village_exit":
			marker_name = "SpawnVillageExit"
		_:
			marker_name = "SpawnStart"
	var marker := get_node_or_null("World/Spawns/%s" % marker_name)
	if marker and player:
		player.global_position = marker.global_position
	GameState.spawn_point = "start"


func _handle_return_from_battle() -> void:
	match GameState.last_battle_result:
		"victory":
			AudioManager.play_ui("Bell1")
			_on_log("As raízes de Mylune se aquietam. %s" % GameState.quest_text())
			if GameState.skill_points > 0:
				_on_log("Skill points — Tab abre a árvore.")
		"defeat":
			GameState.heal_full()
			_on_log("Você caiu entre as raízes… e acordou com HP cheio.")
			var start := get_node_or_null("World/Spawns/SpawnStart")
			if start and player:
				player.global_position = start.global_position
		"flee":
			_on_log("Você recuou pela trilha sombreada.")
	GameState.last_battle_result = ""


func _refresh_hud() -> void:
	hud.text = (
		"%s  |  Nv %d  HP %d/%d  |  %dd%d  |  SP %d  |  Vitórias %d\nParty: %s\nFloresta de Mylune · WASD · E · Tab skills"
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
	if event.is_action_pressed("skill_tree"):
		SkillTreeUI.open_tree()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("ui_cancel"):
		var dialog := AcceptDialog.new()
		dialog.title = "Pause"
		dialog.dialog_text = "Floresta de Mylune\nSP: %d\nTab = Árvore" % GameState.skill_points
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
		dialog.add_button("Árvore de Skills", true, "skills")
		dialog.add_button("Vila de Cinzas", true, "village")
		dialog.add_button("Menu principal", true, "quit")
		dialog.custom_action.connect(func(action: StringName):
			get_tree().paused = false
			dialog.queue_free()
			if action == &"skills":
				SkillTreeUI.open_tree()
			elif action == &"village":
				GameState.spawn_point = "plaza"
				SceneRouter.go_village()
			elif action == &"quit":
				SceneRouter.go_main()
		)
