class_name RtpUi
extends RefCounted

## Estilos de UI a partir de `Graphics/System` (RTP).

const PATH_WINDOW := "res://assets/sprites/rtp/Graphics/System/Window.png"
const PATH_ICONSET := "res://assets/sprites/rtp/Graphics/System/IconSet.png"
const PATH_GAMEOVER := "res://assets/sprites/rtp/Graphics/System/GameOver.png"
const PATH_BATTLE_START := "res://assets/sprites/rtp/Graphics/System/BattleStart.png"


static func window_style(margin: float = 14.0) -> StyleBoxTexture:
	var tex := load(PATH_WINDOW) as Texture2D
	var sb := StyleBoxTexture.new()
	if tex:
		sb.texture = tex
	sb.texture_margin_left = margin
	sb.texture_margin_top = margin
	sb.texture_margin_right = margin
	sb.texture_margin_bottom = margin
	sb.content_margin_left = 18
	sb.content_margin_top = 16
	sb.content_margin_right = 18
	sb.content_margin_bottom = 16
	return sb


static func apply_window_panel(panel: PanelContainer) -> void:
	if panel == null:
		return
	panel.add_theme_stylebox_override("panel", window_style())


static func apply_button_styles(btn: Button) -> void:
	if btn == null:
		return
	var normal := window_style(10.0)
	var hover := window_style(10.0)
	hover.modulate_color = Color(1.15, 1.12, 1.05, 1.0)
	var pressed := window_style(10.0)
	pressed.modulate_color = Color(0.85, 0.82, 0.75, 1.0)
	btn.add_theme_stylebox_override("normal", normal)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("pressed", pressed)
	btn.add_theme_stylebox_override("focus", hover)
	btn.add_theme_color_override("font_color", Color(0.92, 0.88, 0.78))
	btn.add_theme_color_override("font_hover_color", Color(1.0, 0.95, 0.75))
	btn.add_theme_color_override("font_pressed_color", Color(0.75, 0.7, 0.55))


static func icon_atlas(index: int) -> AtlasTexture:
	## IconSet RTP neste pack: ~16×N ícones de 24×24.
	var sheet := load(PATH_ICONSET) as Texture2D
	if sheet == null:
		return null
	const CELL := 24
	var cols := maxi(1, sheet.get_width() / CELL)
	var atlas := AtlasTexture.new()
	atlas.atlas = sheet
	var col := index % cols
	var row := int(index / cols)
	atlas.region = Rect2(col * CELL, row * CELL, CELL, CELL)
	atlas.filter_clip = true
	return atlas
