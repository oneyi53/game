class_name ExplorationFog
extends Node2D

const WorldProjectionScript = preload("res://scripts/core/world_projection.gd")
const WorldMaps = preload("res://scripts/core/world_map_manager.gd")
const CELL_SIZE: float = 80.0
const REVEAL_RADIUS: float = 260.0
const FOG_COLOR := Color(0.025, 0.045, 0.04, 0.92)

var active_map_id: String = WorldMaps.MOSS_CROWN
var explored: Dictionary = {}

func set_map_state(map_id: String, saved_cells: Array) -> void:
    active_map_id = map_id
    explored.clear()
    for value in saved_cells:
        explored[str(value)] = true
    queue_redraw()

func reveal_around(world_position: Vector2) -> int:
    if active_map_id == WorldMaps.TOWN:
        return 0
    var radius_cells: int = int(ceil(REVEAL_RADIUS / CELL_SIZE)) + 1
    var center_x: int = int(floor(world_position.x / CELL_SIZE))
    var center_y: int = int(floor(world_position.y / CELL_SIZE))
    var newly_revealed: int = 0
    var half_diagonal: float = CELL_SIZE * 0.7072
    for cell_x in range(center_x - radius_cells, center_x + radius_cells + 1):
        for cell_y in range(center_y - radius_cells, center_y + radius_cells + 1):
            var rect := Rect2(float(cell_x) * CELL_SIZE, float(cell_y) * CELL_SIZE, CELL_SIZE, CELL_SIZE)
            if rect.position.x < 0.0 or rect.position.y < 0.0:
                continue
            if rect.end.x > WorldProjectionScript.MAP_WIDTH or rect.end.y > WorldProjectionScript.MAP_HEIGHT:
                continue
            var cell_center: Vector2 = rect.position + Vector2.ONE * CELL_SIZE * 0.5
            if cell_center.distance_to(world_position) > REVEAL_RADIUS + half_diagonal:
                continue
            var key: String = str(cell_x) + ":" + str(cell_y)
            if not explored.has(key):
                explored[key] = true
                newly_revealed += 1
    if newly_revealed > 0:
        queue_redraw()
    return newly_revealed

func get_saved_cells() -> Array:
    var result: Array = explored.keys()
    result.sort()
    return result

func _draw() -> void:
    if active_map_id == WorldMaps.TOWN:
        return
    var columns: int = int(ceil(WorldProjectionScript.MAP_WIDTH / CELL_SIZE))
    var rows: int = int(ceil(WorldProjectionScript.MAP_HEIGHT / CELL_SIZE))
    for cell_x in range(columns):
        for cell_y in range(rows):
            var key: String = str(cell_x) + ":" + str(cell_y)
            if explored.has(key):
                continue
            var rect := Rect2(float(cell_x) * CELL_SIZE, float(cell_y) * CELL_SIZE, CELL_SIZE, CELL_SIZE)
            draw_colored_polygon(WorldProjectionScript.world_rect_to_screen_polygon(rect), FOG_COLOR)
