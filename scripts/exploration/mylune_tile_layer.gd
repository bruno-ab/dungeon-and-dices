extends TileMapLayer

## Floresta de Mylune — camada de CHÃO (A5/A2). Árvores/props vão em `World/Props`.
## Por padrão NÃO redesenha no play (respeita pintura do editor).
## Marque `auto_paint_on_ready` só se quiser o layout procedural de novo.

@export var auto_paint_on_ready: bool = false
@export var paint_if_empty: bool = true

const MAP_W := 50
const MAP_H := 34
const SRC_A5 := 0
const SRC_A2 := 1

const MEADOW := Vector2i(0, 2)
const MEADOW_B := Vector2i(0, 3)
const DIRT := Vector2i(1, 2)
const DIRT_B := Vector2i(1, 3)
const DESERT := Vector2i(2, 2)
const DESERT_B := Vector2i(2, 3)
const DARK := Vector2i(0, 0)
const ROAD := Vector2i(2, 0)


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if tile_set == null:
		tile_set = load("res://assets/tilesets/village.tres") as TileSet
	var empty := get_used_cells().is_empty()
	if auto_paint_on_ready or (paint_if_empty and empty):
		_paint()


func _paint() -> void:
	## Layout procedural de fallback (sem Outside_B — evita “ícones” soltos).
	clear()
	for y in MAP_H:
		for x in MAP_W:
			var t := MEADOW if (x * 3 + y * 7) % 4 != 0 else MEADOW_B
			if y < 2 or y > MAP_H - 3 or x < 2 or x > MAP_W - 3:
				t = DARK
			set_cell(Vector2i(x, y), SRC_A5, t)
	_fill(SRC_A2, 8, 15, 38, 4, ROAD)
	_fill(SRC_A5, 6, 10, 10, 8, DESERT, DESERT_B)
	_fill(SRC_A2, 22, 4, 4, 12, ROAD)


func _fill(src: int, ox: int, oy: int, w: int, h: int, a: Vector2i, b: Vector2i = Vector2i(-1, -1)) -> void:
	for y in h:
		for x in w:
			var t := a
			if b.x >= 0 and (x + y) % 3 == 0:
				t = b
			set_cell(Vector2i(ox + x, oy + y), src, t)
