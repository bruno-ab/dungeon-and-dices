class_name DiceEngine
extends RefCounted

## Rolls estilo mesa: acerto (d20) + potência + crit/fumble.


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


## Teste de acerto d20 + bônus vs CA. Crit natural 20 / fumble natural 1.
static func attack_check(attack_bonus: int, armor_class: int, rng: RandomNumberGenerator = null) -> Dictionary:
	var generator := rng if rng != null else RandomNumberGenerator.new()
	if rng == null:
		generator.randomize()
	var raw := generator.randi_range(1, 20)
	var total := raw + attack_bonus
	var is_crit := raw == 20
	var is_fumble := raw == 1
	var hit := is_crit or (not is_fumble and total >= armor_class)
	var verdict := "ERRO"
	if is_fumble:
		verdict = "FUMBLE"
	elif is_crit:
		verdict = "CRÍTICO"
	elif hit:
		verdict = "ACERTO"
	return {
		"raw": raw,
		"bonus": attack_bonus,
		"total": total,
		"ac": armor_class,
		"hit": hit,
		"crit": is_crit,
		"fumble": is_fumble,
		"label": "d20+%d → %d vs CA %d [%s]" % [attack_bonus, total, armor_class, verdict],
	}


## Combina acerto + potência. Em miss/fumble o dano é 0.
static func full_attack(
	dice_count: int,
	dice_sides: int,
	flat_bonus: int,
	attack_bonus: int,
	armor_class: int,
	rng: RandomNumberGenerator = null
) -> Dictionary:
	var check := attack_check(attack_bonus, armor_class, rng)
	if not bool(check["hit"]):
		return {
			"hit": false,
			"crit": false,
			"fumble": bool(check["fumble"]),
			"total": 0,
			"check": check,
			"power": {},
			"label": check["label"],
		}
	var power := roll_damage(dice_count, dice_sides, flat_bonus, rng)
	var dmg: int = int(power["total"])
	if bool(check["crit"]):
		dmg *= 2
		power["label"] = "%s ×2 CRÍTICO = %d" % [power["label"], dmg]
		power["total"] = dmg
	return {
		"hit": true,
		"crit": bool(check["crit"]),
		"fumble": false,
		"total": dmg,
		"check": check,
		"power": power,
		"label": "%s | %s" % [check["label"], power["label"]],
	}
