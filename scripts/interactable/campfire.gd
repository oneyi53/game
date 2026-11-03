class_name Campfire
extends Node2D

const WorldProjectionScript = preload("res://scripts/core/world_projection.gd")

# Placeholder campfire marker, drawn in code like the map: an orange
# circle with a flame dot. No art asset, no gameplay logic here;
# interaction (fog prompt / wood check / dispel) lives in Main,
# exactly like the chest, so this node can never lock a zone.

func _draw() -> void:
    draw_set_transform(WorldProjectionScript.world_to_screen(global_position) - global_position)
    # Clear readable firepit: stone ring, crossed logs and a tall flame.
    draw_set_transform(WorldProjectionScript.world_to_screen(global_position) - global_position, 0.0, Vector2(1.0, 0.42))
    draw_circle(Vector2.ZERO, 25.0, Color(0.28, 0.22, 0.16, 0.55))
    draw_arc(Vector2.ZERO, 23.0, 0.0, TAU, 32, Color(0.72, 0.66, 0.52), 4.0, true)
    draw_set_transform(WorldProjectionScript.world_to_screen(global_position) - global_position)
    draw_line(Vector2(-15.0, 7.0), Vector2(15.0, -7.0), Color(0.16, 0.12, 0.1), 7.0)
    draw_line(Vector2(-15.0, 7.0), Vector2(15.0, -7.0), Color(0.56, 0.34, 0.18), 4.0)
    draw_line(Vector2(15.0, 7.0), Vector2(-15.0, -7.0), Color(0.16, 0.12, 0.1), 7.0)
    draw_line(Vector2(15.0, 7.0), Vector2(-15.0, -7.0), Color(0.66, 0.4, 0.2), 4.0)
    draw_colored_polygon(PackedVector2Array([Vector2(-8.0, -4.0), Vector2(-5.0, -17.0), Vector2(0.0, -28.0), Vector2(5.0, -17.0), Vector2(8.0, -4.0), Vector2(0.0, 1.0)]), Color(1.0, 0.42, 0.08))
    draw_colored_polygon(PackedVector2Array([Vector2(-4.0, -4.0), Vector2(-2.0, -15.0), Vector2(2.0, -20.0), Vector2(5.0, -7.0), Vector2(0.0, -1.0)]), Color(1.0, 0.86, 0.28))
