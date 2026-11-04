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
    print("Quest manager tests: 10 passed")
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
    assert(manager.quests.size() == 9)
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
