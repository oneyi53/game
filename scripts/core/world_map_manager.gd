class_name WorldMapManager
extends RefCounted

# Each area is a self-contained logical world. Gameplay coordinates are
# always map-local (0..1600, 0..1400); projection is a render-only concern.

const TOWN := "town"
const MOSS_CROWN := "moss_crown"
const FALLEN_LEAF := "fallen_leaf"
const MORNING_DEW := "morning_dew"

const MAP_SIZE := Vector2(1600.0, 1400.0)
const DEFAULT_MARGIN := 32.0
# Region graph: physical exits and quest-gated world-map links share one source.
# A route can span multiple links; UI and teleport services should not invent edges.
const CONNECTIONS := [
    {"from": TOWN, "to": MOSS_CROWN, "type": "gate", "name": "森林入口"},
    {"from": MOSS_CROWN, "to": FALLEN_LEAF, "type": "quest", "name": "落叶幽谷道路"},
    {"from": FALLEN_LEAF, "to": MORNING_DEW, "type": "quest", "name": "朝露林地道路"}
]

# Only exits with verified in-scene coordinates are registered here.
# Quest links remain logical until their physical gate positions are authored.
const PHYSICAL_EXITS := [
    {"from": TOWN, "to": MOSS_CROWN, "position": Vector2(1460.0, 700.0), "radius": 84.0},
    {"from": MOSS_CROWN, "to": FALLEN_LEAF, "position": Vector2(900.0, 790.0), "radius": 72.0}
]

const MAPS := {
    TOWN: {"name": "王朝营地", "bounds": Rect2(Vector2.ZERO, MAP_SIZE), "spawn": Vector2(600.0, 610.0), "safe": true},
    MOSS_CROWN: {"name": "苔冠空地", "bounds": Rect2(Vector2.ZERO, MAP_SIZE), "spawn": Vector2(600.0, 620.0), "safe": false},
    FALLEN_LEAF: {"name": "落叶幽谷", "bounds": Rect2(Vector2.ZERO, MAP_SIZE), "spawn": Vector2(600.0, 650.0), "safe": false},
    MORNING_DEW: {"name": "朝露林地", "bounds": Rect2(Vector2.ZERO, MAP_SIZE), "spawn": Vector2(600.0, 650.0), "safe": false}
}

func connections_from(map_id: String) -> Array:
    var result: Array = []
    for connection in CONNECTIONS:
        if str(connection["from"]) == map_id:
            result.append(connection.duplicate(true))
        elif str(connection["to"]) == map_id:
            var reverse: Dictionary = connection.duplicate(true)
            var previous_from: String = str(reverse["from"])
            reverse["from"] = reverse["to"]
            reverse["to"] = previous_from
            result.append(reverse)
    return result

func physical_exit_at(map_id: String, position: Vector2) -> Dictionary:
    for exit in PHYSICAL_EXITS:
        if str(exit["from"]) != map_id:
            continue
        if position.distance_to(exit["position"]) <= float(exit["radius"]):
            return exit.duplicate(true)
    return {}

func has_direct_connection(from_map_id: String, to_map_id: String) -> bool:
    if not is_known_map(from_map_id) or not is_known_map(to_map_id):
        return false
    for connection in connections_from(from_map_id):
        if str(connection["to"]) == to_map_id:
            return true
    return false

func route_between(from_map_id: String, to_map_id: String) -> Array:
    if not is_known_map(from_map_id) or not is_known_map(to_map_id):
        return []
    if from_map_id == to_map_id:
        return [from_map_id]
    var frontier: Array = [[from_map_id]]
    var visited: Dictionary = {from_map_id: true}
    while not frontier.is_empty():
        var path: Array = frontier.pop_front()
        var current: String = str(path.back())
        for connection in connections_from(current):
            var next_map: String = str(connection["to"])
            if visited.has(next_map):
                continue
            var next_path: Array = path.duplicate()
            next_path.append(next_map)
            if next_map == to_map_id:
                return next_path
            visited[next_map] = true
            frontier.append(next_path)
    return []

func teleport_destinations(boss_defeated: bool, elite_defeated: bool, valley_quest_done: bool, moss_crown_quest_done: bool, campfire_unlocked: bool) -> Array:
    var destinations: Array = [
        {"id": "town", "name": "王朝营地", "map_id": TOWN, "kind": "spawn", "available": true, "hint": "返回安全区"},
        {"id": "campfire", "name": "营火据点", "map_id": MOSS_CROWN, "kind": "campfire", "available": campfire_unlocked, "hint": "已激活的营火"},
        {"id": MOSS_CROWN, "name": "苔冠空地", "map_id": MOSS_CROWN, "kind": "spawn", "available": true, "hint": "首个探索区域"},
        {"id": FALLEN_LEAF, "name": "落叶幽谷", "map_id": FALLEN_LEAF, "kind": "spawn", "available": is_unlocked(FALLEN_LEAF, boss_defeated, elite_defeated, valley_quest_done, moss_crown_quest_done), "hint": "完成苔冠区域主线后开放"},
        {"id": MORNING_DEW, "name": "朝露林地", "map_id": MORNING_DEW, "kind": "spawn", "available": is_unlocked(MORNING_DEW, boss_defeated, elite_defeated, valley_quest_done, moss_crown_quest_done), "hint": "完成落叶幽谷主线后开放"}
    ]
    return destinations

func resolve_teleport_destination(destination_id: String, boss_defeated: bool, elite_defeated: bool, valley_quest_done: bool, moss_crown_quest_done: bool, campfire_unlocked: bool, campfire_position: Vector2 = Vector2.ZERO) -> Dictionary:
    for destination in teleport_destinations(boss_defeated, elite_defeated, valley_quest_done, moss_crown_quest_done, campfire_unlocked):
        if str(destination["id"]) != destination_id:
            continue
        if not bool(destination["available"]):
            return {"ok": false, "reason": "locked"}
        if str(destination["kind"]) == "campfire" and campfire_position == Vector2.ZERO:
            return {"ok": false, "reason": "missing_campfire"}
        var position: Vector2 = campfire_position + Vector2(0.0, 96.0) if str(destination["kind"]) == "campfire" else (destination["position"] if destination["kind"] == "fixed" else spawn_position(str(destination["map_id"])))
        return {"ok": true, "map_id": str(destination["map_id"]), "position": clamp_position(position), "name": str(destination["name"])}
    return {"ok": false}

func is_known_map(map_id: String) -> bool:
    return MAPS.has(map_id)

func map_name(map_id: String) -> String:
    return str(MAPS.get(map_id, MAPS[TOWN])["name"])

func map_bounds(map_id: String) -> Rect2:
    return MAPS.get(map_id, MAPS[TOWN])["bounds"]

func spawn_position(map_id: String) -> Vector2:
    return MAPS.get(map_id, MAPS[TOWN])["spawn"]

func is_safe_map(map_id: String) -> bool:
    return bool(MAPS.get(map_id, MAPS[TOWN])["safe"])

func is_unlocked(map_id: String, boss_defeated: bool, elite_defeated: bool, valley_quest_done: bool, moss_crown_quest_done: bool = false) -> bool:
    match map_id:
        TOWN, MOSS_CROWN:
            # The starter forest is the first destination of the opening quest.
            return true
        FALLEN_LEAF:
            # The next region opens only after its preceding boss quest is complete.
            return elite_defeated and moss_crown_quest_done
        MORNING_DEW:
            # The final region follows completion of the valley's main quest.
            return elite_defeated and moss_crown_quest_done and valley_quest_done
        _:
            return false

func map_for_enemy(enemy_id: String) -> String:
    if enemy_id in ["valley_firefly", "withered_puppet", "stream_spirit", "valley_mushroom"]:
        return FALLEN_LEAF
    if enemy_id in ["dawn_deer", "hill_rock"]:
        return MORNING_DEW
    return MOSS_CROWN

func enemy_spawn_position(enemy_id: String) -> Vector2:
    match enemy_id:
        "slime": return Vector2(820.0, 470.0)
        "wolf": return Vector2(390.0, 650.0)
        "boss_tree": return Vector2(930.0, 650.0)
        "thorn_vine": return Vector2(360.0, 280.0)
        "forest_wasp": return Vector2(780.0, 260.0)
        "boss_thorn": return Vector2(930.0, 360.0)
        "valley_firefly": return Vector2(300.0, 360.0)
        "withered_puppet": return Vector2(850.0, 360.0)
        "stream_spirit": return Vector2(600.0, 230.0)
        "valley_mushroom": return Vector2(420.0, 650.0)
        "dawn_deer": return Vector2(360.0, 420.0)
        "hill_rock": return Vector2(850.0, 420.0)
        _:
            return spawn_position(map_for_enemy(enemy_id)) + Vector2(100.0, 0.0)

static func clamp_position(position: Vector2, margin: float = DEFAULT_MARGIN) -> Vector2:
    var safe_margin: float = clampf(margin, 0.0, minf(MAP_SIZE.x, MAP_SIZE.y) * 0.5)
    return Vector2(
        clampf(position.x, safe_margin, MAP_SIZE.x - safe_margin),
        clampf(position.y, safe_margin, MAP_SIZE.y - safe_margin)
    )
