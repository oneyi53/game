extends SceneTree

const Migration = preload("res://scripts/core/world_save_migration.gd")
const WorldMaps = preload("res://scripts/core/world_map_manager.gd")
const WorldProjectionScript = preload("res://scripts/core/world_projection.gd")
const MainScene = preload("res://scenes/main.tscn")

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
    _test_camera_limits_match_projected_bounds()
    _test_new_game_starts_in_town()
    _test_project_orientation_is_portrait()
    _test_portrait_projection_fills_viewport()
    _test_portrait_depth_order()
    _test_screen_controls_match_portrait_projection()
    print("World coordinate tests: 19 passed")
    quit()



func _test_map_local_clamp_contract() -> void:
    var clamped: Vector2 = WorldMaps.clamp_position(Vector2(-200.0, 1400.0))
    assert(is_equal_approx(clamped.x, 32.0))
    assert(is_equal_approx(clamped.y, 1368.0))
    var maps = WorldMaps.new()
    for map_id in [WorldMaps.TOWN, WorldMaps.MOSS_CROWN, WorldMaps.FALLEN_LEAF, WorldMaps.MORNING_DEW]:
        var spawn: Vector2 = maps.spawn_position(map_id)
        assert(spawn.x >= 32.0 and spawn.x <= 1568.0)
        assert(spawn.y >= 32.0 and spawn.y <= 1368.0)


func _test_map_unlock_gates() -> void:
    var maps = WorldMaps.new()
    assert(maps.is_unlocked(WorldMaps.TOWN, false, false, false))
    assert(maps.is_unlocked(WorldMaps.MOSS_CROWN, false, false, false))
    assert(not maps.is_unlocked(WorldMaps.FALLEN_LEAF, false, true, false, false))
    assert(not maps.is_unlocked(WorldMaps.FALLEN_LEAF, true, true, false, false))
    assert(maps.is_unlocked(WorldMaps.FALLEN_LEAF, false, true, false, true))
    assert(not maps.is_unlocked(WorldMaps.MORNING_DEW, true, true, false, true))
    assert(not maps.is_unlocked(WorldMaps.MORNING_DEW, true, true, true, false))
    assert(maps.is_unlocked(WorldMaps.MORNING_DEW, true, true, true, true))


func _test_enemy_map_assignment() -> void:
    var maps = WorldMaps.new()
    assert(maps.map_for_enemy("slime") == WorldMaps.MOSS_CROWN)
    assert(maps.map_for_enemy("valley_firefly") == WorldMaps.FALLEN_LEAF)
    assert(maps.map_for_enemy("dawn_deer") == WorldMaps.MORNING_DEW)


func _test_projection_bounds_and_depth() -> void:
    var bounds: Rect2 = WorldProjectionScript.projected_bounds()
    assert(is_equal_approx(bounds.position.x, 0.0))
    assert(is_equal_approx(bounds.position.y, 0.0))
    assert(is_equal_approx(bounds.size.x, 1200.0))
    assert(is_equal_approx(bounds.size.y, 2400.0))
    assert(WorldProjectionScript.screen_depth(Vector2(500.0, 200.0)) > WorldProjectionScript.screen_depth(Vector2(200.0, 500.0)))


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
    var locked_input := {
        "player_position": {"x": 1200.0, "y": 1020.0},
        "boss_defeated": true,
        "elite_defeated": true,
        "quests": {"completed": {"side_moss_crown_king": true, "side_valley_puppet": false}}
    }
    assert(Migration.migrate_save(locked_input)["map_id"] == Migration.MOSS_CROWN)
    var input := {
        "player_position": {"x": 1200.0, "y": 1020.0},
        "boss_defeated": true,
        "elite_defeated": true,
        "quests": {"completed": {"side_moss_crown_king": true, "side_valley_puppet": true}}
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
        "boss_defeated": true,
        "elite_defeated": true
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
    assert(result["map_id"] == Migration.TOWN)
    var pos: Dictionary = result["data"]["player_position"]
    assert(is_equal_approx(float(pos["x"]), 600.0))
    assert(is_equal_approx(float(pos["y"]), 610.0))



func _test_new_game_starts_in_town() -> void:
    var result: Dictionary = Migration.migrate_save({"player_position": null})
    assert(result["map_id"] == Migration.TOWN)
    var pos: Dictionary = result["data"]["player_position"]
    assert(is_equal_approx(float(pos["x"]), 600.0))
    assert(is_equal_approx(float(pos["y"]), 610.0))


func _test_project_orientation_is_portrait() -> void:
    assert(int(ProjectSettings.get_setting("display/window/handheld/orientation", -1)) == 1)



func _test_portrait_projection_fills_viewport() -> void:
    var bounds: Rect2 = WorldProjectionScript.projected_bounds()
    assert(bounds.size.x >= 720.0)
    assert(bounds.size.y >= 1280.0)
    var spawn_screen: Vector2 = WorldProjectionScript.world_to_screen(Vector2(600.0, 610.0))
    assert(spawn_screen.x > 0.0 and spawn_screen.x < bounds.size.x)
    assert(spawn_screen.y > 0.0 and spawn_screen.y < bounds.size.y)


func _test_portrait_depth_order() -> void:
    var upper := WorldProjectionScript.screen_depth(Vector2(300.0, 800.0))
    var lower := WorldProjectionScript.screen_depth(Vector2(800.0, 300.0))
    assert(lower > upper)

func _test_screen_controls_match_portrait_projection() -> void:
    var right: Vector2 = WorldProjectionScript.screen_to_world_direction(Vector2.RIGHT)
    var down: Vector2 = WorldProjectionScript.screen_to_world_direction(Vector2.DOWN)
    var up: Vector2 = WorldProjectionScript.screen_to_world_direction(Vector2.UP)
    var right_delta: Vector2 = WorldProjectionScript.world_to_screen(right) - WorldProjectionScript.world_to_screen(Vector2.ZERO)
    var down_delta: Vector2 = WorldProjectionScript.world_to_screen(down) - WorldProjectionScript.world_to_screen(Vector2.ZERO)
    var up_delta: Vector2 = WorldProjectionScript.world_to_screen(up) - WorldProjectionScript.world_to_screen(Vector2.ZERO)
    assert(right_delta.x > 0.0 and is_zero_approx(right_delta.y))
    assert(down_delta.y > 0.0 and is_zero_approx(down_delta.x))
    assert(up_delta.y < 0.0 and is_zero_approx(up_delta.x))


func _test_camera_limits_match_projected_bounds() -> void:
    var instance = MainScene.instantiate()
    var camera: Camera2D = instance.get_node("Camera")
    var bounds: Rect2 = WorldProjectionScript.projected_bounds()
    assert(camera.limit_right == int(bounds.end.x))
    assert(camera.limit_bottom == int(bounds.end.y))
    instance.free()
