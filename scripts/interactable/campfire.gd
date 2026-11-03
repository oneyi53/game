class_name Campfire
extends Node2D

const WorldProjectionScript = preload("res://scripts/core/world_projection.gd")
const CAMPFIRE_TEXTURE: Texture2D = preload("res://assets/art-v1/sprites/scene/campfire.png")

# Placeholder campfire marker, drawn in code like the map: an orange
# circle with a flame dot. No art asset, no gameplay logic here;
# interaction (fog prompt / wood check / dispel) lives in Main,
# exactly like the chest, so this node can never lock a zone.

func _draw() -> void:
    var projection_offset: Vector2 = WorldProjectionScript.world_to_screen(global_position) - global_position
    draw_set_transform(projection_offset, 0.0, Vector2(1.0, 0.42))
    draw_circle(Vector2.ZERO, 25.0, Color(0.28, 0.22, 0.16, 0.42))
    draw_set_transform(projection_offset)
    # 512px canvas, bottom anchor (256, 480), displayed at 90px high.
    draw_texture_rect(CAMPFIRE_TEXTURE, Rect2(-45.0, -84.375, 90.0, 90.0), false)
