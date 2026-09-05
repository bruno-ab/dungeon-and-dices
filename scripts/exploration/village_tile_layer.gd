extends TileMapLayer

## Monta o chão da Vila de Cinzas com Outside_A5 (RTP).

const MAP_W := 50
const MAP_H := 34
const SRC := 0

## Índices de atlas (Outside_A5 8×16) — placeholders de terreno
const GRASS := Vector2i(0, 0)
const GRASS_ALT := Vector2i(1, 0)
const DIRT := Vector2i(0, 2)
const DIRT_ALT := Vector2i(1, 2)
const STONE := Vector2i(4, 4)
const STONE_ALT := Vector2i(5, 4)
const DARK := Vector2i(2, 6)


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	tile_set = RtpTileset.outside_a5()
	_paint_village()


func _paint_village() -> void:
	clear()
	## Base: grama / terra escura (cinzas)
	for y in MAP_H:
		for x in MAP_W:
			var t := GRASS if (x + y) % 5 != 0 else GRASS_ALT
			if y < 4 or y > MAP_H - 3 or x < 2 or x > MAP_W - 3:
				t = DARK
			set_cell(Vector2i(x, y), SRC, t)

	## Praça central (stone)
	_fill_rect(16, 12, 15, 10, STONE, STONE_ALT)
	## Estrada leste
	_fill_rect(30, 15, 18, 4, DIRT, DIRT_ALT)
	## Estrada norte (cemitério)
	_fill_rect(21, 3, 5, 10, DIRT, DIRT_ALT)
	## Caminho oeste (Mylune)
	_fill_rect(1, 15, 16, 4, DIRT, DIRT_ALT)
	## Pátio da estalagem
	_fill_rect(20, 5, 8, 5, STONE_ALT, STONE)
	## Área do poço / Mira
	_fill_rect(33, 20, 6, 5, DIRT, STONE)


func _fill_rect(ox: int, oy: int, w: int, h: int, a: Vector2i, b: Vector2i) -> void:
	for y in h:
		for x in w:
			var t := a if (x + y) % 3 != 0 else b
			set_cell(Vector2i(ox + x, oy + y), SRC, t)
