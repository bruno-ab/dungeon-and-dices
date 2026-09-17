class_name EncounterCatalog
extends RefCounted

## Encontros jogáveis — cada um destaca mecânicas diferentes.


static func ids() -> PackedStringArray:
	return PackedStringArray(["mylune", "trilha", "cripta", "cemiterio"])


static func meta(id: String) -> Dictionary:
	match id:
		"mylune":
			return {
				"title": "Floresta de Mylune",
				"blurb": "Emboscada nas raízes — foque Guard / Esquivar / Contra-ataque.",
				"battleback": "res://assets/sprites/battlebacks/mylune.png",
				"env": {"FOGO": 8, "TERRA": 10, "GELO": 6},
				"focus": "melee",
			}
		"trilha":
			return {
				"title": "Trilha Sombria",
				"blurb": "Vazamento de Arcano — pratique Contra-feitiço.",
				"battleback": "res://assets/sprites/battlebacks/dark_trail.png",
				"env": {"FOGO": 6, "TERRA": 8, "GELO": 10},
				"focus": "spell",
			}
		"cripta":
			return {
				"title": "Cripta dos Metais — Ante-sala",
				"blurb": "Guardiões menores. Loot e aquecimento antes do Golem.",
				"battleback": "res://assets/sprites/battlebacks/metal_graveyard.png",
				"env": {"FOGO": 9, "TERRA": 11, "GELO": 5},
				"focus": "melee",
			}
		"cemiterio":
			return {
				"title": "Cripta dos Metais — Câmara do Golem",
				"blurb": "Boss constructo — combate misto + dados ambientais.",
				"battleback": "res://assets/sprites/battlebacks/metal_graveyard.png",
				"env": {"FOGO": 10, "TERRA": 12, "GELO": 4},
				"focus": "mixed",
			}
		_:
			return meta("trilha")


static func build_enemies(id: String) -> Array[Combatant]:
	var out: Array[Combatant] = []
	match id:
		"mylune":
			var s1 := Combatant.new(&"serpent_g", "Serpente de Mylune", false, 26, 9, 1, 6, 1, Color(0.4, 0.7, 0.35))
			s1.sprite_key = "serpent_green"
			s1.attack_kind = &"melee"
			s1.skill_name = "Mordida"
			s1.armor_class = 11
			s1.attack_bonus = 2
			var s2 := Combatant.new(&"serpent_p", "Serpente Púrpura", false, 22, 12, 1, 8, 0, Color(0.55, 0.3, 0.7))
			s2.sprite_key = "serpent_purple"
			s2.attack_kind = &"melee"
			s2.skill_name = "Investida"
			s2.armor_class = 12
			s2.attack_bonus = 3
			out.append(s1)
			out.append(s2)
		"trilha":
			var slime := Combatant.new(&"slime", "Lodo Sombrio", false, 24, 7, 1, 6, 0, Color(0.35, 0.7, 0.4))
			slime.sprite_key = "slime"
			slime.attack_kind = &"melee"
			slime.skill_name = "Espasmo"
			slime.armor_class = 10
			slime.attack_bonus = 1
			var shade := Combatant.new(&"shade", "Sombra da Sentinela", false, 20, 13, 1, 8, 2, Color(0.45, 0.4, 0.55))
			shade.sprite_key = "shade"
			shade.attack_kind = &"spell"
			shade.skill_name = "Véu Arcano"
			shade.max_mp = 12
			shade.mp = 12
			shade.armor_class = 12
			shade.attack_bonus = 3
			out.append(slime)
			out.append(shade)
		"cripta":
			var scrap := Combatant.new(&"scrap", "Autômato Sucata", false, 30, 8, 1, 8, 1, Color(0.5, 0.4, 0.35))
			scrap.sprite_key = "trolling"
			scrap.attack_kind = &"melee"
			scrap.skill_name = "Martelada"
			scrap.armor_class = 13
			scrap.attack_bonus = 2
			out.append(scrap)
		"cemiterio":
			var golem := Combatant.new(&"golem", "Golem Corrupto", false, 55, 6, 2, 8, 2, Color(0.55, 0.25, 0.3))
			golem.sprite_key = "golem_corrupt"
			golem.attack_kind = &"melee"
			golem.skill_name = "Punho de Sucata"
			golem.max_mp = 10
			golem.mp = 10
			golem.armor_class = 14
			golem.attack_bonus = 4
			var troll := Combatant.new(&"trolling", "Troll das Sucatas", false, 32, 10, 1, 10, 1, Color(0.6, 0.45, 0.25))
			troll.sprite_key = "trolling"
			troll.attack_kind = &"spell"
			troll.skill_name = "Rugido Tóxico"
			troll.armor_class = 12
			troll.attack_bonus = 3
			out.append(golem)
			out.append(troll)
		_:
			return build_enemies("trilha")
	return out


static func xp_reward(id: String) -> int:
	match id:
		"mylune":
			return 18
		"trilha":
			return 20
		"cripta":
			return 12
		"cemiterio":
			return 35
		_:
			return 15


static func loot_reward(id: String) -> Dictionary:
	match id:
		"mylune":
			return {"gold": 8, "items": {"pocao": 1}}
		"trilha":
			return {"gold": 10, "items": {"semente": 1}}
		"cripta":
			return {"gold": 15, "items": {"pocao": 1}}
		"cemiterio":
			return {"gold": 40, "items": {"pocao": 2, "semente": 1}}
		_:
			return {"gold": 5, "items": {}}
