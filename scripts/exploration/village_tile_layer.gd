extends TileMapLayer

## Chão da Vila de Cinzas usando `assets/tilesets/village.tres`.
## Sources: 0=A5 chão · 1=A2 terreno · 2=B props · 3=C props · 4=A1 água

const MAP_W := 50
const MAP_H := 34

const SRC_A5 := 0
const SRC_A2 := 1

## Outside_A5 (8×16) — nomes do Outside_A5.txt
const MEADOW := Vector2i(0, 2)
const MEADOW_B := Vector2i(0, 3)
const DIRT := Vector2i(1, 2)
const DIRT_B := Vector2i(1, 3)
const COBBLE := Vector2i(0, 4)
const COBBLE_B := Vector2i(1, 4)
const COBBLE_RUIN := Vector2i(4, 4)
const DARK := Vector2i(0, 0) ## Darkness
const FARM := Vector2i(0, 9)

## Outside_A2 — faixas de estrada (atlas 16×12, bloco meadow road ~ col 2)
const ROAD_MEADOW := Vector2i(2, 0)
const ROAD_DIRT := Vector2i(2, 1)


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if tile_set == null:
		tile_set = load("res://assets/tilesets/village.tres") as TileSet
	_paint_village()


func _paint_village() -> void:
	clear()
	## Base: meadow / borda escura
	for y in MAP_H:
		for x in MAP_W:
			var t := MEADOW if (x + y) % 5 != 0 else MEADOW_B
			if y < 4 or y > MAP_H - 3 or x < 2 or x > MAP_W - 3:
				t = DARK
			set_cell(Vector2i(x, y), SRC_A5, t)

	## Praça (paralelepípedos)
	_fill_a5(16, 12, 15, 10, COBBLE, COBBLE_B)
	## Estradas com A2 (sobre A5)
	_fill_a2(30, 15, 18, 4, ROAD_DIRT)
	_fill_a2(21, 3, 5, 10, ROAD_DIRT)
	_fill_a2(1, 15, 16, 4, ROAD_MEADOW)
	## Pátio estalagem
	_fill_a5(20, 5, 8, 5, COBBLE_B, COBBLE)
	## Poço / Mira
	_fill_a5(33, 20, 6, 5, DIRT, FARM)
	## Faixa de ruína perto do cemitério
	_fill_a5(20, 2, 7, 2, COBBLE_RUIN, COBBLE_RUIN)


func _fill_a5(ox: int, oy: int, w: int, h: int, a: Vector2i, b: Vector2i) -> void:
	for y in h:
		for x in w:
			var t := a if (x + y) % 3 != 0 else b
			set_cell(Vector2i(ox + x, oy + y), SRC_A5, t)


func _fill_a2(ox: int, oy: int, w: int, h: int, atlas: Vector2i) -> void:
	for y in h:
		for x in w:
			set_cell(Vector2i(ox + x, oy + y), SRC_A2, atlas)
