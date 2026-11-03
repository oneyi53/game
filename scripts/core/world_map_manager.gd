class_name WorldMapManager
extends RefCounted

# Owns world-map identity and unlock rules. Existing combat, quest and
# reward systems remain authoritative; this class only routes the player
# between safe town and the three existing progression regions.

const TOWN := "town"
const MOSS_CROWN := "moss_crown"
const FALLEN_LEAF := "fallen_leaf"
const MORNING_DEW := "morning_dew"

const MAPS := {
    TOWN: {
        "name": "王朝营地",
        "bounds": Rect2(0.0, 0.0, 1200.0, 900.0),
        "spawn": Vector2(600.0, 450.0),
        "safe": true
    },
    MOSS_CROWN: {
        "name": "苔冠空地",
        "bounds": Rect2(200.0, 40.0, 1200.0, 280.0),
        "spawn": Vector2(800.0, 180.0),
        "safe": false
    },
    FALLEN_LEAF: {
        "name": "落叶幽谷",
        "bounds": Rect2(40.0, 880.0, 720.0, 280.0),
        "spawn": Vector2(400.0, 1020.0),
        "safe": false
    },
    MORNING_DEW: {
        "name": "朝露林地",
        "bounds": Rect2(840.0, 880.0, 720.0, 280.0),
        "spawn": Vector2(1200.0, 1020.0),
        "safe": false
    }
}

func is_known_map(map_id: String) -> bool:
    return MAPS.has(map_id)

func map_name(map_id: String) -> String:
    return str(MAPS.get(map_id, MAPS[TOWN]).get("name", "王朝营地"))

func map_bounds(map_id: String) -> Rect2:
    return MAPS.get(map_id, MAPS[TOWN]).get("bounds", Rect2(0.0, 0.0, 1200.0, 900.0))

func spawn_position(map_id: String) -> Vector2:
    return MAPS.get(map_id, MAPS[TOWN]).get("spawn", Vector2(600.0, 450.0))

func is_safe_map(map_id: String) -> bool:
    return bool(MAPS.get(map_id, MAPS[TOWN]).get("safe", true))

func is_unlocked(map_id: String, boss_defeated: bool, elite_defeated: bool, valley_quest_done: bool) -> bool:
    match map_id:
        TOWN:
            return true
        MOSS_CROWN:
            return boss_defeated
        FALLEN_LEAF:
            return elite_defeated
        MORNING_DEW:
            return elite_defeated and valley_quest_done
        _:
            return false

# Migrate old saves without a map identifier. Coordinates in the original
# combined world are retained as a best-effort region hint; unknown or
# central coordinates start in town rather than opening a locked map.
func map_from_legacy_position(position: Vector2, boss_defeated: bool, elite_defeated: bool, valley_quest_done: bool) -> String:
    if Rect2(200.0, 40.0, 1200.0, 280.0).has_point(position) and boss_defeated:
        return MOSS_CROWN
    if Rect2(40.0, 880.0, 720.0, 280.0).has_point(position) and elite_defeated:
        return FALLEN_LEAF
    if Rect2(840.0, 880.0, 720.0, 280.0).has_point(position) and elite_defeated and valley_quest_done:
        return MORNING_DEW
    return TOWN

func clamp_to_map(position: Vector2, map_id: String, margin: float = 24.0) -> Vector2:
    var bounds: Rect2 = map_bounds(map_id)
    return Vector2(
        clampf(position.x, bounds.position.x + margin, bounds.end.x - margin),
        clampf(position.y, bounds.position.y + margin, bounds.end.y - margin)
    )
