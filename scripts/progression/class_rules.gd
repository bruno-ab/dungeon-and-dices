class_name ClassRules
extends RefCounted

## Regras canônicas de `docs/classes.md`.


static func base_die(class_id: StringName) -> int:
	match String(class_id):
		"warrior":
			return 10
		"druid":
			return 6
		"mage":
			return 4
		_:
			return 6


static func pool_count(class_id: StringName, level: int) -> int:
	## Nível 1 = 1 → Nv5 = 2 → Nv10 = 3 (e mage elemental escala mais cedo)
	var n := 1
	if level >= 5:
		n = 2
	if level >= 10:
		n = 3
	if class_id == &"mage":
		## Elemental: 3d4 no Nv1 → 6d4 no Nv8 (aprox. por nível)
		n = 3
		if level >= 4:
			n = 4
		if level >= 6:
			n = 5
		if level >= 8:
			n = 6
	return n


static func die_for_form(form: StringName) -> int:
	match String(form):
		"bear":
			return 12
		"panther":
			return 8
		_:
			return 6 ## humana


static func form_label(form: StringName) -> String:
	match String(form):
		"bear":
			return "Urso"
		"panther":
			return "Pantera"
		_:
			return "Humana"


static func class_blurb(class_id: StringName) -> String:
	match String(class_id):
		"warrior":
			return "d10 · Vanguarda / Executor · Aparo e Contra-Ataque"
		"druid":
			return "d6/d12/d8 · Restauração / Metamorfose · Esquiva e Absorção"
		"mage":
			return "d4 elemental / d20 ritual · Elemental / Anulação · Contra-feitiço"
		_:
			return ""


static func branch_label(branch: StringName) -> String:
	match String(branch):
		"vanguard":
			return "Vanguarda"
		"executor":
			return "Executor"
		"restoration":
			return "Restauração"
		"metamorph":
			return "Metamorfose"
		"elemental":
			return "Elemental"
		"nullify":
			return "Anulação"
		"core":
			return "Núcleo"
		_:
			return String(branch)


static func skill_name_default(class_id: StringName) -> String:
	match String(class_id):
		"warrior":
			return "Golpe de Linha"
		"druid":
			return "Magia Natural"
		"mage":
			return "Rajada Elemental"
		_:
			return "Ataque"
