extends StaticBody2D

## Prédio bloqueador com visual retangular.

@export var building_size: Vector2 = Vector2(160, 120)
@export var building_color: Color = Color(0.22, 0.2, 0.26, 1)
@export var roof_color: Color = Color(0.35, 0.22, 0.22, 1)
@export var label_text: String = ""


func _ready() -> void:
	var shape := RectangleShape2D.new()
	shape.size = building_size
	var col := CollisionShape2D.new()
	col.shape = shape
	add_child(col)

	var body := Polygon2D.new()
	body.color = building_color
	var hx := building_size.x * 0.5
	var hy := building_size.y * 0.5
	body.polygon = PackedVector2Array([
		Vector2(-hx, -hy), Vector2(hx, -hy), Vector2(hx, hy), Vector2(-hx, hy)
	])
	add_child(body)

	var roof := Polygon2D.new()
	roof.color = roof_color
	roof.polygon = PackedVector2Array([
		Vector2(-hx - 8, -hy), Vector2(0, -hy - 36), Vector2(hx + 8, -hy)
	])
	add_child(roof)

	if label_text != "":
		var lab := Label.new()
		lab.text = label_text
		lab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lab.position = Vector2(-hx, hy + 4)
		lab.size = Vector2(building_size.x, 24)
		add_child(lab)
