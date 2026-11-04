class_name WorldMapManager
extends RefCounted

# Each area is a self-contained logical world. Gameplay coordinates are
# always map-local (0..1200, 0..900); projection is a render-only concern.

const TOWN := "town"
const MOSS_CROWN := "moss_crown"
const FALLEN_LEAF := "fallen_leaf"
const MORNING_DEW := "morning_dew"

const MAP_SIZE := Vector2(1200.0, 900.0)
const DEFAULT_MARGIN := 32.0
const MAPS := {
    TOWN: {"name": "王朝营地", "bounds": Rect2(Vector2.ZERO, MAP_SIZE), "spawn": Vector2(600.0, 610.0), "safe": true},
    MOSS_CROWN: {"name": "苔冠空地", "bounds": Rect2(Vector2.ZERO, MAP_SIZE), "spawn": Vector2(600.0, 620.0), "safe": false},
    FALLEN_LEAF: {"name": "落叶幽谷", "bounds": Rect2(Vector2.ZERO, MAP_SIZE), "spawn": Vector2(600.0, 650.0), "safe": false},
    MORNING_DEW: {"name": "朝露林地", "bounds": Rect2(Vector2.ZERO, MAP_SIZE), "spawn": Vector2(600.0, 650.0), "safe": false}
}

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

func is_unlocked(map_id: String, boss_defeated: bool, elite_defeated: bool, valley_quest_done: bool) -> bool:
    match map_id:
        TOWN, MOSS_CROWN:
            return true
        FALLEN_LEAF:
            return boss_defeated
        MORNING_DEW:
            return elite_defeated and valley_quest_done
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
