class_name MapDrawer
extends Node2D

# Static map art is projected for display only. All gameplay positions
# remain in the original 1600x1200 logical coordinate system.
const WorldProjectionScript = preload("res://scripts/core/world_projection.gd")
const TREE_VISUAL_SCRIPT = preload("res://scripts/core/tree_visual.gd")
const LANDMARK_VISUAL_SCRIPT = preload("res://scripts/core/landmark_visual.gd")

const MAP_WIDTH: int = 1600
const MAP_HEIGHT: int = 1200
const TILE: int = 64

const WorldMapManagerScript = preload("res://scripts/core/world_map_manager.gd")
var active_map_id: String = WorldMapManagerScript.MOSS_CROWN

func set_active_map(map_id: String) -> void:
    if not WorldMapManagerScript.new().is_known_map(map_id):
        push_warning("Unknown map id: " + map_id)
        return
    active_map_id = map_id
    queue_redraw()

func get_active_map_id() -> String:
    return active_map_id

var tree_positions: Array = [
    Vector2(120, 120), Vector2(300, 180), Vector2(1480, 140), Vector2(1320, 220),
    Vector2(140, 1040), Vector2(420, 1080), Vector2(1500, 1020), Vector2(1240, 1080),
    Vector2(180, 560), Vector2(1420, 640), Vector2(640, 120), Vector2(980, 1080),
    Vector2(220, 320), Vector2(1380, 880), Vector2(760, 240), Vector2(520, 920),
]

func _ready() -> void:
    # Trees are separate world objects so they can interleave with heroes,
    # monsters, bosses and interactables in one depth-sorted render order.
    for tree_pos in tree_positions:
        var tree := Node2D.new()
        tree.set_script(TREE_VISUAL_SCRIPT)
        tree.position = tree_pos
        add_child(tree)
    # Three fixed landmarks add orientation without filling the walking lanes.
    var landmark_specs: Array = [
        {"kind": "tower", "position": Vector2(320.0, 300.0)},
        {"kind": "fountain", "position": Vector2(1260.0, 520.0)},
        {"kind": "tree_cluster", "position": Vector2(820.0, 1040.0)}
    ]
    for spec in landmark_specs:
        var landmark := Node2D.new()
        landmark.set_script(LANDMARK_VISUAL_SCRIPT)
        landmark.position = spec["position"]
        add_child(landmark)
        landmark.setup(str(spec["kind"]))

func _project(point: Vector2) -> Vector2:
    return WorldProjectionScript.world_to_screen(point)

func _projected_rect(rect: Rect2) -> PackedVector2Array:
    return WorldProjectionScript.world_rect_to_screen_polygon(rect)

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

func _draw() -> void:
    var manager = WorldMapManagerScript.new()
    var bounds: Rect2 = manager.map_bounds(active_map_id)
    var town: bool = active_map_id == WorldMapManagerScript.TOWN
    var background: Color = Color(0.22, 0.38, 0.25) if town else Color(0.34, 0.62, 0.34)
    draw_rect(Rect2(-1000.0, -1000.0, 3400.0, 2700.0), background)

    # Draw only the active map's logical ground. This prevents the former
    # four-region mega-map from appearing as one continuous play space.
    var x0: int = int(floor(bounds.position.x / TILE)) * TILE
    var y0: int = int(floor(bounds.position.y / TILE)) * TILE
    var x1: int = int(ceil(bounds.end.x / TILE)) * TILE
    var y1: int = int(ceil(bounds.end.y / TILE)) * TILE
    for xi in range(x0, x1, TILE):
        for yi in range(y0, y1, TILE):
            var odd: bool = (int(xi / TILE) + int(yi / TILE)) % 2 == 0
            var tile_color: Color
            if town:
                tile_color = Color(0.66, 0.59, 0.43) if odd else Color(0.72, 0.65, 0.49)
            else:
                tile_color = Color(0.45, 0.76, 0.36) if odd else Color(0.5, 0.8, 0.4)
            _draw_ground_tile(xi, yi, tile_color)

    var outline := _projected_rect(bounds)
    outline.append(outline[0])
    draw_polyline(outline, Color(0.2, 0.35, 0.2), 5.0, true)

    var title: String = manager.map_name(active_map_id)
    var font = ThemeDB.fallback_font
    if font != null:
        var label_pos: Vector2 = _project(bounds.position + Vector2(40.0, 55.0))
        var label_width: float = font.get_string_size(title).x + 34.0
        draw_rect(Rect2(label_pos.x - 12.0, label_pos.y - 27.0, label_width, 38.0), Color(0.08, 0.19, 0.12, 0.82))
        draw_string(font, label_pos, title, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color(0.96, 0.94, 0.78))

    # Local paths and accents are deliberately clipped to their own map.
    if town:
        for p in [Vector2(500, 450), Vector2(564, 450), Vector2(628, 450), Vector2(692, 450), Vector2(628, 514)]:
            _draw_ground_tile(int(p.x), int(p.y), Color(0.82, 0.75, 0.61))
        for p in [Vector2(300, 300), Vector2(900, 300), Vector2(300, 650), Vector2(900, 650)]:
            _draw_dot(p, 12.0, Color(0.75, 0.63, 0.38))
    else:
        for flower in [bounds.position + Vector2(100, 120), bounds.position + Vector2(280, 180), bounds.position + Vector2(480, 100)]:
            _draw_dot(flower, 3.0, Color(1.0, 0.85, 0.2))
            _draw_dot(flower + Vector2(6.0, 6.0), 2.0, Color(1.0, 0.55, 0.35))
