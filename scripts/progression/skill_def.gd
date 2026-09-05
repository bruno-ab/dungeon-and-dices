class_name SkillDef
extends RefCounted

## Definição estática de um nó da árvore (não mutável em runtime).

var id: StringName
var class_id: StringName ## warrior | druid | mage
var display_name: String
var description: String
var tier: int = 0
var cost: int = 1
var level_req: int = 1
var prerequisites: Array[StringName] = []
var effects: Dictionary = {} ## chave -> valor numérico


func _init(
	p_id: StringName = &"",
	p_class: StringName = &"warrior",
	p_name: String = "",
	p_desc: String = "",
	p_tier: int = 0,
	p_cost: int = 1,
	p_level: int = 1,
	p_prereqs: Array = [],
	p_effects: Dictionary = {}
) -> void:
	id = p_id
	class_id = p_class
	display_name = p_name
	description = p_desc
	tier = p_tier
	cost = p_cost
	level_req = p_level
	prerequisites.clear()
	for p in p_prereqs:
		prerequisites.append(StringName(p))
	effects = p_effects.duplicate()
