extends SceneTree

const DailyActivityManagerScript = preload("res://scripts/progression/daily_activity_manager.gd")

var granted_rewards: Array = []

func _initialize() -> void:
    _test_initial_state_and_snapshot()
    _test_invalid_definitions_are_rejected()
    _test_matching_event_updates_only_matching_tasks()
    _test_one_event_can_advance_multiple_tasks()
    _test_completion_awards_points_once()
    _test_progress_is_capped_at_target()
    _test_duplicate_occurrence_is_ignored()
    _test_state_round_trip_preserves_progress_and_deduplication()
    _test_restore_clamps_progress_and_ignores_unknown_ids()
    _test_same_day_does_not_reset()
    _test_day_rollover_resets_daily_state()
    _test_clock_rollback_is_rejected()
    _test_stage_claim_requires_unlock_and_successful_grant()
    _test_snapshot_is_detached_from_internal_state()
    print("Daily activity manager tests: 14 passed")
    quit()

func _task_definitions() -> Array:
    return [
        {"id": "slime_hunt", "name": "史莱姆清理", "event_type": "enemy_killed", "target_count": 2, "points": 10, "filters": {"enemy_id": "slime"}},
        {"id": "boss_hunt", "name": "首领挑战", "event_type": "enemy_killed", "target_count": 1, "points": 20, "filters": {"is_boss": true}},
        {"id": "all_kills", "name": "战斗练习", "event_type": "enemy_killed", "target_count": 3, "points": 5, "filters": {}},
        {"id": "chest_open", "name": "宝箱探索", "event_type": "chest_opened", "target_count": 1, "points": 5, "filters": {}}
    ]

func _stage_definitions() -> Array:
    return [
        {"id": "stage_10", "name": "初阶补给", "threshold": 10, "reward_id": "reward_small"},
        {"id": "stage_20", "name": "进阶补给", "threshold": 20, "reward_id": "reward_large"}
    ]

func _new_manager(saved_state: Variant = null, day: String = "2026-11-04") -> DailyActivityManager:
    var manager = DailyActivityManagerScript.new()
    assert(manager.initialize(_task_definitions(), _stage_definitions(), day, saved_state), manager.error_message)
    return manager

func _test_initial_state_and_snapshot() -> void:
    var manager = _new_manager()
    var snapshot: Dictionary = manager.get_snapshot()
    assert(snapshot["day_key"] == "2026-11-04")
    assert(snapshot["activity_points"] == 0)
    assert(snapshot["tasks"].size() == 4)
    assert(snapshot["stages"]["stage_10"]["status"] == "locked")
    assert(snapshot["tasks"]["slime_hunt"]["progress"] == 0)

func _test_invalid_definitions_are_rejected() -> void:
    var manager = DailyActivityManagerScript.new()
    assert(not manager.initialize([{"id": "bad", "event_type": "kill", "target_count": 0, "points": 1}], [], "2026-11-04"))
    assert(manager.error_message != "")
    assert(not manager.initialize([], [{"id": "bad", "threshold": 10}], "2026-11-04"))
    assert(not manager.initialize([], [], "04-11-2026"))

func _test_matching_event_updates_only_matching_tasks() -> void:
    var manager = _new_manager()
    var result: Dictionary = manager.record_event("enemy_killed", "kill-001", {"enemy_id": "wolf", "is_boss": false})
    assert(result["accepted"])
    assert(manager.get_snapshot()["tasks"]["slime_hunt"]["progress"] == 0)
    assert(manager.get_snapshot()["tasks"]["all_kills"]["progress"] == 1)
    assert(manager.get_snapshot()["tasks"]["boss_hunt"]["progress"] == 0)

func _test_one_event_can_advance_multiple_tasks() -> void:
    var manager = _new_manager()
    manager.record_event("enemy_killed", "kill-002", {"enemy_id": "slime", "is_boss": false})
    var snapshot: Dictionary = manager.get_snapshot()
    assert(snapshot["tasks"]["slime_hunt"]["progress"] == 1)
    assert(snapshot["tasks"]["all_kills"]["progress"] == 1)

func _test_completion_awards_points_once() -> void:
    var manager = _new_manager()
    manager.record_event("enemy_killed", "kill-003", {"enemy_id": "slime"})
    var result: Dictionary = manager.record_event("enemy_killed", "kill-004", {"enemy_id": "slime"})
    assert(result["completed_task_ids"].has("slime_hunt"))
    assert(result["points_added"] == 10)
    assert(manager.get_activity_points() == 10)
    manager.record_event("enemy_killed", "kill-005", {"enemy_id": "slime"})
    assert(manager.get_activity_points() == 15)

func _test_progress_is_capped_at_target() -> void:
    var manager = _new_manager()
    manager.record_event("enemy_killed", "kill-006", {"enemy_id": "slime"}, 20)
    assert(manager.get_snapshot()["tasks"]["slime_hunt"]["progress"] == 2)
    assert(manager.get_activity_points() == 10)

func _test_duplicate_occurrence_is_ignored() -> void:
    var manager = _new_manager()
    var first: Dictionary = manager.record_event("enemy_killed", "stable-kill-1", {"enemy_id": "slime"})
    var second: Dictionary = manager.record_event("enemy_killed", "stable-kill-1", {"enemy_id": "slime"})
    assert(first["accepted"])
    assert(second["duplicate"])
    assert(not second["changed"])
    assert(manager.get_snapshot()["tasks"]["slime_hunt"]["progress"] == 1)

func _test_state_round_trip_preserves_progress_and_deduplication() -> void:
    var manager = _new_manager()
    manager.record_event("enemy_killed", "persisted-kill-1", {"enemy_id": "slime"})
    var saved: Dictionary = manager.save_state()
    var restored = _new_manager(saved)
    assert(restored.save_state() == saved)
    var duplicate: Dictionary = restored.record_event("enemy_killed", "persisted-kill-1", {"enemy_id": "slime"})
    assert(duplicate["duplicate"])
    assert(restored.get_snapshot()["tasks"]["slime_hunt"]["progress"] == 1)

func _test_restore_clamps_progress_and_ignores_unknown_ids() -> void:
    var manager = _new_manager({
        "day_key": "2026-11-04",
        "task_progress": {"slime_hunt": 999, "all_kills": -4, "removed_task": 99},
        "claimed_stages": ["stage_10", "removed_stage"],
        "processed_occurrences": ["old-event"]
    })
    var snapshot: Dictionary = manager.get_snapshot()
    assert(snapshot["tasks"]["slime_hunt"]["progress"] == 2)
    assert(snapshot["tasks"]["slime_hunt"]["completed"])
    assert(snapshot["tasks"]["all_kills"]["progress"] == 0)
    assert(snapshot["stages"]["stage_10"]["claimed"])
    assert(not snapshot["stages"].has("removed_stage"))
    assert(manager.save_state()["processed_occurrences"].has("old-event"))

func _test_same_day_does_not_reset() -> void:
    var manager = _new_manager()
    manager.record_event("enemy_killed", "same-day-kill", {"enemy_id": "slime"})
    assert(manager.advance_day("2026-11-04"))
    assert(manager.get_snapshot()["tasks"]["slime_hunt"]["progress"] == 1)

func _test_day_rollover_resets_daily_state() -> void:
    var manager = _new_manager()
    manager.record_event("enemy_killed", "before-rollover", {"enemy_id": "slime"})
    manager.claim_stage("stage_10", Callable(self, "_grant_reward"))
    assert(manager.advance_day("2026-11-05"))
    var snapshot: Dictionary = manager.get_snapshot()
    assert(snapshot["day_key"] == "2026-11-05")
    assert(snapshot["activity_points"] == 0)
    assert(snapshot["tasks"]["slime_hunt"]["progress"] == 0)
    assert(not snapshot["stages"]["stage_10"]["claimed"])
    assert(not manager.save_state()["processed_occurrences"].has("before-rollover"))

func _test_clock_rollback_is_rejected() -> void:
    var manager = _new_manager()
    manager.record_event("enemy_killed", "rollback-protected", {"enemy_id": "slime"})
    assert(not manager.advance_day("2026-11-03"))
    assert(manager.get_snapshot()["day_key"] == "2026-11-04")
    assert(manager.get_snapshot()["tasks"]["slime_hunt"]["progress"] == 1)

func _test_stage_claim_requires_unlock_and_successful_grant() -> void:
    var manager = _new_manager()
    var locked: Dictionary = manager.claim_stage("stage_10", Callable(self, "_grant_reward"))
    assert(not locked["ok"] and locked["reason"] == "locked")
    manager.record_event("enemy_killed", "claim-kill-1", {"enemy_id": "slime"}, 2)
    var failed: Dictionary = manager.claim_stage("stage_10", Callable(self, "_reject_reward"))
    assert(not failed["ok"] and failed["reason"] == "reward_failed")
    assert(not manager.get_snapshot()["stages"]["stage_10"]["claimed"])
    var claimed: Dictionary = manager.claim_stage("stage_10", Callable(self, "_grant_reward"))
    assert(claimed["ok"])
    var duplicate: Dictionary = manager.claim_stage("stage_10", Callable(self, "_grant_reward"))
    assert(not duplicate["ok"] and duplicate["reason"] == "already_claimed")
    assert(granted_rewards.size() == 1)

func _grant_reward(reward_id: String) -> bool:
    granted_rewards.append(reward_id)
    return true

func _reject_reward(_reward_id: String) -> bool:
    return false

func _test_snapshot_is_detached_from_internal_state() -> void:
    var manager = _new_manager()
    var snapshot: Dictionary = manager.get_snapshot()
    var task_copy: Dictionary = snapshot["tasks"]["slime_hunt"]
    task_copy["progress"] = 99
    assert(manager.get_snapshot()["tasks"]["slime_hunt"]["progress"] == 0)
