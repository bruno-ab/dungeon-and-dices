class_name ReactionWindow
extends RefCounted

## Janelas RT: Guard / Dodge / Counter / Counterspell + input buffer.

enum Result { MISS, DODGE, PARRY, PERFECT_PARRY, COUNTERSPELL, GUARD }
enum Mode { MELEE, SPELL }

var open: bool = false
var mode: Mode = Mode.MELEE
var elapsed: float = 0.0
var duration: float = 0.7
var dodge_start: float = 0.35
var dodge_end: float = 0.55
var parry_start: float = 0.22
var parry_end: float = 0.34
var perfect_start: float = 0.26
var perfect_end: float = 0.30
var spell_start: float = 0.20
var spell_end: float = 0.55
var pressed: bool = false
var press_time: float = -1.0
var chosen_action: StringName = &"auto"
## Buffer: pressões um pouco cedo demais entram na janela
var early_buffer: float = 0.08


func begin(
	p_duration: float,
	parry_bonus: float = 0.0,
	p_mode: Mode = Mode.MELEE,
	dodge_bonus: float = 0.0,
	spell_bonus: float = 0.0,
	p_buffer: float = 0.08
) -> void:
	duration = p_duration
	mode = p_mode
	early_buffer = maxf(0.0, p_buffer)
	parry_start = maxf(0.05, 0.22 - parry_bonus * 0.5)
	parry_end = minf(duration - 0.05, 0.34 + parry_bonus)
	perfect_start = parry_start + (parry_end - parry_start) * 0.35
	perfect_end = parry_start + (parry_end - parry_start) * 0.65
	dodge_start = parry_end
	dodge_end = minf(duration - 0.02, parry_end + 0.22 + dodge_bonus)
	spell_start = maxf(0.08, 0.18 - spell_bonus * 0.3)
	spell_end = minf(duration - 0.05, 0.52 + spell_bonus)
	elapsed = 0.0
	pressed = false
	press_time = -1.0
	chosen_action = &"auto"
	open = true


func tick(delta: float) -> bool:
	if not open:
		return false
	elapsed += delta
	if elapsed >= duration:
		open = false
		return true
	return false


func register_press(action: StringName = &"auto") -> void:
	if open and not pressed:
		pressed = true
		press_time = elapsed
		chosen_action = action


## Pressão durante o telegraph (antes da janela) — aplica no início da janela.
func buffer_press(action: StringName = &"auto") -> void:
	if not pressed:
		pressed = true
		press_time = 0.0
		chosen_action = action


func _buffered_time() -> float:
	if not pressed:
		return -1.0
	var t := press_time
	if mode == Mode.SPELL:
		if t < spell_start and t >= spell_start - early_buffer:
			return spell_start + 0.001
		return t
	# Empurra pressões early para o início da janela útil
	var first := parry_start
	if t < first and t >= first - early_buffer:
		return first + 0.001
	return t


func evaluate() -> Result:
	if not pressed:
		return Result.MISS
	var t := _buffered_time()
	if mode == Mode.SPELL:
		if chosen_action == &"counterspell" or chosen_action == &"auto":
			if t >= spell_start and t <= spell_end:
				return Result.COUNTERSPELL
		return Result.MISS
	match String(chosen_action):
		"guard":
			if t >= parry_start and t <= dodge_end:
				return Result.GUARD
			return Result.MISS
		"dodge":
			if t >= dodge_start and t <= dodge_end:
				return Result.DODGE
			return Result.MISS
		"counter":
			if t >= perfect_start and t <= perfect_end:
				return Result.PERFECT_PARRY
			if t >= parry_start and t <= parry_end:
				return Result.PARRY
			return Result.MISS
		_:
			if t >= perfect_start and t <= perfect_end:
				return Result.PERFECT_PARRY
			if t >= parry_start and t <= parry_end:
				return Result.PARRY
			if t >= dodge_start and t <= dodge_end:
				return Result.DODGE
			return Result.MISS


func progress() -> float:
	if duration <= 0.0:
		return 1.0
	return clampf(elapsed / duration, 0.0, 1.0)
