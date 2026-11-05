extends SceneTree

const QuestManagerScript = preload("res://scripts/progression/quest_manager.gd")

var completion_events: Array = []

func _initialize() -> void:
    _test_real_quest_table_is_valid()
    _test_old_save_without_quest_progress_defaults_to_zero()
    _test_progress_load_clamps_negative_counts_and_ignores_unknown_ids()
    _test_progress_serialization_round_trip()
    _test_kill_progress_requires_matching_enemy()
    _test_kill_threshold_emits_reward_once()
    _test_boss_objective_requires_matching_boss_id()
    _test_chest_objective_completes_at_configured_count()
    _test_completed_quest_ignores_later_progress()
    _test_saved_completed_quest_does_not_emit_again()
    _test_reload_preserves_progress()
    _test_config_validation_and_dependency_cycles()
    _test_harvest_explore_and_delivery_events()
    print("Quest manager tests: 13 passed")
    quit()

func _new_manager() -> QuestManager:
    completion_events.clear()
    var manager = QuestManagerScript.new()
    assert(manager.load_quests(), manager.error_message)
    manager.quest_completed.connect(_on_quest_completed)
    return manager

func _on_quest_completed(quest_id, quest_name, complete_line, reward_gold) -> void:
    completion_events.append({"id": str(quest_id), "name": str(quest_name), "line": str(complete_line), "reward_gold": int(reward_gold)})

func _test_real_quest_table_is_valid() -> void:
    var manager = _new_manager()
    assert(manager.quests.size() == 10)
    assert(manager.counts.size() == manager.quests.size())
    assert(manager.completed.size() == manager.quests.size())
    for quest in manager.quests:
        var quest_id: String = str(quest["id"])
        assert(manager.counts.has(quest_id))
        assert(manager.completed.has(quest_id))

func _test_old_save_without_quest_progress_defaults_to_zero() -> void:
    var manager = _new_manager()
    manager.load_progress({})
    manager.load_progress(null)
    for quest_id in manager.counts:
        assert(int(manager.counts[quest_id]) == 0)
        assert(not manager.is_completed(str(quest_id)))

func _test_progress_load_clamps_negative_counts_and_ignores_unknown_ids() -> void:
    var manager = _new_manager()
    manager.load_progress({"counts": {"side_slime_trouble": -4, "removed_quest": 99}, "completed": {"side_wolf_threat": true, "removed_quest": true}})
    assert(int(manager.counts["side_slime_trouble"]) == 0)
    assert(not manager.is_completed("side_slime_trouble"))
    assert(manager.is_completed("side_wolf_threat"))
    assert(not manager.counts.has("removed_quest"))
    assert(not manager.completed.has("removed_quest"))

func _test_progress_serialization_round_trip() -> void:
    var manager = _new_manager()
    manager.on_enemy_killed("slime", false)
    manager.on_enemy_killed("wolf", false)
    manager.on_chest_opened()
    var saved_progress: Dictionary = manager.save_progress()
    assert(saved_progress.keys().size() == 2)
    assert(saved_progress["counts"]["side_slime_trouble"] == 1)
    assert(saved_progress["counts"]["side_wolf_threat"] == 1)
    assert(saved_progress["counts"]["side_lost_chest"] == 1)
    var restored = _new_manager()
    restored.load_progress(saved_progress)
    assert(restored.save_progress() == saved_progress)
    assert(completion_events.is_empty())

func _test_kill_progress_requires_matching_enemy() -> void:
    var manager = _new_manager()
    manager.on_enemy_killed("wolf", false)
    assert(int(manager.counts["side_wolf_threat"]) == 1)
    assert(int(manager.counts["side_slime_trouble"]) == 0)
    assert(completion_events.is_empty())

func _test_kill_threshold_emits_reward_once() -> void:
    var manager = _new_manager()
    for _i in range(8):
        manager.on_enemy_killed("slime", false)
    assert(manager.is_completed("side_slime_trouble"))
    assert(int(manager.counts["side_slime_trouble"]) == 8)
    assert(completion_events.size() == 1)
    assert(completion_events[0]["id"] == "side_slime_trouble")
    assert(completion_events[0]["reward_gold"] == 20)
    assert(completion_events[0]["name"] == "潮湿地带的麻烦")
    assert(completion_events[0]["line"] == "「太棒了！这片潮湿地带终于清爽多了！」")

func _test_boss_objective_requires_matching_boss_id() -> void:
    var manager = _new_manager()
    manager.on_enemy_killed("boss_thorn", true)
    assert(not manager.is_completed("main_forest_secret"))
    assert(manager.is_completed("side_moss_crown_king"))
    assert(completion_events.size() == 1)
    assert(completion_events[0]["id"] == "side_moss_crown_king")
    assert(completion_events[0]["reward_gold"] == 20)
    var main_quest_manager = _new_manager()
    main_quest_manager.on_enemy_killed("boss_tree", false)
    assert(not main_quest_manager.is_completed("main_forest_secret"))
    assert(completion_events.is_empty())
    main_quest_manager.on_enemy_killed("boss_tree", true)
    assert(main_quest_manager.is_completed("main_forest_secret"))
    assert(completion_events.size() == 1)
    assert(completion_events[0]["id"] == "main_forest_secret")
    assert(completion_events[0]["reward_gold"] == 0)

func _test_chest_objective_completes_at_configured_count() -> void:
    var manager = _new_manager()
    manager.on_chest_opened()
    assert(manager.is_completed("side_lost_chest"))
    assert(int(manager.counts["side_lost_chest"]) == 1)
    assert(completion_events.size() == 1)
    assert(completion_events[0]["id"] == "side_lost_chest")
    assert(completion_events[0]["reward_gold"] == 20)

func _test_completed_quest_ignores_later_progress() -> void:
    var manager = _new_manager()
    for _i in range(8):
        manager.on_enemy_killed("slime", false)
    manager.on_enemy_killed("slime", false)
    manager.on_chest_opened()
    assert(int(manager.counts["side_slime_trouble"]) == 8)
    assert(completion_events.size() == 2)
    assert(completion_events[0]["id"] == "side_slime_trouble")
    assert(completion_events[1]["id"] == "side_lost_chest")

func _test_saved_completed_quest_does_not_emit_again() -> void:
    var manager = _new_manager()
    manager.load_progress({"counts": {"side_slime_trouble": 8}, "completed": {"side_slime_trouble": true}})
    manager.on_enemy_killed("slime", false)
    assert(manager.is_completed("side_slime_trouble"))
    assert(int(manager.counts["side_slime_trouble"]) == 8)
    assert(completion_events.is_empty())
    assert(manager.save_progress()["completed"]["side_slime_trouble"])

func _write_temp_quests(data: Array) -> String:
    var path := "user://quest_manager_regression_tmp.json"
    var file = FileAccess.open(path, FileAccess.WRITE)
    assert(file != null, "cannot create test-owned temp config")
    file.store_string(JSON.stringify(data))
    file.close()
    return path

func _minimal_quest(quest_id: String) -> Dictionary:
    return {
        "id": quest_id,
        "name": quest_id,
        "type": "side",
        "objective_type": "kill",
        "target_id": "slime",
        "count": 1,
        "reward_gold": 0
    }

func _assert_invalid_config(data: Array, label: String) -> void:
    var manager = _new_manager()
    var before_quests: Array = manager.quests.duplicate(true)
    var before_counts: Dictionary = manager.counts.duplicate(true)
    var before_completed: Dictionary = manager.completed.duplicate(true)
    var path := _write_temp_quests(data)
    assert(not manager.load_quests(path), label + " should be rejected")
    assert(manager.quests == before_quests, label + " changed quests on failure")
    assert(manager.counts == before_counts, label + " changed counts on failure")
    assert(manager.completed == before_completed, label + " changed completed on failure")
    DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

func _test_reload_preserves_progress() -> void:
    var manager = _new_manager()
    manager.on_enemy_killed("slime", false)
    var before: Dictionary = manager.save_progress()
    assert(manager.load_quests(), manager.error_message)
    assert(manager.save_progress() == before, "load_quests must preserve progress for retained IDs")

func _test_config_validation_and_dependency_cycles() -> void:
    var q := _minimal_quest("q")
    var invalid := q.duplicate(true)
    invalid.erase("reward_gold")
    _assert_invalid_config([invalid], "missing reward_gold")
    invalid = q.duplicate(true)
    invalid.erase("name")
    _assert_invalid_config([invalid], "missing name")
    invalid = q.duplicate(true)
    invalid["name"] = 42
    _assert_invalid_config([invalid], "non-string name")
    invalid = q.duplicate(true)
    invalid["name"] = "   "
    _assert_invalid_config([invalid], "blank name")
    invalid = q.duplicate(true)
    invalid["type"] = false
    _assert_invalid_config([invalid], "non-string quest type")
    invalid = q.duplicate(true)
    invalid["objective_type"] = 3
    _assert_invalid_config([invalid], "non-string objective type")
    invalid = q.duplicate(true)
    invalid["count"] = true
    _assert_invalid_config([invalid], "boolean count")
    invalid = q.duplicate(true)
    invalid["count"] = "5"
    _assert_invalid_config([invalid], "string count")
    invalid = q.duplicate(true)
    invalid["count"] = 1.5
    _assert_invalid_config([invalid], "fractional count")
    invalid = q.duplicate(true)
    invalid["count"] = 0
    _assert_invalid_config([invalid], "zero count")
    invalid = q.duplicate(true)
    invalid["count"] = -1
    _assert_invalid_config([invalid], "negative count")
    invalid = q.duplicate(true)
    invalid["reward_gold"] = true
    _assert_invalid_config([invalid], "boolean reward")
    invalid = q.duplicate(true)
    invalid["reward_gold"] = "5"
    _assert_invalid_config([invalid], "string reward")
    invalid = q.duplicate(true)
    invalid["reward_gold"] = 1.5
    _assert_invalid_config([invalid], "fractional reward")
    invalid = q.duplicate(true)
    invalid["reward_gold"] = -1
    _assert_invalid_config([invalid], "negative reward")
    invalid = q.duplicate(true)
    invalid["id"] = ""
    _assert_invalid_config([invalid], "empty ID")
    _assert_invalid_config([q.duplicate(true), q.duplicate(true)], "duplicate ID")
    invalid = q.duplicate(true)
    invalid["prerequisite"] = "missing"
    _assert_invalid_config([invalid], "missing prerequisite")
    invalid = q.duplicate(true)
    invalid["prerequisite"] = "q"
    _assert_invalid_config([invalid], "self cycle")
    var a := _minimal_quest("a")
    var b := _minimal_quest("b")
    a["prerequisite"] = "b"
    b["prerequisite"] = "a"
    _assert_invalid_config([a, b], "multi-node cycle")

    var first := _minimal_quest("first")
    var second := _minimal_quest("second")
    second["prerequisite"] = "first"
    var valid_path := _write_temp_quests([first, second])
    var manager = QuestManagerScript.new()
    assert(manager.load_quests(valid_path), manager.error_message)
    manager.on_enemy_killed("slime", false)
    assert(manager.is_completed("first"))
    assert(manager.is_completed("second"), "dependent quest should unlock after prerequisite")
    DirAccess.remove_absolute(ProjectSettings.globalize_path(valid_path))

func _test_harvest_explore_and_delivery_events() -> void:
    var harvest := _minimal_quest("harvest_q")
    harvest["objective_type"] = "harvest"
    harvest["target_id"] = "wood_node"
    var explore := _minimal_quest("explore_q")
    explore["objective_type"] = "explore"
    explore["target_id"] = "region_b"
    var deliver := _minimal_quest("deliver_q")
    deliver["objective_type"] = "deliver"
    deliver["target_id"] = "npc_a"
    deliver["item_id"] = "herb"
    var path := _write_temp_quests([harvest, explore, deliver])
    var manager = QuestManagerScript.new()
    assert(manager.load_quests(path), manager.error_message)
    manager.on_resource_harvested("wrong_node")
    manager.on_region_entered("wrong_region")
    manager.on_item_delivered("wrong_npc", "herb")
    manager.on_item_delivered("npc_a", "wrong_item")
    assert(int(manager.counts["harvest_q"]) == 0)
    assert(int(manager.counts["explore_q"]) == 0)
    assert(int(manager.counts["deliver_q"]) == 0)
    manager.on_resource_harvested("wood_node")
    manager.on_region_entered("region_b")
    manager.on_item_delivered("npc_a", "herb")
    assert(manager.is_completed("harvest_q"))
    assert(manager.is_completed("explore_q"))
    assert(manager.is_completed("deliver_q"))
    DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
