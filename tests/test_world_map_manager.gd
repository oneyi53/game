extends SceneTree

const WorldMapManagerScript = preload("res://scripts/core/world_map_manager.gd")

func _initialize() -> void:
    var manager = WorldMapManagerScript.new()
    assert(manager.is_known_map(WorldMapManagerScript.TOWN))
    assert(manager.is_known_map(WorldMapManagerScript.MOSS_CROWN))
    assert(manager.is_known_map(WorldMapManagerScript.FALLEN_LEAF))
    assert(manager.is_known_map(WorldMapManagerScript.MORNING_DEW))
    assert(not manager.is_known_map("unknown_region"))
    assert(manager.map_for_enemy("valley_firefly") == WorldMapManagerScript.FALLEN_LEAF)
    assert(manager.map_for_enemy("dawn_deer") == WorldMapManagerScript.MORNING_DEW)
    assert(manager.map_for_enemy("slime") == WorldMapManagerScript.MOSS_CROWN)
    assert(manager.is_unlocked(WorldMapManagerScript.TOWN, false, false, false, false))
    assert(manager.is_unlocked(WorldMapManagerScript.MOSS_CROWN, false, false, false, false))
    assert(not manager.is_unlocked(WorldMapManagerScript.FALLEN_LEAF, false, false, false, false))
    assert(manager.is_unlocked(WorldMapManagerScript.FALLEN_LEAF, false, true, false, true))
    assert(not manager.is_unlocked(WorldMapManagerScript.MORNING_DEW, false, true, false, true))
    assert(manager.is_unlocked(WorldMapManagerScript.MORNING_DEW, false, true, true, true))
    assert(WorldMapManagerScript.clamp_position(Vector2(-100.0, 2000.0)) == Vector2(32.0, 1368.0))
    assert(manager.map_bounds(WorldMapManagerScript.MOSS_CROWN).size == WorldMapManagerScript.MAP_SIZE)
    print("World map manager tests: 16 passed")
    quit()
