extends Control

## Menu principal — Start / Continuar (save) / Sair.


func _ready() -> void:
	AudioManager.bgm_menu()
	%StartBtn.grab_focus()
	%StartBtn.focus_entered.connect(AudioManager.sfx_ui_cursor)
	$Center/Panel/Margin/VBox/ContinueBtn.focus_entered.connect(AudioManager.sfx_ui_cursor)
	$Center/Panel/Margin/VBox/QuitBtn.focus_entered.connect(AudioManager.sfx_ui_cursor)
	_refresh_continue()


func _refresh_continue() -> void:
	var btn: Button = $Center/Panel/Margin/VBox/ContinueBtn
	btn.disabled = not GameState.has_save()
	btn.text = "Continuar" if GameState.has_save() else "Continuar (sem save)"


func _on_start_pressed() -> void:
	AudioManager.sfx_ui_confirm()
	GameState.reset_run()
	GameState.save_game()
	SceneRouter.go_village()


func _on_continue_pressed() -> void:
	AudioManager.sfx_ui_confirm()
	if not GameState.load_game():
		_refresh_continue()
		return
	SceneRouter.go_exploration()


func _on_quit_pressed() -> void:
	AudioManager.sfx_ui_cancel()
	get_tree().quit()
