class_name WorldMapManager
extends RefCounted

# Owns world-map identity and unlock rules. Existing combat, quest and
# reward systems remain authoritative; this class only routes the player
# between the safe town and the three progression regions.
# Progression order follows the original campaign: Moss Crown is the
# starting field, Fallen Leaf follows the main boss, Morning Dew follows
# the elite boss and valley quest.

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
            return true
        FALLEN_LEAF:
            return boss_defeated
        MORNING_DEW:
            return elite_defeated and valley_quest_done
        _:
            return false

# Legacy saves contain only a position in the old combined world. That
# coordinate cannot safely identify the active logical map: old boss and
# monster spawn points overlap the newer map rectangles. Until a caller
# performs an explicit, validated migration, preserve the campaign's
# earliest field as the safe fallback rather than guessing a later map.
func map_from_legacy_position(_position: Vector2, _boss_defeated: bool, _elite_defeated: bool, _valley_quest_done: bool) -> String:
    return MOSS_CROWN

func clamp_to_map(position: Vector2, map_id: String, margin: float = 24.0) -> Vector2:
    var bounds: Rect2 = map_bounds(map_id)
    return Vector2(
        clampf(position.x, bounds.position.x + margin, bounds.end.x - margin),
        clampf(position.y, bounds.position.y + margin, bounds.end.y - margin)
    )
