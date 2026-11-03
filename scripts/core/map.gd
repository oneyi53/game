class_name MapDrawer
extends Node2D

# Code-drawn forest tiles. No external art assets are used.
# The map is decoration plus a fixed play area; movement is clamped
# to the same rectangle by the characters themselves.

const MAP_WIDTH: int = 1600
const MAP_HEIGHT: int = 1200
const TILE: int = 64

var tree_positions: Array = [
    Vector2(120, 120), Vector2(300, 180), Vector2(1480, 140), Vector2(1320, 220),
    Vector2(140, 1040), Vector2(420, 1080), Vector2(1500, 1020), Vector2(1240, 1080),
    Vector2(180, 560), Vector2(1420, 640), Vector2(640, 120), Vector2(980, 1080),
    Vector2(220, 320), Vector2(1380, 880), Vector2(760, 240), Vector2(520, 920),
]

func _draw() -> void:
    for xi in range(0, MAP_WIDTH / TILE):
        for yi in range(0, MAP_HEIGHT / TILE):
            var odd: bool = (xi + yi) % 2 == 0
            var tile_color: Color = Color(0.45, 0.76, 0.36) if odd else Color(0.5, 0.8, 0.4)
            draw_rect(Rect2(float(xi * TILE), float(yi * TILE), float(TILE), float(TILE)), tile_color)
    draw_rect(Rect2(0.0, 0.0, float(MAP_WIDTH), float(MAP_HEIGHT)), Color(0.2, 0.45, 0.2), false, 6.0)
    # Second zone: the Moss Crown Clearing, the northern band. It is
    # only a drawn region marker here; the gate itself lives in
    # main.gd, which spawns its monsters only after the main boss
    # is defeated.
    draw_rect(Rect2(200.0, 40.0, 1200.0, 280.0), Color(0.1, 0.4, 0.2, 0.12))
    draw_rect(Rect2(200.0, 40.0, 1200.0, 280.0), Color(0.1, 0.4, 0.2), false, 4.0)
    var label_font = ThemeDB.fallback_font
    if label_font != null:
        draw_string(label_font, Vector2(220.0, 75.0), "苔冠空地")
    # Third zone: the Fallen Leaf Valley, the southern band. Like
    # the second zone, this is only a drawn region marker; the gate
    # itself lives in main.gd, which spawns its monsters only after
    # the elite boss is defeated.
    draw_rect(Rect2(40.0, 880.0, 720.0, 280.0), Color(0.1, 0.35, 0.3, 0.12))
    draw_rect(Rect2(40.0, 880.0, 720.0, 280.0), Color(0.1, 0.35, 0.3), false, 4.0)
    if label_font != null:
        draw_string(label_font, Vector2(60.0, 915.0), "落叶幽谷")
    # Fourth zone: the Morning Dew Grove, the southeast band. Like
    # the earlier zones, this is only a drawn region marker; the
    # gate itself lives in main.gd, which spawns its monsters only
    # after the third-zone quest is done. It does not overlap the
    # second zone (north) or the third zone (southwest); the main
    # boss spawn at (1300, 900) is inside this box but that boss
    # is already dead by the time this zone can open.
    draw_rect(Rect2(840.0, 880.0, 720.0, 280.0), Color(0.5, 0.4, 0.1, 0.12))
    draw_rect(Rect2(840.0, 880.0, 720.0, 280.0), Color(0.5, 0.4, 0.1), false, 4.0)
    if label_font != null:
        draw_string(label_font, Vector2(860.0, 915.0), "朝露林地")
    # Visual only: fixed decoration dots inside the zones above.
    # Zone rectangles, labels, tree positions and all gameplay
    # coordinates are unchanged; these marks have no collision.
    for flower in [Vector2(260.0, 480.0), Vector2(500.0, 620.0), Vector2(900.0, 480.0), Vector2(1100.0, 700.0)]:
        draw_circle(flower, 4.0, Color(1.0, 0.85, 0.2))
        draw_circle(flower + Vector2(6.0, 6.0), 3.0, Color(1.0, 0.55, 0.35))
    for pebble in [Vector2(400.0, 420.0), Vector2(760.0, 760.0), Vector2(1180.0, 520.0)]:
        draw_circle(pebble, 3.0, Color(0.75, 0.75, 0.7))
    # Moss Crown: moss stones + low grass tufts.
    for stone in [Vector2(320.0, 180.0), Vector2(900.0, 260.0), Vector2(1250.0, 120.0)]:
        draw_circle(stone, 9.0, Color(0.65, 0.85, 0.7))
        draw_circle(stone + Vector2(4.0, -4.0), 3.0, Color(0.35, 0.7, 0.4))
    # Fallen Leaf Valley: golden / coral leaf dots, warm and bright.
    for leaf_pos in [Vector2(120.0, 960.0), Vector2(300.0, 1040.0), Vector2(520.0, 960.0), Vector2(660.0, 1080.0), Vector2(200.0, 1120.0)]:
        draw_circle(leaf_pos, 4.0, Color(1.0, 0.75, 0.2))
        draw_circle(leaf_pos + Vector2(7.0, 3.0), 3.0, Color(1.0, 0.55, 0.3))
    # Morning Dew Grove: puddles + a small wooden bridge.
    for puddle in [Vector2(1000.0, 1000.0), Vector2(1300.0, 1120.0), Vector2(1450.0, 960.0)]:
        draw_circle(puddle, 10.0, Color(0.55, 0.8, 1.0, 0.55))
    draw_rect(Rect2(1120.0, 1020.0, 60.0, 10.0), Color(0.6, 0.45, 0.25))
    for tree_pos in tree_positions:
        draw_rect(Rect2(tree_pos.x - 4.0, tree_pos.y, 8.0, 18.0), Color(0.45, 0.3, 0.15))
        draw_circle(Vector2(tree_pos.x, tree_pos.y - 6.0), 22.0, Color(0.15, 0.55, 0.25))
        draw_circle(Vector2(tree_pos.x - 10.0, tree_pos.y + 2.0), 12.0, Color(0.2, 0.62, 0.3))
        draw_circle(Vector2(tree_pos.x + 10.0, tree_pos.y - 14.0), 8.0, Color(0.25, 0.68, 0.35))
