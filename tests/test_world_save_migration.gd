extends SceneTree

const Migration = preload("res://scripts/core/world_save_migration.gd")

func _initialize() -> void:
    _test_legacy_starter_region()
    _test_legacy_fallen_leaf_region()
    _test_locked_region_falls_back_safely()
    _test_morning_dew_requires_both_gates()
    _test_legacy_position_outside_regions()
    _test_existing_map_local_save_is_preserved()
    _test_missing_position_uses_spawn()
    print("World save migration tests: 7 passed")
    quit()


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
        "boss_defeated": true
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


func _test_missing_position_uses_spawn() -> void:
    var input := {"boss_defeated": false}
    var result: Dictionary = Migration.migrate_save(input)
    assert(result["map_id"] == Migration.MOSS_CROWN)
    var pos: Dictionary = result["data"]["player_position"]
    assert(is_equal_approx(float(pos["x"]), 600.0))
    assert(is_equal_approx(float(pos["y"]), 620.0))
