extends Control

## Menu principal — Start Game / Continuar / Sair.


func _ready() -> void:
	%StartBtn.grab_focus()


func _on_start_pressed() -> void:
	GameState.reset_run()
	SceneRouter.go_village()


func _on_continue_pressed() -> void:
	SceneRouter.go_village()


func _on_quit_pressed() -> void:
	get_tree().quit()
