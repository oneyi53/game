extends SceneTree

const Migration = preload("res://scripts/core/world_save_migration.gd")
const WorldMaps = preload("res://scripts/core/world_map_manager.gd")
const WorldProjectionScript = preload("res://scripts/core/world_projection.gd")

func _initialize() -> void:
    _test_legacy_starter_region()
    _test_legacy_fallen_leaf_region()
    _test_fallen_leaf_requires_elite_boss()
    _test_locked_region_falls_back_safely()
    _test_morning_dew_requires_both_gates()
    _test_legacy_position_outside_regions()
    _test_existing_map_local_save_is_preserved()
    _test_locked_new_format_map_falls_back_without_rescaling()
    _test_missing_position_uses_spawn()
    _test_map_local_clamp_contract()
    _test_map_unlock_gates()
    _test_enemy_map_assignment()
    _test_projection_bounds_and_depth()
    print("World coordinate tests: 13 passed")
    quit()



func _test_map_local_clamp_contract() -> void:
    var clamped: Vector2 = WorldMaps.clamp_position(Vector2(-200.0, 1400.0))
    assert(is_equal_approx(clamped.x, 32.0))
    assert(is_equal_approx(clamped.y, 868.0))
    var maps = WorldMaps.new()
    for map_id in [WorldMaps.TOWN, WorldMaps.MOSS_CROWN, WorldMaps.FALLEN_LEAF, WorldMaps.MORNING_DEW]:
        var spawn: Vector2 = maps.spawn_position(map_id)
        assert(spawn.x >= 32.0 and spawn.x <= 1168.0)
        assert(spawn.y >= 32.0 and spawn.y <= 868.0)


func _test_map_unlock_gates() -> void:
    var maps = WorldMaps.new()
    assert(maps.is_unlocked(WorldMaps.TOWN, false, false, false))
    assert(maps.is_unlocked(WorldMaps.MOSS_CROWN, false, false, false))
    assert(not maps.is_unlocked(WorldMaps.FALLEN_LEAF, false, false, false))
    assert(maps.is_unlocked(WorldMaps.FALLEN_LEAF, true, false, false))
    assert(not maps.is_unlocked(WorldMaps.MORNING_DEW, true, true, false))
    assert(maps.is_unlocked(WorldMaps.MORNING_DEW, true, true, true))


func _test_enemy_map_assignment() -> void:
    var maps = WorldMaps.new()
    assert(maps.map_for_enemy("slime") == WorldMaps.MOSS_CROWN)
    assert(maps.map_for_enemy("valley_firefly") == WorldMaps.FALLEN_LEAF)
    assert(maps.map_for_enemy("dawn_deer") == WorldMaps.MORNING_DEW)


func _test_projection_bounds_and_depth() -> void:
    var bounds: Rect2 = WorldProjectionScript.projected_bounds()
    assert(is_equal_approx(bounds.position.x, 0.0))
    assert(is_equal_approx(bounds.position.y, 0.0))
    assert(is_equal_approx(bounds.size.x, 1050.0))
    assert(is_equal_approx(bounds.size.y, 525.0))
    assert(WorldProjectionScript.screen_depth(Vector2(500.0, 500.0)) > WorldProjectionScript.screen_depth(Vector2(200.0, 200.0)))


func _test_legacy_starter_region() -> void:
    var input := {"player_position": {"x": 800.0, "y": 180.0}}
    var result: Dictionary = Migration.migrate_save(input)
    assert(result["migrated"] == true)
    assert(result["map_id"] == Migration.MOSS_CROWN)
    var pos: Dictionary = result["data"]["player_position"]
    assert(is_equal_approx(float(pos["x"]), 600.0))
    assert(is_equal_approx(float(pos["y"]), 450.0))


func _test_legacy_fallen_leaf_region() -> void:
    var input := {
        "player_position": {"x": 400.0, "y": 1020.0},
        "boss_defeated": true,
        "elite_defeated": true
    }
    var result: Dictionary = Migration.migrate_save(input)
    assert(result["map_id"] == Migration.FALLEN_LEAF)
    var pos: Dictionary = result["data"]["player_position"]
    assert(is_equal_approx(float(pos["x"]), 600.0))
    assert(is_equal_approx(float(pos["y"]), 450.0))


func _test_locked_region_falls_back_safely() -> void:
    var input := {
        "player_position": {"x": 1200.0, "y": 1020.0},
        "boss_defeated": false,
        "elite_defeated": false
    }
    var result: Dictionary = Migration.migrate_save(input)
    assert(result["map_id"] == Migration.MOSS_CROWN)
    var pos: Dictionary = result["data"]["player_position"]
    assert(float(pos["x"]) >= Migration.MARGIN)
    assert(float(pos["x"]) <= Migration.MAP_SIZE.x - Migration.MARGIN)
    assert(float(pos["y"]) >= Migration.MARGIN)
    assert(float(pos["y"]) <= Migration.MAP_SIZE.y - Migration.MARGIN)




func _test_fallen_leaf_requires_elite_boss() -> void:
    var input := {
        "player_position": {"x": 400.0, "y": 1020.0},
        "boss_defeated": true,
        "elite_defeated": false
    }
    var result: Dictionary = Migration.migrate_save(input)
    assert(result["map_id"] == Migration.MOSS_CROWN)


func _test_morning_dew_requires_both_gates() -> void:
    var input := {
        "player_position": {"x": 1200.0, "y": 1020.0},
        "boss_defeated": true,
        "elite_defeated": true,
        "quests": {"completed": {"side_valley_puppet": true}}
    }
    var result: Dictionary = Migration.migrate_save(input)
    assert(result["map_id"] == Migration.MORNING_DEW)
    var pos: Dictionary = result["data"]["player_position"]
    assert(is_equal_approx(float(pos["x"]), 600.0))
    assert(is_equal_approx(float(pos["y"]), 450.0))


func _test_legacy_position_outside_regions() -> void:
    var input := {"player_position": {"x": 800.0, "y": 600.0}}
    var result: Dictionary = Migration.migrate_save(input)
    assert(result["map_id"] == Migration.MOSS_CROWN)
    var pos: Dictionary = result["data"]["player_position"]
    assert(is_equal_approx(float(pos["x"]), 600.0))
    assert(is_equal_approx(float(pos["y"]), 450.0))


func _test_existing_map_local_save_is_preserved() -> void:
    var input := {
        "map_id": Migration.FALLEN_LEAF,
        "player_position": {"x": 420.0, "y": 500.0},
        "boss_defeated": true
    }
    var result: Dictionary = Migration.migrate_save(input)
    assert(result["migrated"] == false)
    assert(result["map_id"] == Migration.FALLEN_LEAF)
    var pos: Dictionary = result["data"]["player_position"]
    assert(is_equal_approx(float(pos["x"]), 420.0))
    assert(is_equal_approx(float(pos["y"]), 500.0))



func _test_locked_new_format_map_falls_back_without_rescaling() -> void:
    var input := {
        "map_id": Migration.MORNING_DEW,
        "player_position": {"x": 420.0, "y": 500.0},
        "elite_defeated": false
    }
    var result: Dictionary = Migration.migrate_save(input)
    assert(result["migrated"] == true)
    assert(result["map_id"] == Migration.MOSS_CROWN)
    var pos: Dictionary = result["data"]["player_position"]
    assert(is_equal_approx(float(pos["x"]), 420.0))
    assert(is_equal_approx(float(pos["y"]), 500.0))


func _test_missing_position_uses_spawn() -> void:
    var input := {"boss_defeated": false}
    var result: Dictionary = Migration.migrate_save(input)
    assert(result["map_id"] == Migration.MOSS_CROWN)
    var pos: Dictionary = result["data"]["player_position"]
    assert(is_equal_approx(float(pos["x"]), 600.0))
    assert(is_equal_approx(float(pos["y"]), 620.0))
