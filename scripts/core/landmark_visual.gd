class_name LandmarkVisual
extends Node2D

const WorldProjectionScript = preload("res://scripts/core/world_projection.gd")

var landmark_kind: String = "tower"

func setup(kind: String) -> void:
    landmark_kind = kind
    z_as_relative = false
    z_index = clampi(int(WorldProjectionScript.screen_depth(global_position) / 4.0), 0, 1024)
    queue_redraw()

func _draw() -> void:
    draw_set_transform(WorldProjectionScript.world_to_screen(global_position) - global_position)
    # Every landmark is anchored at its ground contact point. Silhouettes
    # remain upright and are depth-sorted with heroes and monsters.
    match landmark_kind:
        "tower":
            draw_colored_polygon(PackedVector2Array([Vector2(-16.0, 0.0), Vector2(-13.0, -66.0), Vector2(13.0, -66.0), Vector2(16.0, 0.0)]), Color(0.82, 0.72, 0.52))
            draw_polyline(PackedVector2Array([Vector2(-16.0, 0.0), Vector2(-13.0, -66.0), Vector2(13.0, -66.0), Vector2(16.0, 0.0), Vector2(-16.0, 0.0)]), Color(0.22, 0.18, 0.14), 3.0, true)
            draw_colored_polygon(PackedVector2Array([Vector2(-18.0, -66.0), Vector2(0.0, -88.0), Vector2(18.0, -66.0)]), Color(0.86, 0.38, 0.22))
            draw_rect(Rect2(-5.0, -28.0, 10.0, 18.0), Color(0.35, 0.62, 0.82))
        "fountain":
            draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.42))
            draw_circle(Vector2.ZERO, 28.0, Color(0.55, 0.72, 0.78))
            draw_arc(Vector2.ZERO, 28.0, 0.0, TAU, 32, Color(0.22, 0.32, 0.38), 4.0, true)
            draw_set_transform(WorldProjectionScript.world_to_screen(global_position) - global_position)
            draw_rect(Rect2(-4.0, -38.0, 8.0, 38.0), Color(0.78, 0.78, 0.7))
            draw_circle(Vector2.ZERO + Vector2(0.0, -43.0), 15.0, Color(0.35, 0.78, 0.92))
            draw_circle(Vector2(-4.0, -47.0), 5.0, Color(0.78, 0.96, 1.0))
        "tree_cluster":
            draw_rect(Rect2(-5.0, -42.0, 10.0, 42.0), Color(0.42, 0.27, 0.14))
            draw_circle(Vector2(-12.0, -48.0), 23.0, Color(0.12, 0.55, 0.24))
            draw_circle(Vector2(13.0, -56.0), 20.0, Color(0.2, 0.68, 0.29))
            draw_circle(Vector2(0.0, -70.0), 19.0, Color(0.28, 0.76, 0.32))
            draw_arc(Vector2(0.0, -54.0), 22.0, PI, TAU, 20, Color(0.08, 0.35, 0.16), 3.0)

