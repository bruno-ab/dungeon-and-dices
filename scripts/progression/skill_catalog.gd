class_name SkillCatalog
extends RefCounted

## Árvores por classe (~7 nós). Efeitos mudam como se joga.


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
			return String(a.id) < String(b.id)
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
			return "Mago"
		_:
			return String(class_id)


static func _warrior() -> Array[SkillDef]:
	return [
		SkillDef.new(&"w_stance", &"warrior", "Postura Férrea",
			"Raiz da árvore. +6 HP máximo.", 0, 1, 1, [],
			{"max_hp": 6}),
		SkillDef.new(&"w_parry", &"warrior", "Aparo Largo",
			"Janela de Parry/Contra +0.10s.", 1, 1, 1, [&"w_stance"],
			{"parry_window": 0.10}),
		SkillDef.new(&"w_die", &"warrior", "Segundo Dado",
			"+1d10 no pool de ataque.", 1, 1, 2, [&"w_stance"],
			{"extra_dice": 1}),
		SkillDef.new(&"w_guard", &"warrior", "Escudo Vivo",
			"Guardar cura +4 HP e reduz mais dano.", 2, 1, 2, [&"w_stance"],
			{"guard_heal": 4, "guard_mitigation": 0.15}),
		SkillDef.new(&"w_counter", &"warrior", "Contra Brutal",
			"Contra-ataque causa +50% dano.", 2, 1, 3, [&"w_parry"],
			{"counter_mult": 0.5}),
		SkillDef.new(&"w_blade", &"warrior", "Lâmina Cruel",
			"+3 bônus fixo na Lâmina Severa.", 2, 1, 3, [&"w_die"],
			{"flat_bonus": 3}),
		SkillDef.new(&"w_master", &"warrior", "Marreta de Otto",
			"Habilidade: Magia do guerreiro gasta 0 MP e +5 dano.", 3, 2, 4,
			[&"w_counter", &"w_blade"],
			{"warrior_magic_free": 1, "flat_bonus": 2}),
	]


static func _druid() -> Array[SkillDef]:
	return [
		SkillDef.new(&"d_seed", &"druid", "Semente de Mylune",
			"Raiz. +4 MP máximo.", 0, 1, 1, [],
			{"max_mp": 4}),
		SkillDef.new(&"d_heal", &"druid", "Seiva",
			"Itens e cura restauram +6 HP.", 1, 1, 1, [&"d_seed"],
			{"heal_bonus": 6}),
		SkillDef.new(&"d_dodge", &"druid", "Folha Leve",
			"Janela de Esquiva +0.12s.", 1, 1, 2, [&"d_seed"],
			{"dodge_window": 0.12}),
		SkillDef.new(&"d_ice", &"druid", "Geada",
			"Bônus ambiental de GELO ×2.", 2, 1, 2, [&"d_seed"],
			{"env_gelo_mult": 1.0}),
		SkillDef.new(&"d_form", &"druid", "Forma Ágil",
			"+2 Speed na iniciativa.", 2, 1, 3, [&"d_dodge"],
			{"speed": 2}),
		SkillDef.new(&"d_pool", &"druid", "Crescimento",
			"+1d6 no pool.", 2, 1, 3, [&"d_heal"],
			{"extra_dice": 1}),
		SkillDef.new(&"d_bloom", &"druid", "Florescer",
			"Magia custa 2 MP a menos; +1 dado.", 3, 2, 4,
			[&"d_pool", &"d_ice"],
			{"magic_cost_reduce": 2, "extra_dice": 1}),
	]


static func _mage() -> Array[SkillDef]:
	return [
		SkillDef.new(&"m_veil", &"mage", "Véu Arcano",
			"Raiz. +6 MP máximo.", 0, 1, 1, [],
			{"max_mp": 6}),
		SkillDef.new(&"m_cspell", &"mage", "Contra-janela",
			"Janela de Contra-feitiço +0.14s.", 1, 1, 1, [&"m_veil"],
			{"spell_window": 0.14}),
		SkillDef.new(&"m_fire", &"mage", "Brasa de Vasta",
			"Bônus ambiental de FOGO ×2.", 1, 1, 2, [&"m_veil"],
			{"env_fogo_mult": 1.0}),
		SkillDef.new(&"m_mp", &"mage", "Reservatório",
			"+10 MP máximo.", 2, 1, 2, [&"m_veil"],
			{"max_mp": 10}),
		SkillDef.new(&"m_reflect", &"mage", "Espelho",
			"Reflexo do Contra-feitiço +4 dano.", 2, 1, 3, [&"m_cspell"],
			{"reflect_bonus": 4}),
		SkillDef.new(&"m_die", &"mage", "Dado Proibido",
			"+1d8 no pool.", 2, 1, 3, [&"m_fire"],
			{"extra_dice": 1}),
		SkillDef.new(&"m_arcane", &"mage", "Sentinela Renegada",
			"Magia −3 MP; reflexo +d4 extra.", 3, 2, 4,
			[&"m_reflect", &"m_die"],
			{"magic_cost_reduce": 3, "reflect_bonus": 2, "extra_dice": 1}),
	]
