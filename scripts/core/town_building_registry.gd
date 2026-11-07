class_name TownBuildingRegistry
extends RefCounted

const WorldProjectionScript = preload("res://scripts/core/world_projection.gd")

const BUILDINGS := [
    {"id": "recruit", "title": "英雄招募所", "subtitle": "招募", "world_position": Vector2(900.0, 1050.0), "color": Color(0.78, 0.58, 0.25), "panel": "recruit"},
    {"id": "camp", "title": "营地工坊", "subtitle": "建设", "world_position": Vector2(2100.0, 1050.0), "color": Color(0.38, 0.62, 0.42), "panel": "camp"},
    {"id": "equipment", "title": "装备工坊", "subtitle": "装备", "world_position": Vector2(900.0, 1550.0), "color": Color(0.48, 0.58, 0.78), "panel": "equipment"},
    {"id": "backpack", "title": "仓库", "subtitle": "背包", "world_position": Vector2(2100.0, 1550.0), "color": Color(0.68, 0.48, 0.38), "panel": "backpack"}
]

static func entries() -> Array:
    return BUILDINGS.duplicate(true)

static func entry(building_id: String) -> Dictionary:
    for item in BUILDINGS:
        if str(item["id"]) == building_id:
            return item.duplicate(true)
    return {}

static func panel_for(building_id: String) -> String:
    var item: Dictionary = entry(building_id)
    return str(item.get("panel", ""))

static func projected_position(building_id: String) -> Vector2:
    var item: Dictionary = entry(building_id)
    if item.is_empty():
        return Vector2(-10000.0, -10000.0)
    return WorldProjectionScript.world_to_screen(item["world_position"])

static func hit_test(projected_position_value: Vector2) -> String:
    for item in BUILDINGS:
        var center: Vector2 = WorldProjectionScript.world_to_screen(item["world_position"])
        if projected_position_value.distance_to(center) <= 46.0:
            return str(item["id"])
    return ""
