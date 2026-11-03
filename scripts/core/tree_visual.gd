class_name TreeVisual
extends Node2D

const Projection = preload("res://scripts/core/world_projection.gd")

func _ready() -> void:
    z_as_relative = false
    z_index = clampi(int(Projection.screen_depth(global_position) / 4.0), 0, 1024)
    queue_redraw()

func _draw() -> void:
    # Anchor the tree at its logical ground point, but keep its body upright.
    draw_set_transform(Projection.world_to_screen(global_position) - global_position)
    draw_rect(Rect2(-3.0, -17.0, 6.0, 17.0), Color(0.45, 0.3, 0.15))
    draw_circle(Vector2(0.0, -26.0), 18.0, Color(0.15, 0.55, 0.25))
    draw_circle(Vector2(-9.0, -20.0), 10.0, Color(0.2, 0.62, 0.3))
    draw_circle(Vector2(9.0, -33.0), 7.0, Color(0.25, 0.68, 0.35))
