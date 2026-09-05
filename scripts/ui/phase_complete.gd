extends Control


func _ready() -> void:
	%Title.text = "Fase 1 concluída"
	%Body.text = (
		"A Vila de Cinzas está segura — por enquanto.\n\n"
		+ "Vitórias: %d\nNível: %d\nParty: %s\n\n"
		+ "Você validou o loop: explorar → diálogo → combate reativo → progresso."
		% [GameState.battles_won, GameState.player_level, GameState.party_summary()]
	)
	%MenuBtn.grab_focus()


func _on_menu_pressed() -> void:
	SceneRouter.go_main()


func _on_village_pressed() -> void:
	SceneRouter.go_village()
