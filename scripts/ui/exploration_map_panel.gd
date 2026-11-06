extends Control

signal close_requested
signal region_selected(map_index: int)
signal campfire_teleport_requested(marker_index: int)

const MAP_SIZE := Vector2(1600.0, 1400.0)
const CELL_SIZE := 80.0
const MAP_RECT := Rect2(40.0, 220.0, 640.0, 560.0)
const CARD_RECT := Rect2(18.0, 86.0, 684.0, 1100.0)
const REGION_IDS := ["town", "moss_crown", "fallen_leaf", "morning_dew"]
const REGION_NAMES := ["营地", "苔冠空地", "落叶幽谷", "朝露林地"]

var current_map_id: String = "town"
var current_map_name: String = "王朝营地"
var player_position: Vector2 = Vector2.ZERO
var explored_cells: Array = []
var enemy_positions: Array = []
var resource_positions: Array = []
var teleport_positions: Array = []
var unlocked_maps: Array = ["town", "moss_crown"]
var exploration_applicable: bool = false
var exploration_percent: int = 0

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    mouse_filter = Control.MOUSE_FILTER_STOP
    visible = false

func set_snapshot(map_id: String, map_name: String, player_pos: Vector2, explored: Array, enemies: Array, resources: Array, teleports: Array, unlocked: Array, applicable: bool, percent: int) -> void:
    current_map_id = map_id
    current_map_name = map_name
    player_position = player_pos
    explored_cells = explored.duplicate()
    enemy_positions = enemies.duplicate()
    resource_positions = resources.duplicate()
    teleport_positions = teleports.duplicate()
    unlocked_maps = unlocked.duplicate()
    exploration_applicable = applicable
    exploration_percent = percent
    queue_redraw()

func _draw() -> void:
    draw_rect(Rect2(Vector2.ZERO, size), Color(0.015, 0.025, 0.025, 0.78))
    draw_rect(CARD_RECT, Color(0.055, 0.085, 0.075, 0.98), true, 18.0)
    draw_rect(CARD_RECT, Color(0.43, 0.57, 0.39, 0.95), false, 2.0)
    _draw_text("世界地图", Vector2(42.0, 132.0), 34, Color(0.94, 0.89, 0.70))
    _draw_text(current_map_name, Vector2(42.0, 178.0), 24, Color(0.82, 0.91, 0.75))
    _draw_text("×", Vector2(640.0, 140.0), 42, Color(0.95, 0.88, 0.72))
    var progress_text := "探索度 %d%%" % exploration_percent if exploration_applicable else "安全区域 · 无探索度统计"
    _draw_text(progress_text, Vector2(42.0, 205.0), 18, Color(0.77, 0.84, 0.70))
    _draw_map_surface()
    _draw_text("地图标记", Vector2(42.0, 830.0), 22, Color(0.94, 0.89, 0.70))
    _draw_legend_item(Vector2(48.0, 875.0), Color(0.35, 0.82, 1.0), "队伍")
    _draw_legend_item(Vector2(210.0, 875.0), Color(0.95, 0.34, 0.28), "怪物 / 首领")
    _draw_legend_item(Vector2(420.0, 875.0), Color(1.0, 0.78, 0.25), "资源")
    _draw_legend_item(Vector2(48.0, 925.0), Color(0.45, 0.94, 0.65), "营火 / 传送点")
    _draw_text("点击下方区域切换地图（受主线进度限制）", Vector2(42.0, 1015.0), 17, Color(0.72, 0.78, 0.68))
    var tab_y := 1045.0
    var tab_width := 154.0
    for i in range(REGION_IDS.size()):
        var tab_rect := Rect2(34.0 + float(i) * 164.0, tab_y, tab_width, 76.0)
        var unlocked: bool = REGION_IDS[i] in unlocked_maps
        var active: bool = REGION_IDS[i] == current_map_id
        var fill := Color(0.22, 0.34, 0.24, 1.0) if active else Color(0.12, 0.18, 0.15, 1.0)
        if not unlocked:
            fill = Color(0.10, 0.11, 0.10, 1.0)
        draw_rect(tab_rect, fill, true, 8.0)
        draw_rect(tab_rect, Color(0.70, 0.70, 0.48, 0.9) if active else Color(0.28, 0.37, 0.29, 1.0), false, 2.0, true)
        var tab_text: String = REGION_NAMES[i] if unlocked else "未解锁"
        _draw_text(tab_text, Vector2(tab_rect.position.x + 12.0, tab_rect.position.y + 46.0), 18, Color(0.91, 0.88, 0.72) if unlocked else Color(0.43, 0.46, 0.42))
    _draw_text("探索地图 · 逐步揭开未知区域", Vector2(42.0, 1155.0), 16, Color(0.54, 0.64, 0.54))

func _draw_map_surface() -> void:
    draw_rect(MAP_RECT, Color(0.15, 0.22, 0.16), true)
    draw_rect(MAP_RECT, Color(0.61, 0.67, 0.43), false, 2.0)
    for x in range(20):
        for y in range(18):
            var cell_key := str(x) + ":" + str(y)
            var cell_rect := Rect2(MAP_RECT.position.x + float(x) * MAP_RECT.size.x / 20.0, MAP_RECT.position.y + float(y) * MAP_RECT.size.y / 18.0, MAP_RECT.size.x / 20.0, MAP_RECT.size.y / 18.0)
            # The town is a safe hub, not an unexplored wilderness map.
            # Render its full layout instead of covering it with exploration fog.
            if current_map_id == "town" or cell_key in explored_cells:
                var terrain_tone := 0.18 + float((x * 7 + y * 3) % 8) * 0.012
                draw_rect(cell_rect, Color(0.19 + terrain_tone * 0.25, 0.30 + terrain_tone, 0.18 + terrain_tone * 0.20, 1.0))
                draw_rect(cell_rect, Color(0.72, 0.78, 0.56, 0.10), false, 1.0)
            else:
                draw_rect(cell_rect, Color(0.018, 0.032, 0.028, 0.97))
    for marker in resource_positions:
        _draw_marker(marker, Color(1.0, 0.78, 0.25), 7.0)
    for marker in teleport_positions:
        _draw_marker(marker, Color(0.45, 0.94, 0.65), 10.0)
    for marker in enemy_positions:
        _draw_marker(marker, Color(0.95, 0.34, 0.28), 8.0)
    # The party marker is useful in every region, including the safe hub.
    _draw_marker(player_position, Color(0.35, 0.82, 1.0), 11.0)
    draw_arc(_map_to_panel(player_position), 17.0, 0.0, TAU, 32, Color(0.70, 0.92, 1.0), 2.0)

func _draw_marker(world_pos: Vector2, color: Color, radius: float) -> void:
    var point := _map_to_panel(world_pos)
    if MAP_RECT.has_point(point):
        draw_circle(point, radius + 2.0, Color(0.02, 0.03, 0.02, 0.9))
        draw_circle(point, radius, color)

func _map_to_panel(world_pos: Vector2) -> Vector2:
    return MAP_RECT.position + Vector2(world_pos.x / MAP_SIZE.x * MAP_RECT.size.x, world_pos.y / MAP_SIZE.y * MAP_RECT.size.y)

func _draw_legend_item(point: Vector2, color: Color, label: String) -> void:
    draw_circle(point, 8.0, color)
    _draw_text(label, point + Vector2(16.0, 6.0), 18, Color(0.83, 0.86, 0.77))

func _draw_text(value: String, point: Vector2, font_size: int, color: Color) -> void:
    draw_string(ThemeDB.fallback_font, point, value, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size, color)

func _gui_input(event: InputEvent) -> void:
    var pressed := false
    var pointer := Vector2.ZERO
    if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        pressed = true
        pointer = event.position
    elif event is InputEventScreenTouch and event.pressed:
        pressed = true
        pointer = event.position
    if not pressed:
        return
    if Rect2(610.0, 95.0, 72.0, 72.0).has_point(pointer):
        close_requested.emit()
        accept_event()
        return
    if MAP_RECT.has_point(pointer):
        for marker_index in range(teleport_positions.size()):
            var marker_position: Vector2 = _map_to_panel(teleport_positions[marker_index])
            if marker_position.distance_to(pointer) <= 24.0:
                campfire_teleport_requested.emit(marker_index)
                accept_event()
                return
    var tab_y := 1045.0
    var tab_width := 154.0
    for i in range(REGION_IDS.size()):
        var tab_rect := Rect2(34.0 + float(i) * 164.0, tab_y, tab_width, 76.0)
        if tab_rect.has_point(pointer) and REGION_IDS[i] in unlocked_maps:
            region_selected.emit(i)
            accept_event()
            return
