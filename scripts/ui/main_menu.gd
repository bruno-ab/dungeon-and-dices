extends Control


func _on_start_pressed() -> void:
	GameState.reset_run()
	SceneRouter.go_hub()


func _on_continue_pressed() -> void:
	SceneRouter.go_hub()
