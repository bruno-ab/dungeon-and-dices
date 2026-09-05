class_name RtpTileset
extends RefCounted

## TileSets a partir de `Graphics/Tilesets` (RTP VX Ace / 32×32).

const PATH_OUTSIDE_A5 := "res://assets/sprites/rtp/Graphics/Tilesets/Outside_A5.png"
const PATH_OUTSIDE_A2 := "res://assets/sprites/rtp/Graphics/Tilesets/Outside_A2.png"
const TILE := 32


static func outside_a5() -> TileSet:
	return _atlas_tileset(PATH_OUTSIDE_A5, TILE)


static func outside_a2() -> TileSet:
	return _atlas_tileset(PATH_OUTSIDE_A2, TILE)


static func _atlas_tileset(path: String, tile_px: int) -> TileSet:
	var tex := load(path) as Texture2D
	var ts := TileSet.new()
	ts.tile_size = Vector2i(tile_px, tile_px)
	if tex == null:
		push_warning("RtpTileset: missing %s" % path)
		return ts
	var src := TileSetAtlasSource.new()
	src.texture = tex
	src.texture_region_size = Vector2i(tile_px, tile_px)
	var sid := ts.add_source(src, 0)
	var cols := int(tex.get_width() / tile_px)
	var rows := int(tex.get_height() / tile_px)
	for y in rows:
		for x in cols:
			var coords := Vector2i(x, y)
			if not src.has_tile(coords):
				src.create_tile(coords)
	## sid unused beyond add — keep for clarity
	if sid < 0:
		pass
	return ts
