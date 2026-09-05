extends Control

## Menu principal — Start Game / Continuar / Sair.


func _ready() -> void:
	AudioManager.bgm_menu()
	_apply_rtp_ui()
	%StartBtn.grab_focus()
	%StartBtn.focus_entered.connect(AudioManager.sfx_ui_cursor)
	$Center/Panel/Margin/VBox/ContinueBtn.focus_entered.connect(AudioManager.sfx_ui_cursor)
	$Center/Panel/Margin/VBox/QuitBtn.focus_entered.connect(AudioManager.sfx_ui_cursor)


func _apply_rtp_ui() -> void:
	RtpUi.apply_window_panel($Center/Panel)
	RtpUi.apply_button_styles(%StartBtn)
	RtpUi.apply_button_styles($Center/Panel/Margin/VBox/ContinueBtn)
	RtpUi.apply_button_styles($Center/Panel/Margin/VBox/QuitBtn)


func _on_start_pressed() -> void:
	AudioManager.sfx_ui_confirm()
	GameState.reset_run()
	SceneRouter.go_intro()


func _on_continue_pressed() -> void:
	AudioManager.sfx_ui_confirm()
	SceneRouter.go_village()


func _on_quit_pressed() -> void:
	AudioManager.sfx_ui_cancel()
	get_tree().quit()
