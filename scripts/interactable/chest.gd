class_name Chest
extends Area2D

const WorldProjectionScript = preload("res://scripts/core/world_projection.gd")
const CHEST_TEXTURE: Texture2D = preload("res://assets/art-v1/sprites/scene/chest.png")

signal opened(gold_amount)

var is_open: bool = false
var reward_gold: int = 0

func setup(p_reward: int, p_opened: bool) -> void:
    reward_gold = p_reward
    is_open = p_opened
    queue_redraw()

func try_open() -> int:
    if is_open:
        return 0
    is_open = true
    queue_redraw()
    opened.emit(reward_gold)
    return reward_gold

func _draw() -> void:
    var offset: Vector2 = WorldProjectionScript.world_to_screen(global_position) - global_position
    draw_set_transform(offset, 0.0, Vector2(1.0, 0.45))
    draw_circle(Vector2.ZERO, 13.0, Color(0.05, 0.18, 0.05, 0.25))
    draw_set_transform(offset)
    draw_texture_rect(CHEST_TEXTURE, Rect2(-30.0, -56.25, 60.0, 60.0), false)
    if is_open:
        draw_line(Vector2(-8.0, -12.0), Vector2(8.0, -18.0), Color(0.95, 0.8, 0.42, 0.9), 2.0)
