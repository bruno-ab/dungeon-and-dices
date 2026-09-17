extends Node

const MAIN := "res://scenes/main.tscn"
const VILLAGE := "res://scenes/exploration/village.tscn"
const DUNGEON := "res://scenes/exploration/dungeon.tscn"
const BATTLE := "res://scenes/combat/battle.tscn"
const PHASE_COMPLETE := "res://scenes/ui/phase_complete.tscn"


func go_main() -> void:
	GameState.save_game()
	get_tree().change_scene_to_file(MAIN)


func go_village() -> void:
	GameState.location = "village"
	get_tree().change_scene_to_file(VILLAGE)


func go_dungeon() -> void:
	GameState.location = "dungeon"
	GameState.spawn_point = "dungeon_entrance"
	get_tree().change_scene_to_file(DUNGEON)


func go_exploration() -> void:
	if GameState.location == "dungeon":
		go_dungeon()
	else:
		go_village()


func go_battle(encounter_id: String = "") -> void:
	if encounter_id != "":
		GameState.pending_encounter = encounter_id
	if GameState.location != "dungeon":
		GameState.spawn_point = "gate"
	get_tree().change_scene_to_file(BATTLE)


func go_phase_complete() -> void:
	GameState.save_game()
	get_tree().change_scene_to_file(PHASE_COMPLETE)
