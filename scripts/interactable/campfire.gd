class_name Campfire
extends Node2D

const Projection = preload("res://scripts/core/world_projection.gd")
const CAMPFIRE_TEXTURE: Texture2D = preload("res://assets/art-v1/sprites/scene/campfire.png")

func _draw() -> void:
    var offset: Vector2 = Projection.world_to_screen(global_position) - global_position
    draw_set_transform(offset, 0.0, Vector2(1.0, 0.42))
    draw_circle(Vector2.ZERO, 25.0, Color(0.28, 0.22, 0.16, 0.42))
    draw_set_transform(offset)
    draw_texture_rect(CAMPFIRE_TEXTURE, Rect2(-45.0, -84.375, 90.0, 90.0), false)
