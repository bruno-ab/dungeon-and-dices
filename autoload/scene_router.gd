extends Node

const MAIN := "res://scenes/main.tscn"
const HUB := "res://scenes/exploration/hub.tscn"
const BATTLE := "res://scenes/combat/battle.tscn"


func go_hub() -> void:
	get_tree().change_scene_to_file(HUB)


func go_battle() -> void:
	get_tree().change_scene_to_file(BATTLE)


func go_main() -> void:
	get_tree().change_scene_to_file(MAIN)
