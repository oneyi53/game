class_name Campfire
extends Node2D

# Visual uses the original campfire sprite; interaction and progression
# remain in Main so this node cannot independently unlock a zone.
const CAMPFIRE_TEXTURE: Texture2D = preload("res://assets/art-v1/sprites/scene/campfire.png")

func _draw() -> void:
    draw_texture_rect(CAMPFIRE_TEXTURE, Rect2(-34.0, -48.0, 68.0, 68.0), false)
