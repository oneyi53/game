class_name Chest
extends Area2D

# A chest that opens once. Opening gives gold and emits "opened",
# which the main scene uses to update gold and auto-save.
signal opened(gold_amount)

const CHEST_TEXTURE: Texture2D = preload("res://assets/art-v1/sprites/scene/chest.png")

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
    # Reuse the same chest artwork; a muted tint distinguishes claimed chests.
    var tint: Color = Color(0.55, 0.55, 0.55, 1.0) if is_open else Color.WHITE
    draw_texture_rect(CHEST_TEXTURE, Rect2(-32.0, -32.0, 64.0, 64.0), false, tint)
