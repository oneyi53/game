class_name LandmarkVisual
extends Node2D

const WorldProjectionScript = preload("res://scripts/core/world_projection.gd")
const LANDMARK_TEXTURES := {
    "tower": preload("res://assets/art-v1/sprites/scene/tower.png"),
    "fountain": preload("res://assets/art-v1/sprites/scene/fountain.png"),
    "tree_cluster": preload("res://assets/art-v1/sprites/scene/tree_yellow.png")
}
const LANDMARK_HEIGHTS := {"tower": 180.0, "fountain": 150.0, "tree_cluster": 150.0}

var landmark_kind: String = "tower"

func setup(kind: String) -> void:
    landmark_kind = kind
    z_as_relative = false
    z_index = clampi(int(WorldProjectionScript.screen_depth(global_position) / 4.0), 0, 1024)
    queue_redraw()

func _draw() -> void:
    var offset: Vector2 = WorldProjectionScript.world_to_screen(global_position) - global_position
    var texture: Texture2D = LANDMARK_TEXTURES.get(landmark_kind)
    if texture == null:
        return
    var display_height: float = float(LANDMARK_HEIGHTS.get(landmark_kind, 120.0))
    draw_set_transform(offset, 0.0, Vector2(1.0, 0.42))
    draw_circle(Vector2.ZERO, display_height * 0.22, Color(0.05, 0.18, 0.05, 0.25))
    draw_set_transform(offset)
    var display_width: float = display_height
    var top: float = display_height * 480.0 / 512.0
    draw_texture_rect(texture, Rect2(-display_width * 0.5, -top, display_width, display_height), false)
