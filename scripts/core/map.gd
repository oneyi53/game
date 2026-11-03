class_name MapDrawer
extends Node2D

# Static map art is projected for display only. All gameplay positions
# remain in the original 1600x1200 logical coordinate system.
const Projection = preload("res://scripts/core/world_projection.gd")

const MAP_WIDTH: int = 1600
const MAP_HEIGHT: int = 1200
const TILE: int = 64

var tree_positions: Array = [
    Vector2(120, 120), Vector2(300, 180), Vector2(1480, 140), Vector2(1320, 220),
    Vector2(140, 1040), Vector2(420, 1080), Vector2(1500, 1020), Vector2(1240, 1080),
    Vector2(180, 560), Vector2(1420, 640), Vector2(640, 120), Vector2(980, 1080),
    Vector2(220, 320), Vector2(1380, 880), Vector2(760, 240), Vector2(520, 920),
]

func _project(point: Vector2) -> Vector2:
    return Projection.world_to_screen(point)

func _projected_rect(rect: Rect2) -> PackedVector2Array:
    return Projection.world_rect_to_screen_polygon(rect)

func _draw_region(rect: Rect2, fill_color: Color, line_color: Color, line_width: float) -> void:
    var polygon: PackedVector2Array = _projected_rect(rect)
    draw_colored_polygon(polygon, fill_color)
    var outline := PackedVector2Array(polygon)
    outline.append(polygon[0])
    draw_polyline(outline, line_color, line_width, true)

func _draw_ground_tile(x: int, y: int, color: Color) -> void:
    var rect := Rect2(float(x), float(y), float(TILE), float(TILE))
    draw_colored_polygon(_projected_rect(rect), color)

func _draw_dot(world_position: Vector2, radius: float, color: Color) -> void:
    draw_circle(_project(world_position), radius, color)

func _draw_tree(world_position: Vector2) -> void:
    # The trunk is anchored at the projected ground point. Tree depth
    # sorting with mobile actors is handled by the shared render layer
    # in the next implementation stage.
    var foot: Vector2 = _project(world_position)
    draw_rect(Rect2(foot.x - 3.0, foot.y - 17.0, 6.0, 17.0), Color(0.45, 0.3, 0.15))
    draw_circle(foot + Vector2(0.0, -26.0), 18.0, Color(0.15, 0.55, 0.25))
    draw_circle(foot + Vector2(-9.0, -20.0), 10.0, Color(0.2, 0.62, 0.3))
    draw_circle(foot + Vector2(9.0, -33.0), 7.0, Color(0.25, 0.68, 0.35))

func _draw() -> void:
    # 1600x1200 logical map -> 1400x700 projected ground diamond.
    # Each 64x64 logical tile becomes a 64x32 screen-space diamond.
    for xi in range(0, MAP_WIDTH, TILE):
        for yi in range(0, MAP_HEIGHT, TILE):
            var odd: bool = (int(xi / TILE) + int(yi / TILE)) % 2 == 0
            var tile_color: Color = Color(0.45, 0.76, 0.36) if odd else Color(0.5, 0.8, 0.4)
            _draw_ground_tile(xi, yi, tile_color)

    var map_outline := Projection.map_corners()
    map_outline.append(map_outline[0])
    draw_polyline(map_outline, Color(0.2, 0.45, 0.2), 5.0, true)

    # Region boundaries retain their original logical rectangles.
    _draw_region(
        Rect2(200.0, 40.0, 1200.0, 280.0),
        Color(0.1, 0.4, 0.2, 0.12), Color(0.1, 0.4, 0.2), 3.0
    )
    _draw_region(
        Rect2(40.0, 880.0, 720.0, 280.0),
        Color(0.1, 0.35, 0.3, 0.12), Color(0.1, 0.35, 0.3), 3.0
    )
    _draw_region(
        Rect2(840.0, 880.0, 720.0, 280.0),
        Color(0.5, 0.4, 0.1, 0.12), Color(0.5, 0.4, 0.1), 3.0
    )

    var label_font = ThemeDB.fallback_font
    if label_font != null:
        draw_string(label_font, _project(Vector2(800.0, 180.0)), "苔冠空地")
        draw_string(label_font, _project(Vector2(400.0, 1010.0)), "落叶幽谷")
        draw_string(label_font, _project(Vector2(1200.0, 1010.0)), "朝露林地")

    # Decoration positions are still authored in logical world space.
    for flower in [Vector2(260.0, 480.0), Vector2(500.0, 620.0), Vector2(900.0, 480.0), Vector2(1100.0, 700.0)]:
        _draw_dot(flower, 3.0, Color(1.0, 0.85, 0.2))
        _draw_dot(flower + Vector2(6.0, 6.0), 2.0, Color(1.0, 0.55, 0.35))

    for pebble in [Vector2(400.0, 420.0), Vector2(760.0, 760.0), Vector2(1180.0, 520.0)]:
        _draw_dot(pebble, 2.5, Color(0.75, 0.75, 0.7))

    for stone in [Vector2(320.0, 180.0), Vector2(900.0, 260.0), Vector2(1250.0, 120.0)]:
        _draw_dot(stone, 6.0, Color(0.65, 0.85, 0.7))
        _draw_dot(stone + Vector2(4.0, -4.0), 2.5, Color(0.35, 0.7, 0.4))

    for leaf_pos in [Vector2(120.0, 960.0), Vector2(300.0, 1040.0), Vector2(520.0, 960.0), Vector2(660.0, 1080.0), Vector2(200.0, 1120.0)]:
        _draw_dot(leaf_pos, 3.0, Color(1.0, 0.75, 0.2))
        _draw_dot(leaf_pos + Vector2(7.0, 3.0), 2.0, Color(1.0, 0.55, 0.3))

    for puddle in [Vector2(1000.0, 1000.0), Vector2(1300.0, 1120.0), Vector2(1450.0, 960.0)]:
        _draw_dot(puddle, 7.0, Color(0.55, 0.8, 1.0, 0.55))

    # Bridge: transform the complete logical rectangle, not just its origin.
    draw_colored_polygon(
        _projected_rect(Rect2(1120.0, 1020.0, 60.0, 10.0)),
        Color(0.6, 0.45, 0.25)
    )

    for tree_pos in tree_positions:
        _draw_tree(tree_pos)
