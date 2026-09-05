class_name ReactionWindow
extends RefCounted

## Avalia timing de Dodge/Parry em uma janela aberta.

enum Result { MISS, DODGE, PARRY, PERFECT_PARRY }

var open: bool = false
var elapsed: float = 0.0
var duration: float = 0.7
var dodge_start: float = 0.35
var dodge_end: float = 0.55
var parry_start: float = 0.22
var parry_end: float = 0.34
var perfect_start: float = 0.26
var perfect_end: float = 0.30
var pressed: bool = false
var press_time: float = -1.0


func begin(p_duration: float, parry_bonus: float = 0.0) -> void:
	duration = p_duration
	parry_start = maxf(0.05, 0.22 - parry_bonus * 0.5)
	parry_end = minf(duration - 0.05, 0.34 + parry_bonus)
	perfect_start = parry_start + (parry_end - parry_start) * 0.35
	perfect_end = parry_start + (parry_end - parry_start) * 0.65
	dodge_start = parry_end
	dodge_end = minf(duration - 0.02, parry_end + 0.22)
	elapsed = 0.0
	pressed = false
	press_time = -1.0
	open = true


func tick(delta: float) -> bool:
	if not open:
		return false
	elapsed += delta
	if elapsed >= duration:
		open = false
		return true
	return false


func register_press() -> void:
	if open and not pressed:
		pressed = true
		press_time = elapsed


func evaluate() -> Result:
	if not pressed:
		return Result.MISS
	var t := press_time
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
