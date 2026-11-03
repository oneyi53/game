class_name Chest
extends Area2D

const Projection = preload("res://scripts/core/world_projection.gd")

# A chest that opens once. Opening gives gold and emits "opened",
# which the main scene uses to update gold and auto-save.

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
    draw_set_transform(Projection.world_to_screen(global_position) - global_position)
    # Visual only: same 28x20 box, same open/closed logic.
    if is_open:
        draw_rect(Rect2(-14.0, -10.0, 28.0, 20.0), Color(0.5, 0.35, 0.1))
        draw_rect(Rect2(-14.0, -10.0, 28.0, 4.0), Color(0.35, 0.25, 0.08))
    else:
        draw_rect(Rect2(-14.0, -10.0, 28.0, 20.0), Color(1.0, 0.8, 0.2))
        draw_rect(Rect2(-14.0, -10.0, 28.0, 6.0), Color(0.8, 0.6, 0.1))
        draw_circle(Vector2(0.0, 0.0), 3.0, Color(1.0, 0.9, 0.4))
