class_name TreeVisual
extends Node2D

const WorldProjectionScript = preload("res://scripts/core/world_projection.gd")
const TREE_TEXTURE: Texture2D = preload("res://assets/art-v1/sprites/scene/tree_green.png")

func _ready() -> void:
    z_as_relative = false
    z_index = clampi(int(WorldProjectionScript.screen_depth(global_position) / 4.0), 0, 1024)
    queue_redraw()

func _draw() -> void:
    var offset: Vector2 = WorldProjectionScript.world_to_screen(global_position) - global_position
    draw_set_transform(offset, 0.0, Vector2(1.0, 0.42))
    draw_circle(Vector2.ZERO, 18.0, Color(0.08, 0.22, 0.06, 0.28))
    draw_set_transform(offset)
    # Slightly smaller than featured landmarks to keep the walking lanes open.
    draw_texture_rect(TREE_TEXTURE, Rect2(-45.0, -84.375, 90.0, 90.0), false)
