class_name RtpTileset
extends RefCounted

## Carrega TileSets pré-configurados em `assets/tilesets/*.tres`.
## Regenerar: `python scripts/tools/generate_tilesets.py`

const TILE := 32

const PATH_VILLAGE := "res://assets/tilesets/village.tres"
const PATH_A5 := "res://assets/tilesets/outside_a5.tres"
const PATH_A2 := "res://assets/tilesets/outside_a2.tres"
const PATH_B := "res://assets/tilesets/outside_b.tres"
const PATH_C := "res://assets/tilesets/outside_c.tres"
const PATH_A1 := "res://assets/tilesets/outside_a1.tres"

## Source IDs em village.tres
const SRC_A5 := 0
const SRC_A2 := 1
const SRC_B := 2
const SRC_C := 3
const SRC_A1 := 4


static func village() -> TileSet:
	return load(PATH_VILLAGE) as TileSet


static func outside_a5() -> TileSet:
	return load(PATH_A5) as TileSet


static func outside_a2() -> TileSet:
	return load(PATH_A2) as TileSet


static func outside_b() -> TileSet:
	return load(PATH_B) as TileSet


static func outside_c() -> TileSet:
	return load(PATH_C) as TileSet


static func outside_a1() -> TileSet:
	return load(PATH_A1) as TileSet
