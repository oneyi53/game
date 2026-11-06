extends SceneTree

const CampManagerScript = preload("res://scripts/progression/camp_manager.gd")

func _initialize() -> void:
    _test_real_tables_and_build_state()
    _test_building_cost_types_are_strict()
    _test_failed_reload_preserves_previous_snapshot()
    _test_campfire_cost_and_position_are_validated()
    _test_campfires_are_partitioned_by_world_map()
    print("Camp manager tests: 5 passed")
    quit()

func _write_temp(name: String, value) -> String:
    var path := "user://" + name
    var file := FileAccess.open(path, FileAccess.WRITE)
    assert(file != null, "cannot create temporary config: " + path)
    file.store_string(JSON.stringify(value))
    file.close()
    return path

func _camp_entry(cost = 10, default_built = false) -> Dictionary:
    return {
        "id": "hero_management",
        "name": "英雄管理",
        "cost_wood": cost,
        "intro": "查看英雄",
        "built_message": "建成",
        "default_built": default_built
    }

func _campfires() -> Array:
    return [{
        "id": "fire_a",
        "area": "forest",
        "target_area": "forest",
        "cost_wood": 5,
        "position": {"x": 10, "y": 20},
        "intro": "营火",
        "fog_prompt": "迷雾",
        "insufficient_prompt": "木材不足",
        "dispel_prompt": "驱散",
        "teleport_intro": "传送"
    }]

func _test_real_tables_and_build_state() -> void:
    var manager = CampManagerScript.new()
    assert(manager.load_all(), manager.error_message)
    assert(manager.is_built("hero_management"))
    assert(not manager.is_built("blacksmith"))
    assert(manager.build("blacksmith"))
    assert(not manager.build("blacksmith"), "duplicate construction must fail")
    var saved := manager.save_camp()
    var restored = CampManagerScript.new()
    assert(restored.load_all(), restored.error_message)
    restored.load_camp(saved)
    assert(restored.is_built("blacksmith"))
    # Production map anchors must be explicitly assigned to their own regions.
    assert(manager.campfire_map_id("campfire_moss_crown") == "moss_crown")
    assert(manager.campfire_map_id("campfire_fallen_leaf") == "fallen_leaf")
    assert(manager.campfire_map_id("campfire_morning_dew") == "morning_dew")
    assert(manager.campfires_for_map("moss_crown").size() == 1)
    assert(manager.campfires_for_map("fallen_leaf").size() == 1)
    assert(manager.campfires_for_map("morning_dew").size() == 1)
    assert(manager.campfires_for_map("future_area_1").size() == 1, "legacy future framework campfire must remain isolated")

func _assert_bad_building_cost(cost, label: String) -> void:
    var camp_path := _write_temp("camp_manager_bad_camp.json", {"buildings": [_camp_entry(cost, true)]})
    var fire_path := _write_temp("camp_manager_valid_fires.json", _campfires())
    var manager = CampManagerScript.new()
    assert(not manager.load_all(camp_path, fire_path), label + " should be rejected")
    assert(manager.buildings.is_empty(), label + " must not publish partial building data")
    _remove_temp(camp_path)
    _remove_temp(fire_path)

func _test_building_cost_types_are_strict() -> void:
    _assert_bad_building_cost(true, "boolean cost")
    _assert_bad_building_cost("10", "string cost")
    _assert_bad_building_cost(1.5, "fractional cost")

func _test_failed_reload_preserves_previous_snapshot() -> void:
    var manager = CampManagerScript.new()
    assert(manager.load_all(), manager.error_message)
    var before := manager.save_camp()
    var before_ids: Array = manager.building_order.duplicate()
    var bad_camp := _write_temp("camp_manager_invalid_reload.json", {"buildings": [_camp_entry(1.25, true)]})
    var valid_fires := _write_temp("camp_manager_reload_fires.json", _campfires())
    assert(not manager.load_all(bad_camp, valid_fires))
    assert(manager.save_camp() == before, "failed reload changed saved state")
    assert(manager.building_order == before_ids, "failed reload changed building registry")
    _remove_temp(bad_camp)
    _remove_temp(valid_fires)

func _test_campfire_cost_and_position_are_validated() -> void:
    var invalid_cost := _campfires()
    invalid_cost[0]["cost_wood"] = false
    var camp_path := _write_temp("camp_manager_valid_camp.json", {"buildings": [_camp_entry(0, true)]})
    var fire_path := _write_temp("camp_manager_invalid_fire_cost.json", invalid_cost)
    var manager = CampManagerScript.new()
    assert(not manager.load_all(camp_path, fire_path), "boolean campfire cost should fail")
    assert(manager.campfires.is_empty())
    _remove_temp(fire_path)

    var invalid_position := _campfires()
    invalid_position[0]["position"]["x"] = "10"
    fire_path = _write_temp("camp_manager_invalid_fire_position.json", invalid_position)
    assert(not manager.load_all(camp_path, fire_path), "string campfire coordinate should fail")
    assert(manager.campfires.is_empty())
    _remove_temp(camp_path)
    _remove_temp(fire_path)

func _remove_temp(path: String) -> void:
    DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

func _test_campfires_are_partitioned_by_world_map() -> void:
    var entries := _campfires()
    entries[0]["target_area"] = "future_area_1"
    entries[0]["map_id"] = "moss_crown"
    var camp_path := _write_temp("camp_manager_map_camp.json", {"buildings": [_camp_entry(0, true)]})
    var fire_path := _write_temp("camp_manager_map_fires.json", entries)
    var manager = CampManagerScript.new()
    assert(manager.load_all(camp_path, fire_path), manager.error_message)
    assert(manager.campfire_map_id("fire_a") == "moss_crown")
    assert(manager.campfires_for_map("moss_crown").size() == 1)
    assert(manager.campfires_for_map("future_area_1").is_empty())
    assert(not manager.has_unlocked_campfire_on_map("moss_crown"))
    assert(manager.unlock_campfire("fire_a"))
    assert(manager.has_unlocked_campfire_on_map("moss_crown"))
    assert(manager.unlocked_campfires_for_map("moss_crown").size() == 1)
    _remove_temp(camp_path)
    _remove_temp(fire_path)
