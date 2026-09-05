class_name DiceEngine
extends RefCounted

## Rolls dados estilo mesa. Determinístico se seed for passado.
## Opções alinhadas a `docs/classes.md`.


static func roll(count: int, sides: int, rng: RandomNumberGenerator = null, opts: Dictionary = {}) -> Dictionary:
	var generator := rng if rng != null else RandomNumberGenerator.new()
	if rng == null:
		generator.randomize()
	var rolls: Array[int] = []
	var total := 0
	var reroll_low := int(opts.get("reroll_low", 0))
	var force_max_first := bool(opts.get("force_max_first", false))
	var notes: PackedStringArray = []
	for i in count:
		var value: int
		if force_max_first and i == 0:
			value = sides
			notes.append("máx")
		else:
			value = generator.randi_range(1, sides)
			if reroll_low > 0 and value <= reroll_low:
				var again := generator.randi_range(1, sides)
				notes.append("reroll %d→%d" % [value, again])
				value = again
		rolls.append(value)
		total += value
	var max_hit := false
	for v in rolls:
		if v == sides:
			max_hit = true
			break
	var label := "%dd%d → %s = %d" % [count, sides, str(rolls), total]
	if not notes.is_empty():
		label += " (%s)" % ", ".join(notes)
	return {
		"rolls": rolls,
		"total": total,
		"sides": sides,
		"count": count,
		"max_face": max_hit,
		"label": label,
	}


static func roll_damage(count: int, sides: int, flat_bonus: int = 0, rng: RandomNumberGenerator = null, opts: Dictionary = {}) -> Dictionary:
	var result := roll(count, sides, rng, opts)
	var total: int = int(result["total"]) + flat_bonus
	var crit := false
	## Acerto crítico físico: ~5% dobra o dano (docs/classes.md)
	if bool(opts.get("allow_crit", false)):
		var g := rng if rng != null else RandomNumberGenerator.new()
		if rng == null:
			g.randomize()
		if g.randf() < float(opts.get("crit_chance", 0.05)):
			crit = true
			total *= 2
			result["label"] = "%s [CRÍTICO ×2]" % result["label"]
	result["total"] = total
	result["crit"] = crit
	result["label"] = "%s %+d = %d" % [result["label"], flat_bonus, total]
	return result
