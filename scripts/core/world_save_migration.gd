class_name WorldSaveMigration
extends RefCounted

# Converts saves from the original shared 1600x1200 world into the
# map-local 1200x900 coordinate spaces used by the 2.5D world.
# This helper is deliberately pure: it never reads or writes files.
# Callers must persist its returned state only after a successful load.

const MAP_SIZE := Vector2(1200.0, 900.0)
const MARGIN := 32.0

const TOWN := "town"
const MOSS_CROWN := "moss_crown"
const FALLEN_LEAF := "fallen_leaf"
const MORNING_DEW := "morning_dew"

const MAP_IDS := [TOWN, MOSS_CROWN, FALLEN_LEAF, MORNING_DEW]
const SPAWNS := {
    TOWN: Vector2(600.0, 610.0),
    MOSS_CROWN: Vector2(600.0, 620.0),
    FALLEN_LEAF: Vector2(600.0, 650.0),
    MORNING_DEW: Vector2(600.0, 650.0)
}

# Regions drawn by the original MapDrawer on its shared 1600x1200 map.
# These are the authored legacy play areas, not new-map pixel coordinates.
const LEGACY_REGIONS := {
    MOSS_CROWN: Rect2(200.0, 40.0, 1200.0, 280.0),
    FALLEN_LEAF: Rect2(40.0, 880.0, 720.0, 280.0),
    MORNING_DEW: Rect2(840.0, 880.0, 720.0, 280.0)
}

static func migrate_save(save_data: Dictionary) -> Dictionary:
    var result: Dictionary = save_data.duplicate(true)
    var unlocked: Dictionary = _unlocked_maps(save_data)

    if save_data.has("map_id"):
        var saved_map_id: String = str(save_data.get("map_id", ""))
        if MAP_IDS.has(saved_map_id) and bool(unlocked.get(saved_map_id, false)):
            var saved_position: Vector2 = _read_position(save_data.get("player_position"))
            if save_data.get("player_position") is Dictionary:
                saved_position = clamp_to_map(saved_position)
            else:
                saved_position = SPAWNS[saved_map_id]
            result["map_id"] = saved_map_id
            result["player_position"] = _position_to_data(saved_position)
            return {"data": result, "migrated": false, "map_id": saved_map_id}

    var legacy_position: Vector2 = _read_position(save_data.get("player_position"))
    var target_map: String = _map_from_legacy_position(legacy_position, unlocked)
    var target_position: Vector2
    if save_data.get("player_position") is Dictionary:
        target_position = _convert_legacy_position(legacy_position, target_map)
    else:
        target_position = SPAWNS[target_map]

    result["map_id"] = target_map
    result["player_position"] = _position_to_data(target_position)
    return {"data": result, "migrated": true, "map_id": target_map}


static func _unlocked_maps(save_data: Dictionary) -> Dictionary:
    var boss_defeated: bool = bool(save_data.get("boss_defeated", false))
    var elite_defeated: bool = bool(save_data.get("elite_defeated", false))
    var quests: Dictionary = save_data.get("quests", {}) if save_data.get("quests", {}) is Dictionary else {}
    var completed_quests: Dictionary = quests.get("completed", {}) if quests.get("completed", {}) is Dictionary else {}
    var valley_quest_done: bool = bool(completed_quests.get("side_valley_puppet", false))
    return {
        TOWN: true,
        MOSS_CROWN: true,
        FALLEN_LEAF: boss_defeated,
        MORNING_DEW: elite_defeated and valley_quest_done
    }


static func _map_from_legacy_position(position: Vector2, unlocked: Dictionary) -> String:
    if LEGACY_REGIONS[MOSS_CROWN].has_point(position):
        return MOSS_CROWN
    if LEGACY_REGIONS[FALLEN_LEAF].has_point(position) and bool(unlocked.get(FALLEN_LEAF, false)):
        return FALLEN_LEAF
    if LEGACY_REGIONS[MORNING_DEW].has_point(position) and bool(unlocked.get(MORNING_DEW, false)):
        return MORNING_DEW
    # The original game had one shared forest map and no town scene.
    # Unmapped/locked legacy locations therefore remain in the starter
    # forest rather than silently moving a player into a locked region.
    return MOSS_CROWN


static func _convert_legacy_position(position: Vector2, target_map: String) -> Vector2:
    var source_region: Rect2
    if target_map == MOSS_CROWN and LEGACY_REGIONS[MOSS_CROWN].has_point(position):
        source_region = LEGACY_REGIONS[MOSS_CROWN]
    elif target_map == FALLEN_LEAF and LEGACY_REGIONS[FALLEN_LEAF].has_point(position):
        source_region = LEGACY_REGIONS[FALLEN_LEAF]
    elif target_map == MORNING_DEW and LEGACY_REGIONS[MORNING_DEW].has_point(position):
        source_region = LEGACY_REGIONS[MORNING_DEW]
    else:
        # Preserve approximate relative position for old saves that were
        # outside a named region (for example the original (800, 600) start).
        source_region = Rect2(0.0, 0.0, 1600.0, 1200.0)
    var normalized: Vector2 = (position - source_region.position) / source_region.size
    return clamp_to_map(Vector2(normalized.x * MAP_SIZE.x, normalized.y * MAP_SIZE.y))


static func clamp_to_map(position: Vector2) -> Vector2:
    return Vector2(
        clampf(position.x, MARGIN, MAP_SIZE.x - MARGIN),
        clampf(position.y, MARGIN, MAP_SIZE.y - MARGIN)
    )


static func _read_position(value: Variant) -> Vector2:
    if value is Dictionary:
        return Vector2(float(value.get("x", 800.0)), float(value.get("y", 600.0)))
    return Vector2(800.0, 600.0)


static func _position_to_data(position: Vector2) -> Dictionary:
    return {"x": position.x, "y": position.y}
