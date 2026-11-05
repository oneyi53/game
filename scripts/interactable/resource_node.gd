class_name ResourceNode
extends Node2D

const WorldProjectionScript = preload("res://scripts/core/world_projection.gd")

var resource_id: String = ""
var resource_name: String = "资源"
var resource_type: String = "wood"
var yield_min: int = 2
var yield_max: int = 4
var depleted: bool = false
var world_map_id: String = ""

func setup(p_id: String, p_name: String, p_type: String, p_map_id: String, p_min: int, p_max: int, p_depleted: bool = false) -> void:
    resource_id = p_id
    resource_name = p_name
    resource_type = p_type
    world_map_id = p_map_id
    yield_min = maxi(1, p_min)
    yield_max = maxi(yield_min, p_max)
    depleted = p_depleted
    queue_redraw()

func harvest() -> int:
    if depleted:
        return 0
    depleted = true
    queue_redraw()
    return randi_range(yield_min, yield_max)

func _draw() -> void:
    var offset: Vector2 = WorldProjectionScript.world_to_screen(global_position) - global_position
    draw_set_transform(offset, 0.0, Vector2(1.0, 0.45))
    draw_circle(Vector2.ZERO, 19.0, Color(0.04, 0.12, 0.05, 0.24))
    draw_set_transform(offset)
    if depleted:
        draw_circle(Vector2(0.0, -5.0), 12.0, Color(0.35, 0.31, 0.25, 0.85))
        draw_line(Vector2(-8.0, -12.0), Vector2(8.0, 2.0), Color(0.22, 0.2, 0.17), 3.0)
        draw_line(Vector2(8.0, -12.0), Vector2(-8.0, 2.0), Color(0.22, 0.2, 0.17), 3.0)
        return
    if resource_type == "wood":
        draw_rect(Rect2(-4.0, -31.0, 8.0, 28.0), Color(0.36, 0.21, 0.11))
        draw_circle(Vector2(0.0, -34.0), 17.0, Color(0.16, 0.39, 0.19))
        draw_circle(Vector2(-10.0, -26.0), 11.0, Color(0.21, 0.48, 0.22))
        draw_circle(Vector2(10.0, -26.0), 11.0, Color(0.18, 0.43, 0.2))
        draw_circle(Vector2(0.0, -39.0), 5.0, Color(0.34, 0.59, 0.27))
    else:
        var points := PackedVector2Array([Vector2(-17.0, -2.0), Vector2(-12.0, -22.0), Vector2(1.0, -30.0), Vector2(17.0, -15.0), Vector2(19.0, -2.0)])
        draw_colored_polygon(points, Color(0.43, 0.49, 0.52))
        draw_line(Vector2(-7.0, -17.0), Vector2(2.0, -25.0), Color(0.72, 0.78, 0.78), 3.0)
    draw_string(ThemeDB.fallback_font, Vector2(-26.0, 18.0), resource_name, HORIZONTAL_ALIGNMENT_CENTER, 52.0, 12, Color(1.0, 0.95, 0.78))
