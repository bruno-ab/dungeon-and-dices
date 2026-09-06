extends TileMapLayer

## Floresta de Mylune — meadow + trilha + clareira (village.tres).

const MAP_W := 50
const MAP_H := 34
const SRC_A5 := 0
const SRC_A2 := 1
const SRC_B := 2

const MEADOW := Vector2i(0, 2)
const MEADOW_B := Vector2i(0, 3)
const DIRT := Vector2i(1, 2)
const DIRT_B := Vector2i(1, 3)
const DARK := Vector2i(0, 0)
const BUSH := Vector2i(4, 0) ## Outside_B approx foliage
const TREE := Vector2i(6, 2)
const ROAD := Vector2i(2, 0) ## A2


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if tile_set == null:
		tile_set = load("res://assets/tilesets/village.tres") as TileSet
	_paint()


func _paint() -> void:
	clear()
	for y in MAP_H:
		for x in MAP_W:
			var t := MEADOW if (x * 3 + y * 7) % 4 != 0 else MEADOW_B
			## Borda mais escura / densa
			if y < 2 or y > MAP_H - 3 or x < 2 or x > MAP_W - 3:
				t = DARK
			set_cell(Vector2i(x, y), SRC_A5, t)

	## Trilha oeste→leste (saída para vila à direita)
	_fill(SRC_A2, 8, 15, 38, 4, ROAD)
	## Clareira de combate (serpentes)
	_fill(SRC_A5, 6, 10, 10, 8, DIRT, DIRT_B)
	## Trilha norte curta
	_fill(SRC_A2, 22, 4, 4, 12, ROAD)

	## Arbustos / árvores (props B) — “floresta”
	var rng := RandomNumberGenerator.new()
	rng.seed = 20260905
	for y in range(3, MAP_H - 3):
		for x in range(3, MAP_W - 3):
			## Não cobrir trilhas/clareira principais
			if y >= 15 and y <= 18:
				continue
			if x >= 6 and x <= 15 and y >= 10 and y <= 17:
				continue
			if rng.randf() < 0.07:
				set_cell(Vector2i(x, y), SRC_B, BUSH if rng.randf() < 0.55 else TREE)


func _fill(src: int, ox: int, oy: int, w: int, h: int, a: Vector2i, b: Vector2i = Vector2i(-1, -1)) -> void:
	for y in h:
		for x in w:
			var t := a
			if b.x >= 0 and (x + y) % 3 == 0:
				t = b
			set_cell(Vector2i(ox + x, oy + y), src, t)
