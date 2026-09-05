extends Control

## Menu principal — Start Game / Continuar / Sair.


func _ready() -> void:
	AudioManager.bgm_menu()
	%StartBtn.grab_focus()
	%StartBtn.focus_entered.connect(AudioManager.sfx_ui_cursor)
	$Center/Panel/Margin/VBox/ContinueBtn.focus_entered.connect(AudioManager.sfx_ui_cursor)
	$Center/Panel/Margin/VBox/QuitBtn.focus_entered.connect(AudioManager.sfx_ui_cursor)


func _on_start_pressed() -> void:
	AudioManager.sfx_ui_confirm()
	GameState.reset_run()
	SceneRouter.go_village()


func _on_continue_pressed() -> void:
	AudioManager.sfx_ui_confirm()
	SceneRouter.go_village()


func _on_quit_pressed() -> void:
	AudioManager.sfx_ui_cancel()
	get_tree().quit()
