class_name MapLabelLayer
extends Node2D

# Top-most label layer for the MapDrawer. Region nameplates must render
# above landmark/tree sprites, which are child nodes of MapDrawer and
# therefore always draw on top of MapDrawer's own _draw(). This layer is
# added last inside MapDrawer, so its _draw() runs after every sprite.
# It ALSO needs z_index above the depth range: trees, landmarks and units
# all carry z_index 0..1024 (screen_depth/10), which beats tree order.
# map.gd pins this layer at 4096; do not lower it below 1025.
# Coordinates are the same projected map space MapDrawer._draw() uses.

var label_title: String = ""
var label_pos: Vector2 = Vector2.ZERO
var label_width: float = 0.0

func set_label(title: String, pos: Vector2, width: float) -> void:
	label_title = title
	label_pos = pos
	label_width = width
	queue_redraw()

func _draw() -> void:
	if label_title == "":
		return
	var font: Font = ThemeDB.fallback_font
	if font == null:
		return
	draw_rect(Rect2(label_pos.x - 12.0, label_pos.y - 27.0, label_width, 38.0), Color(0.08, 0.19, 0.12, 0.82))
	draw_string(font, label_pos, label_title, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color(0.96, 0.94, 0.78))
