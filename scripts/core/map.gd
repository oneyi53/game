class_name MapDrawer
extends Node2D

const WorldProjectionScript = preload("res://scripts/core/world_projection.gd")
const WorldMaps = preload("res://scripts/core/world_map_manager.gd")
const TREE_SCRIPT = preload("res://scripts/core/tree_visual.gd")
const LANDMARK_SCRIPT = preload("res://scripts/core/landmark_visual.gd")
const TILE: int = 64

const DECORATIONS := {
    "town": {
        "trees": [Vector2(160, 170), Vector2(1040, 170), Vector2(160, 740), Vector2(1040, 740)],
        "landmarks": [{"kind": "fountain", "position": Vector2(600, 450), "radius": 34.0}]
    },
    "moss_crown": {
        "trees": [Vector2(100, 110), Vector2(300, 180), Vector2(1080, 120), Vector2(940, 220), Vector2(140, 760), Vector2(420, 800), Vector2(1080, 740), Vector2(900, 800), Vector2(180, 500), Vector2(1040, 560), Vector2(640, 100), Vector2(760, 820)],
        "landmarks": [{"kind": "tower", "position": Vector2(260, 300), "radius": 30.0}, {"kind": "fountain", "position": Vector2(920, 500), "radius": 28.0}]
    },
    "fallen_leaf": {
        "trees": [Vector2(110, 130), Vector2(310, 110), Vector2(1080, 150), Vector2(980, 760), Vector2(140, 760), Vector2(420, 800), Vector2(180, 500), Vector2(1040, 560)],
        "landmarks": [{"kind": "tree_cluster", "position": Vector2(620, 280), "radius": 36.0}]
    },
    "morning_dew": {
        "trees": [Vector2(100, 160), Vector2(300, 140), Vector2(1080, 140), Vector2(980, 220), Vector2(140, 760), Vector2(420, 790), Vector2(1080, 740), Vector2(900, 800)],
        "landmarks": [{"kind": "tree_cluster", "position": Vector2(600, 450), "radius": 36.0}]
    }
}

var active_map_id: String = WorldMaps.MOSS_CROWN
var decoration_nodes: Array[Node2D] = []
var blocker_nodes: Array[StaticBody2D] = []

func set_active_map(map_id: String) -> void:
    var manager = WorldMaps.new()
    if not manager.is_known_map(map_id):
        push_warning("Unknown map id: " + map_id)
        return
    active_map_id = map_id
    _refresh_decorations()
    queue_redraw()

func get_active_map_id() -> String:
    return active_map_id

func _ready() -> void:
    _build_decorations()
    _refresh_decorations()

func _build_decorations() -> void:
    for map_id in DECORATIONS.keys():
        var spec: Dictionary = DECORATIONS[map_id]
        for tree_pos in spec["trees"]:
            var tree := Node2D.new()
            tree.set_script(TREE_SCRIPT)
            tree.position = tree_pos
            tree.set_meta("map_id", str(map_id))
            add_child(tree)
            decoration_nodes.append(tree)
            var blocker := _add_blocker(tree_pos + Vector2(0.0, -8.0), 18.0)
            blocker.set_meta("map_id", str(map_id))
        for landmark_spec in spec["landmarks"]:
            var landmark := Node2D.new()
            landmark.set_script(LANDMARK_SCRIPT)
            landmark.position = landmark_spec["position"]
            landmark.set_meta("map_id", str(map_id))
            add_child(landmark)
            landmark.setup(str(landmark_spec["kind"]))
            decoration_nodes.append(landmark)
            var landmark_blocker := _add_blocker(landmark_spec["position"] + Vector2(0.0, -8.0), float(landmark_spec["radius"]))
            landmark_blocker.set_meta("map_id", str(map_id))

func _add_blocker(at: Vector2, radius: float) -> StaticBody2D:
    var body := StaticBody2D.new()
    body.position = at
    body.collision_layer = 1
    body.collision_mask = 1
    var shape := CollisionShape2D.new()
    var circle := CircleShape2D.new()
    circle.radius = radius
    shape.shape = circle
    body.add_child(shape)
    add_child(body)
    blocker_nodes.append(body)
    return body

func _refresh_decorations() -> void:
    for node in decoration_nodes:
        var belongs: bool = str(node.get_meta("map_id", "")) == active_map_id
        node.visible = belongs
        node.process_mode = Node.PROCESS_MODE_INHERIT if belongs else Node.PROCESS_MODE_DISABLED
    for body in blocker_nodes:
        var belongs: bool = str(body.get_meta("map_id", "")) == active_map_id
        body.set_deferred("collision_layer", 1 if belongs else 0)
        body.set_deferred("collision_mask", 1 if belongs else 0)

func _projected_rect(rect: Rect2) -> PackedVector2Array:
    return WorldProjectionScript.world_rect_to_screen_polygon(rect)

func _draw_ground_tile(x: int, y: int, color: Color) -> void:
    draw_colored_polygon(_projected_rect(Rect2(float(x), float(y), float(TILE), float(TILE))), color)

func _draw_dot(world_position: Vector2, radius: float, color: Color) -> void:
    draw_circle(WorldProjectionScript.world_to_screen(world_position), radius, color)

func _draw() -> void:
    var manager = WorldMaps.new()
    var bounds: Rect2 = manager.map_bounds(active_map_id)
    var town: bool = active_map_id == WorldMaps.TOWN
    var background: Color = Color(0.22, 0.38, 0.25) if town else Color(0.34, 0.62, 0.34)
    draw_rect(Rect2(-1000.0, -1000.0, 3400.0, 2700.0), background)
    for xi in range(0, int(bounds.size.x), TILE):
        for yi in range(0, int(bounds.size.y), TILE):
            var odd: bool = (int(xi / TILE) + int(yi / TILE)) % 2 == 0
            var color: Color
            if town:
                color = Color(0.66, 0.59, 0.43) if odd else Color(0.72, 0.65, 0.49)
            elif active_map_id == WorldMaps.FALLEN_LEAF:
                color = Color(0.55, 0.58, 0.31) if odd else Color(0.62, 0.61, 0.34)
            elif active_map_id == WorldMaps.MORNING_DEW:
                color = Color(0.37, 0.69, 0.55) if odd else Color(0.43, 0.75, 0.61)
            else:
                color = Color(0.45, 0.76, 0.36) if odd else Color(0.5, 0.8, 0.4)
            _draw_ground_tile(xi, yi, color)
    var outline := _projected_rect(bounds)
    outline.append(outline[0])
    draw_polyline(outline, Color(0.2, 0.35, 0.2), 5.0, true)
    var title: String = manager.map_name(active_map_id)
    var font = ThemeDB.fallback_font
    if font != null:
        var label_pos: Vector2 = WorldProjectionScript.world_to_screen(bounds.position + Vector2(40.0, 55.0))
        var label_width: float = font.get_string_size(title).x + 34.0
        draw_rect(Rect2(label_pos.x - 12.0, label_pos.y - 27.0, label_width, 38.0), Color(0.08, 0.19, 0.12, 0.82))
        draw_string(font, label_pos, title, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color(0.96, 0.94, 0.78))
    if town:
        for point in [Vector2(500, 450), Vector2(564, 450), Vector2(628, 450), Vector2(692, 450), Vector2(628, 514)]:
            _draw_ground_tile(int(point.x), int(point.y), Color(0.82, 0.75, 0.61))
    elif active_map_id == WorldMaps.FALLEN_LEAF:
        for point in [Vector2(240, 240), Vector2(420, 300), Vector2(760, 260), Vector2(940, 620)]:
            _draw_dot(point, 5.0, Color(0.84, 0.65, 0.27))
    elif active_map_id == WorldMaps.MORNING_DEW:
        for point in [Vector2(260, 260), Vector2(480, 620), Vector2(860, 280), Vector2(1040, 660)]:
            _draw_dot(point, 5.0, Color(0.68, 0.9, 0.82))
    else:
        for point in [Vector2(260, 480), Vector2(500, 620), Vector2(900, 480), Vector2(1100, 700)]:
            _draw_dot(point, 4.0, Color(1.0, 0.85, 0.2))
