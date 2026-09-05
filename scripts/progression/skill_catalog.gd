class_name SkillCatalog
extends RefCounted

## Árvores conforme `docs/classes.md` — ramos + progressão por nível.


static func all_defs() -> Array[SkillDef]:
	var out: Array[SkillDef] = []
	out.append_array(_warrior())
	out.append_array(_druid())
	out.append_array(_mage())
	return out


static func defs_for(class_id: StringName) -> Array[SkillDef]:
	var out: Array[SkillDef] = []
	for d in all_defs():
		if d.class_id == class_id:
			out.append(d)
	out.sort_custom(func(a: SkillDef, b: SkillDef) -> bool:
		if a.tier == b.tier:
			if a.branch == b.branch:
				return String(a.id) < String(b.id)
			return String(a.branch) < String(b.branch)
		return a.tier < b.tier
	)
	return out


static func get_def(skill_id: StringName) -> SkillDef:
	for d in all_defs():
		if d.id == skill_id:
			return d
	return null


static func class_label(class_id: StringName) -> String:
	match String(class_id):
		"warrior":
			return "Guerreiro"
		"druid":
			return "Druida"
		"mage":
			return "Mago Arcano"
		_:
			return String(class_id)


static func _warrior() -> Array[SkillDef]:
	## Progressão 1–10 + ramos Vanguarda / Executor
	return [
		SkillDef.new(&"w_brute", &"warrior", "Força Bruta",
			"Passiva: ao rolar 1 ou 2 no dano, rola o dado novamente.",
			0, 0, 1, [], {"reroll_low": 2}, &"core"),
		SkillDef.new(&"w_solid", &"warrior", "Defesa Sólida",
			"Passiva: aparo bem-sucedido recupera 1d10 de PV.",
			1, 1, 2, [&"w_brute"], {"parry_heal_die": 1}, &"vanguard"),
		SkillDef.new(&"w_window", &"warrior", "Postura de Aparo",
			"Vanguarda: amplia janela de Aparo (+0.10s) e +8 HP.",
			1, 1, 2, [&"w_brute"], {"parry_window": 0.10, "max_hp": 8}, &"vanguard"),
		SkillDef.new(&"w_crit_brutal", &"warrior", "Crítico Brutal",
			"Passiva: crítico concede +1 dado de bônus aos aliados até o fim do turno.",
			2, 1, 3, [&"w_brute"], {"crit_ally_bonus": 1}, &"executor"),
		SkillDef.new(&"w_dual", &"warrior", "Duas Armas",
			"Passiva: permite duas armas (+1 flat e fórmula dual).",
			2, 1, 4, [&"w_brute"], {"dual_wield": 1, "flat_bonus": 1}, &"executor"),
		SkillDef.new(&"w_pool5", &"warrior", "Segundo d10",
			"Nv.5: pool 2d10 (regra de nível). Desbloqueia Power Attack.",
			3, 1, 5, [&"w_window"], {"power_attack": 1}, &"vanguard"),
		SkillDef.new(&"w_power_atk", &"warrior", "Power Attack",
			"Ativa: sacrifica precisão — +1 dado de dano no ataque.",
			3, 1, 5, [&"w_pool5"], {"power_attack": 1}, &"executor"),
		SkillDef.new(&"w_power_def", &"warrior", "Power Defense",
			"Ativa: sacrifica 1 dado de acerto; bônus na armadura até seu próximo turno.",
			4, 1, 6, [&"w_solid"], {"power_defense": 1}, &"vanguard"),
		SkillDef.new(&"w_last_stand", &"warrior", "Último Fôlego",
			"Passiva: ao atingir 0 PV, recupera 1d10 PV (1× por combate).",
			4, 1, 7, [&"w_power_def"], {"last_stand": 1}, &"vanguard"),
		SkillDef.new(&"w_war_cry", &"warrior", "War Cry",
			"Ativa: sacrifica dados de ataque do turno para +defesa dos aliados.",
			5, 1, 8, [&"w_power_atk"], {"war_cry": 1}, &"executor"),
		SkillDef.new(&"w_parry_counter", &"warrior", "Aparo Retalíativo",
			"Passiva: qualquer Aparo (não só perfeito) permite contra-ataque.",
			5, 1, 9, [&"w_solid", &"w_crit_brutal"], {"parry_counters": 1}, &"core"),
		SkillDef.new(&"w_capstone", &"warrior", "Máximo Absoluto",
			"Capstone Nv.10: primeira rolagem de acerto e de dano sempre no máximo. Pool 3d10.",
			6, 2, 10, [&"w_parry_counter", &"w_war_cry"], {"force_max_first": 1}, &"core"),
	]


static func _druid() -> Array[SkillDef]:
	return [
		SkillDef.new(&"d_seed", &"druid", "Forma Humana",
			"Base d6: cura e controle. +6 MP.",
			0, 0, 1, [], {"max_mp": 6}, &"core"),
		SkillDef.new(&"d_restore", &"druid", "Seiva Restauradora",
			"Restauração: curas e itens +1d6 de eficácia.",
			1, 1, 1, [&"d_seed"], {"heal_bonus_die": 6}, &"restoration"),
		SkillDef.new(&"d_shield", &"druid", "Casca Viva",
			"Restauração: escudo de grupo — Guardar aliado cura +4.",
			2, 1, 3, [&"d_restore"], {"heal_bonus": 4, "guard_heal": 4}, &"restoration"),
		SkillDef.new(&"d_bear", &"druid", "Forma de Urso",
			"Metamorfose: tanque d12 — absorção e aparo.",
			1, 1, 2, [&"d_seed"], {"unlock_form_bear": 1, "max_hp": 10}, &"metamorph"),
		SkillDef.new(&"d_panther", &"druid", "Forma de Pantera",
			"Metamorfose: d8 — crítico e esquiva ampliada.",
			2, 1, 3, [&"d_bear"], {"unlock_form_panther": 1, "dodge_window": 0.14}, &"metamorph"),
		SkillDef.new(&"d_pool", &"druid", "Crescimento Selvagem",
			"+1 dado no pool (todas as formas).",
			3, 1, 5, [&"d_restore"], {"extra_dice": 1}, &"restoration"),
		SkillDef.new(&"d_keep", &"druid", "Memória da Forma",
			"Metamorfose: ao trocar de forma, mantém +1 flat acumulado.",
			3, 1, 5, [&"d_panther"], {"form_keep_bonus": 1}, &"metamorph"),
		SkillDef.new(&"d_bloom", &"druid", "Florescer",
			"Capstone: magia −2 MP; +1 dado; curas em área leve.",
			4, 2, 8, [&"d_pool", &"d_keep"], {"magic_cost_reduce": 2, "extra_dice": 1, "heal_bonus": 4}, &"core"),
	]


static func _mage() -> Array[SkillDef]:
	return [
		SkillDef.new(&"m_spark", &"mage", "Faísca Arcana",
			"Base: rajadas com múltiplos d4. +8 MP.",
			0, 0, 1, [], {"max_mp": 8}, &"core"),
		SkillDef.new(&"m_burn", &"mage", "Queimadura",
			"Elemental: máximo no d4 aplica Queimadura (+2 dano flat).",
			1, 1, 2, [&"m_spark"], {"element_burn": 1, "flat_bonus": 1}, &"elemental"),
		SkillDef.new(&"m_pool", &"mage", "Multiplicação d4",
			"Elemental: +1d4 no pool de feitiços.",
			2, 1, 4, [&"m_burn"], {"extra_dice": 1}, &"elemental"),
		SkillDef.new(&"m_freeze", &"mage", "Congelamento",
			"Elemental: magia pode aplicar lentidão (speed −2 no alvo).",
			2, 1, 5, [&"m_burn"], {"element_freeze": 1}, &"elemental"),
		SkillDef.new(&"m_cspell", &"mage", "Anulador",
			"Anulação: janela de Contra-feitiço +0.16s.",
			1, 1, 2, [&"m_spark"], {"spell_window": 0.16}, &"nullify"),
		SkillDef.new(&"m_reflect", &"mage", "Reflexo Arcano",
			"Anulação: Contra-feitiço reflete +d4(+2) e restaura 3 MP.",
			2, 1, 4, [&"m_cspell"], {"reflect_bonus": 4, "counterspell_mp": 3}, &"nullify"),
		SkillDef.new(&"m_ritual", &"mage", "Ritual de Alto Risco",
			"Ativa Magia como 1d20. Alto = explosão; baixo = risco.",
			3, 1, 6, [&"m_pool"], {"ritual_d20": 1}, &"elemental"),
		SkillDef.new(&"m_capstone", &"mage", "Sentinela Invertida",
			"Capstone: +2d4; Contra-feitiço silencia; Magia −2 MP.",
			4, 2, 8, [&"m_reflect", &"m_ritual"],
			{"extra_dice": 2, "magic_cost_reduce": 2, "silence_on_cspell": 1}, &"core"),
	]
