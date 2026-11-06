class_name MapDrawer
extends Node2D

const WorldProjectionScript = preload("res://scripts/core/world_projection.gd")
const WorldMaps = preload("res://scripts/core/world_map_manager.gd")
const TREE_SCRIPT = preload("res://scripts/core/tree_visual.gd")
const LANDMARK_SCRIPT = preload("res://scripts/core/landmark_visual.gd")
const TOWN_BUILDINGS = preload("res://scripts/core/town_building_registry.gd")
const TILE: int = 128

signal building_pressed(building_id: String)

const DECORATIONS := {
    "town": {
        "trees": [Vector2(160, 170), Vector2(1040, 170), Vector2(160, 740), Vector2(1040, 740), Vector2(340, 180), Vector2(860, 180), Vector2(1240, 420), Vector2(220, 520), Vector2(1180, 900), Vector2(420, 1120), Vector2(900, 1180), Vector2(1360, 1120)],
        "landmarks": [{"kind": "fountain", "position": Vector2(600, 450), "radius": 34.0}]
    },
    "moss_crown": {
        "trees": [Vector2(100, 110), Vector2(300, 180), Vector2(1080, 120), Vector2(940, 220), Vector2(140, 760), Vector2(420, 800), Vector2(1080, 740), Vector2(1120, 900), Vector2(180, 500), Vector2(1040, 560), Vector2(640, 100), Vector2(760, 820), Vector2(1280, 180), Vector2(1380, 480), Vector2(1260, 980), Vector2(1040, 1220), Vector2(760, 1160), Vector2(360, 1180), Vector2(120, 1080), Vector2(80, 300), Vector2(480, 260), Vector2(680, 940)],
        "landmarks": [{"kind": "tower", "position": Vector2(260, 300), "radius": 30.0}, {"kind": "fountain", "position": Vector2(920, 500), "radius": 28.0}]
    },
    "fallen_leaf": {
        "trees": [Vector2(110, 130), Vector2(310, 110), Vector2(1080, 150), Vector2(980, 760), Vector2(140, 760), Vector2(420, 800), Vector2(180, 500), Vector2(1040, 560), Vector2(1320, 240), Vector2(1320, 1040), Vector2(1080, 1220), Vector2(720, 1180), Vector2(360, 1120), Vector2(80, 980), Vector2(80, 320), Vector2(520, 200), Vector2(820, 360), Vector2(1180, 520)],
        "landmarks": [{"kind": "tree_cluster", "position": Vector2(620, 280), "radius": 36.0}]
    },
    "morning_dew": {
        "trees": [Vector2(100, 160), Vector2(300, 140), Vector2(1080, 140), Vector2(980, 220), Vector2(140, 760), Vector2(420, 790), Vector2(1080, 740), Vector2(900, 800), Vector2(1320, 300), Vector2(1260, 920), Vector2(1020, 1200), Vector2(660, 1180), Vector2(300, 1120), Vector2(80, 960), Vector2(80, 360), Vector2(520, 240), Vector2(820, 420), Vector2(1180, 560)],
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

func _draw_exploration_paths() -> void:
    # Readable route network: outer earth shoulder plus a lighter worn trail.
    # Coordinates remain map-local so camera, collision and save positions agree.
    var routes: Array = []
    if active_map_id == WorldMaps.MOSS_CROWN:
        routes = [
            [Vector2(600, 620), Vector2(520, 560), Vector2(430, 500), Vector2(350, 420), Vector2(300, 320)],
            [Vector2(430, 500), Vector2(520, 420), Vector2(610, 350), Vector2(700, 300), Vector2(780, 250)],
            [Vector2(520, 560), Vector2(640, 610), Vector2(760, 600), Vector2(880, 560), Vector2(980, 500)],
            [Vector2(640, 610), Vector2(700, 700), Vector2(800, 760), Vector2(900, 790)]
        ]
    elif active_map_id == WorldMaps.FALLEN_LEAF:
        routes = [
            [Vector2(600, 650), Vector2(500, 570), Vector2(420, 480), Vector2(360, 380), Vector2(300, 260)],
            [Vector2(420, 480), Vector2(540, 420), Vector2(660, 360), Vector2(760, 300)],
            [Vector2(540, 420), Vector2(660, 500), Vector2(780, 570), Vector2(940, 620), Vector2(900, 780), Vector2(720, 960), Vector2(480, 1120)]
        ]
    elif active_map_id == WorldMaps.MORNING_DEW:
        routes = [
            [Vector2(600, 650), Vector2(500, 570), Vector2(420, 480), Vector2(360, 380), Vector2(260, 260)],
            [Vector2(420, 480), Vector2(560, 420), Vector2(700, 360), Vector2(860, 280)],
            [Vector2(560, 420), Vector2(660, 520), Vector2(760, 600), Vector2(900, 650), Vector2(1040, 660), Vector2(1200, 820), Vector2(1400, 1080)]
        ]
    else:
        return
    for route in routes:
        var projected := PackedVector2Array()
        for point in route:
            projected.append(WorldProjectionScript.world_to_screen(point))
        draw_polyline(projected, Color(0.28, 0.24, 0.16, 0.72), 27.0, true)
        draw_polyline(projected, Color(0.72, 0.62, 0.39, 0.88), 19.0, true)
        draw_polyline(projected, Color(0.82, 0.73, 0.5, 0.52), 2.0, true)

func _draw() -> void:
    var bounds: Rect2 = WorldProjectionScript.projected_bounds()
    var town: bool = active_map_id == WorldMaps.TOWN
    _draw_fullscreen_ground(bounds, town)
    _draw_exploration_paths()
    var font = ThemeDB.fallback_font
    if town:
        _draw_town_buildings()
        var exit_screen: Vector2 = WorldProjectionScript.world_to_screen(Vector2(1460.0, 700.0))
        draw_circle(exit_screen, 38.0, Color(0.08, 0.16, 0.1, 0.75))
        draw_circle(exit_screen, 28.0, Color(0.75, 0.67, 0.36))
        draw_circle(exit_screen, 19.0, Color(0.2, 0.42, 0.25))
        if font != null:
            draw_string(font, exit_screen + Vector2(-52.0, 58.0), "森林入口", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color(1.0, 0.95, 0.75))
    elif active_map_id == WorldMaps.FALLEN_LEAF:
        for point in [Vector2(240, 240), Vector2(420, 300), Vector2(760, 260), Vector2(940, 620)]:
            _draw_dot(point, 5.0, Color(0.84, 0.65, 0.27))
    elif active_map_id == WorldMaps.MORNING_DEW:
        for point in [Vector2(260, 260), Vector2(480, 620), Vector2(860, 280), Vector2(1040, 660)]:
            _draw_dot(point, 5.0, Color(0.68, 0.9, 0.82))
    else:
        for point in [Vector2(260, 480), Vector2(500, 620), Vector2(900, 480), Vector2(1100, 700)]:
            _draw_dot(point, 4.0, Color(1.0, 0.85, 0.2))
        # Locked regional road is visible from the start; the world gate
        # activates only after the regional boss objective is complete.
        var gate_screen: Vector2 = WorldProjectionScript.world_to_screen(Vector2(900.0, 790.0))
        draw_circle(gate_screen, 32.0, Color(0.08, 0.14, 0.1, 0.82))
        draw_circle(gate_screen, 23.0, Color(0.76, 0.66, 0.36))
        draw_circle(gate_screen, 14.0, Color(0.25, 0.42, 0.24))
        if font != null:
            draw_string(font, gate_screen + Vector2(-48.0, 48.0), "幽谷道路", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(1.0, 0.95, 0.75))


func _draw_fullscreen_ground(bounds: Rect2, town: bool) -> void:
    var base: Color
    var detail: Color
    if town:
        base = Color(0.48, 0.39, 0.29)
        detail = Color(0.72, 0.61, 0.43, 0.24)
    elif active_map_id == WorldMaps.FALLEN_LEAF:
        base = Color(0.35, 0.39, 0.22)
        detail = Color(0.73, 0.61, 0.31, 0.2)
    elif active_map_id == WorldMaps.MORNING_DEW:
        base = Color(0.22, 0.48, 0.39)
        detail = Color(0.64, 0.84, 0.68, 0.2)
    else:
        base = Color(0.27, 0.49, 0.24)
        detail = Color(0.7, 0.83, 0.43, 0.2)
    # The ground is a portrait rectangle, not a small isometric diamond.
    # It continues beyond the logical walkable bounds so no empty wedges
    # appear around the screen while the camera tracks the captain.
    draw_rect(Rect2(bounds.position - Vector2(420.0, 180.0), bounds.size + Vector2(840.0, 360.0)), base)
    var cell_size: int = 64
    var columns: int = int(ceil(bounds.size.x / float(cell_size))) + 1
    var rows: int = int(ceil(bounds.size.y / float(cell_size))) + 1
    for cell_x in range(-2, columns + 2):
        for cell_y in range(-2, rows + 2):
            var seed_value: int = abs(cell_x * 37 + cell_y * 61 + cell_x * cell_y * 13) % 17
            var rect := Rect2(
                bounds.position.x + float(cell_x * cell_size),
                bounds.position.y + float(cell_y * cell_size),
                float(cell_size),
                float(cell_size)
            )
            if seed_value % 3 == 0:
                draw_rect(rect, detail)
            var tuft := rect.position + Vector2(10.0 + float(seed_value % 23), 12.0 + float((seed_value * 7) % 31))
            draw_line(tuft, tuft + Vector2(3.0, -5.0), detail, 2.0)
            draw_line(tuft + Vector2(4.0, 2.0), tuft + Vector2(8.0, -3.0), detail, 2.0)

func _draw_town_buildings() -> void:
    var font = ThemeDB.fallback_font
    for item in TOWN_BUILDINGS.entries():
        var center: Vector2 = WorldProjectionScript.world_to_screen(item["world_position"])
        var building_color: Color = item["color"]
        draw_circle(center + Vector2(0.0, 8.0), 34.0, Color(0.08, 0.12, 0.08, 0.28))
        draw_circle(center, 30.0, Color(0.12, 0.2, 0.16, 0.92))
        draw_circle(center, 25.0, building_color)
        var roof := PackedVector2Array([
            center + Vector2(-17.0, -5.0),
            center + Vector2(0.0, -22.0),
            center + Vector2(17.0, -5.0)
        ])
        draw_colored_polygon(roof, Color(0.28, 0.2, 0.14))
        draw_rect(Rect2(center + Vector2(-11.0, -5.0), Vector2(22.0, 17.0)), Color(0.9, 0.82, 0.62))
        draw_rect(Rect2(center + Vector2(-3.0, 2.0), Vector2(6.0, 10.0)), Color(0.35, 0.25, 0.18))
        if font != null:
            var title: String = str(item["subtitle"])
            var text_size: Vector2 = font.get_string_size(title, HORIZONTAL_ALIGNMENT_CENTER, -1, 16)
            draw_rect(Rect2(center.x - text_size.x * 0.5 - 9.0, center.y + 34.0, text_size.x + 18.0, 25.0), Color(0.06, 0.12, 0.09, 0.88))
            draw_string(font, center + Vector2(0.0, 52.0), title, HORIZONTAL_ALIGNMENT_CENTER, -1, 16, Color(1.0, 0.96, 0.82))

func _unhandled_input(event: InputEvent) -> void:
    if active_map_id != WorldMaps.TOWN:
        return
    var pressed: bool = false
    var screen_position := Vector2.ZERO
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
        pressed = true
        screen_position = event.position
    elif event is InputEventScreenTouch and event.pressed:
        pressed = true
        screen_position = event.position
    if not pressed:
        return
    var local_position: Vector2 = make_canvas_position_local(screen_position)
    var building_id: String = TOWN_BUILDINGS.hit_test(local_position)
    if building_id != "":
        building_pressed.emit(building_id)
        get_viewport().set_input_as_handled()
