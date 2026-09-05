extends Control


func _ready() -> void:
	AudioManager.play_bgm("Theme3")
	AudioManager.me_fanfare()
	RtpUi.apply_window_panel($Center/Panel)
	RtpUi.apply_button_styles(%MenuBtn)
	RtpUi.apply_button_styles($Center/Panel/Margin/VBox/VillageBtn)
	%Title.text = "Fase concluída"
	%Body.text = (
		"A Vila de Cinzas respira de novo.\n"
		+ "Mylune, a Trilha e o Cemitério dos Metais foram enfrentados.\n\n"
		+ "Vitórias: %d\nNível: %d\nParty: %s\n\n"
		+ "Mittelerd ainda é vasto — mas Otto, Mira e Magus provaram os dados."
		% [GameState.battles_won, GameState.player_level, GameState.party_summary()]
	)
	%MenuBtn.grab_focus()


func _on_menu_pressed() -> void:
	SceneRouter.go_main()


func _on_village_pressed() -> void:
	SceneRouter.go_village()
