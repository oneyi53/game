class_name WorldMapManager
extends RefCounted

# Independent, local coordinate spaces: every map starts at (0, 0).
# The active map is a complete play space, not a rectangle inside a
# shared mega-map. Combat entities are routed by their authored map id.

const TOWN := "town"
const MOSS_CROWN := "moss_crown"
const FALLEN_LEAF := "fallen_leaf"
const MORNING_DEW := "morning_dew"

const MAP_SIZE := Vector2(1200.0, 900.0)
const MAPS := {
    TOWN: {"name":"王朝营地", "bounds":Rect2(Vector2.ZERO, MAP_SIZE), "spawn":Vector2(600, 610), "safe":true},
    MOSS_CROWN: {"name":"苔冠空地", "bounds":Rect2(Vector2.ZERO, MAP_SIZE), "spawn":Vector2(600, 620), "safe":false},
    FALLEN_LEAF: {"name":"落叶幽谷", "bounds":Rect2(Vector2.ZERO, MAP_SIZE), "spawn":Vector2(600, 650), "safe":false},
    MORNING_DEW: {"name":"朝露林地", "bounds":Rect2(Vector2.ZERO, MAP_SIZE), "spawn":Vector2(600, 650), "safe":false}
}

const STARTER_REGION := "starter"
const NORTH_CLEARING_REGION := "north_clearing"

func is_known_map(map_id: String) -> bool:
    return MAPS.has(map_id)

func map_name(map_id: String) -> String:
    return str(MAPS.get(map_id, MAPS[TOWN]).name)

func map_bounds(map_id: String) -> Rect2:
    return MAPS.get(map_id, MAPS[TOWN]).bounds

func spawn_position(map_id: String) -> Vector2:
    return MAPS.get(map_id, MAPS[TOWN]).spawn

func is_safe_map(map_id: String) -> bool:
    return bool(MAPS.get(map_id, MAPS[TOWN]).safe)

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

func map_from_legacy_position(_position: Vector2, _boss_defeated: bool, _elite_defeated: bool, _valley_quest_done: bool) -> String:
    return MOSS_CROWN

func enemy_region(enemy_id: String) -> String:
    if enemy_id in ["thorn_vine", "forest_wasp", "boss_thorn"]:
        return NORTH_CLEARING_REGION
    return STARTER_REGION

func is_region_unlocked(region_id: String, boss_defeated: bool) -> bool:
    return region_id == STARTER_REGION or (region_id == NORTH_CLEARING_REGION and boss_defeated)

func map_for_enemy(enemy_id: String) -> String:
    if enemy_id in ["valley_firefly", "withered_puppet", "stream_spirit", "valley_mushroom"]:
        return FALLEN_LEAF
    if enemy_id in ["dawn_deer", "hill_rock"]:
        return MORNING_DEW
    return MOSS_CROWN

# Authored encounter positions in each map's own coordinate space.
# This intentionally replaces legacy mega-map coordinates.
func enemy_spawn_position(enemy_id: String) -> Vector2:
    match enemy_id:
        "slime": return Vector2(820, 470)
        "wolf": return Vector2(390, 650)
        "boss_tree": return Vector2(930, 650)
        "thorn_vine": return Vector2(360, 280)
        "forest_wasp": return Vector2(780, 260)
        "boss_thorn": return Vector2(930, 360)
        "valley_firefly": return Vector2(300, 360)
        "withered_puppet": return Vector2(850, 360)
        "stream_spirit": return Vector2(600, 230)
        "valley_mushroom": return Vector2(420, 650)
        "dawn_deer": return Vector2(360, 420)
        "hill_rock": return Vector2(850, 420)
        _:
            return spawn_position(map_for_enemy(enemy_id)) + Vector2(100, 0)

func clamp_to_map(position: Vector2, map_id: String, margin: float = 32.0) -> Vector2:
    var bounds: Rect2 = map_bounds(map_id)
    return Vector2(clampf(position.x, bounds.position.x + margin, bounds.end.x - margin), clampf(position.y, bounds.position.y + margin, bounds.end.y - margin))
