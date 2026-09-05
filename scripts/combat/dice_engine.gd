class_name DiceEngine
extends RefCounted

## Rolls dados estilo mesa. Determinístico se seed for passado.


static func roll(count: int, sides: int, rng: RandomNumberGenerator = null) -> Dictionary:
	var generator := rng if rng != null else RandomNumberGenerator.new()
	if rng == null:
		generator.randomize()
	var rolls: Array[int] = []
	var total := 0
	for _i in count:
		var value := generator.randi_range(1, sides)
		rolls.append(value)
		total += value
	return {
		"rolls": rolls,
		"total": total,
		"label": "%dd%d → %s = %d" % [count, sides, str(rolls), total],
	}


static func roll_damage(count: int, sides: int, flat_bonus: int = 0, rng: RandomNumberGenerator = null) -> Dictionary:
	var result := roll(count, sides, rng)
	result["total"] = int(result["total"]) + flat_bonus
	result["label"] = "%s %+d = %d" % [result["label"], flat_bonus, result["total"]]
	return result
