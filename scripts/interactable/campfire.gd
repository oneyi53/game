class_name Campfire
extends Node2D

const Projection = preload("res://scripts/core/world_projection.gd")

# Placeholder campfire marker, drawn in code like the map: an orange
# circle with a flame dot. No art asset, no gameplay logic here;
# interaction (fog prompt / wood check / dispel) lives in Main,
# exactly like the chest, so this node can never lock a zone.

func _draw() -> void:
    draw_set_transform(Projection.world_to_screen(global_position) - global_position)
    # Visual only: same footprint, no gameplay logic here.
    draw_circle(Vector2.ZERO, 22.0, Color(0.35, 0.25, 0.15, 0.6))
    draw_line(Vector2(-12.0, 8.0), Vector2(12.0, -8.0), Color(0.45, 0.3, 0.15), 3.0)
    draw_line(Vector2(12.0, 8.0), Vector2(-12.0, -8.0), Color(0.45, 0.3, 0.15), 3.0)
    draw_circle(Vector2.ZERO, 14.0, Color(1.0, 0.55, 0.1, 0.9))
    draw_circle(Vector2(0.0, -4.0), 6.0, Color(1.0, 0.85, 0.3, 1.0))
    draw_circle(Vector2(-4.0, -14.0), 2.0, Color(1.0, 0.85, 0.3, 0.8))
    draw_circle(Vector2(5.0, -17.0), 1.5, Color(1.0, 0.85, 0.3, 0.6))
