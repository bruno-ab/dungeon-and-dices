extends Node

const MAIN := "res://scenes/main.tscn"
const INTRO := "res://scenes/ui/world_intro.tscn"
const VILLAGE := "res://scenes/exploration/village.tscn"
const BATTLE := "res://scenes/combat/battle.tscn"
const PHASE_COMPLETE := "res://scenes/ui/phase_complete.tscn"
const HUB := VILLAGE


func go_main() -> void:
	get_tree().change_scene_to_file(MAIN)


func go_intro() -> void:
	get_tree().change_scene_to_file(INTRO)


func go_village() -> void:
	get_tree().change_scene_to_file(VILLAGE)


func go_hub() -> void:
	go_village()


func go_battle(encounter_id: String = "") -> void:
	if encounter_id != "":
		GameState.pending_encounter = encounter_id
	GameState.spawn_point = "gate"
	get_tree().change_scene_to_file(BATTLE)


func go_phase_complete() -> void:
	get_tree().change_scene_to_file(PHASE_COMPLETE)
