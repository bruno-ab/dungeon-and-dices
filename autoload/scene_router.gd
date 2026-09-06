extends Node

const MAIN := "res://scenes/main.tscn"
const INTRO := "res://scenes/ui/world_intro.tscn"
const MYLUNE := "res://scenes/exploration/mylune_forest.tscn"
const VILLAGE := "res://scenes/exploration/village.tscn"
const BATTLE := "res://scenes/combat/battle.tscn"
const PHASE_COMPLETE := "res://scenes/ui/phase_complete.tscn"
## Hub padrão = mapa inicial
const HUB := MYLUNE


func go_main() -> void:
	get_tree().change_scene_to_file(MAIN)


func go_intro() -> void:
	get_tree().change_scene_to_file(INTRO)


func go_mylune() -> void:
	get_tree().change_scene_to_file(MYLUNE)


func go_village() -> void:
	get_tree().change_scene_to_file(VILLAGE)


func go_hub() -> void:
	var path := GameState.return_scene
	if path == "" or not ResourceLoader.exists(path):
		path = MYLUNE
	get_tree().change_scene_to_file(path)


func go_battle(encounter_id: String = "", spawn: String = "gate") -> void:
	if encounter_id != "":
		GameState.pending_encounter = encounter_id
	var cur := get_tree().current_scene
	if cur and cur.scene_file_path != "":
		GameState.return_scene = cur.scene_file_path
	GameState.spawn_point = spawn
	get_tree().change_scene_to_file(BATTLE)


func go_phase_complete() -> void:
	get_tree().change_scene_to_file(PHASE_COMPLETE)
