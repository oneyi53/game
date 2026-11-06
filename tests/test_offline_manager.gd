extends SceneTree

const Offline = preload("res://scripts/progression/offline_manager.gd")

func _initialize() -> void:
    _test_missing_timestamp()
    _test_invalid_timestamp()
    _test_invalid_current_time()
    _test_clock_rollback()
    _test_below_threshold()
    _test_normal_settlement()
    _test_cap_and_wood_limit()
    print("Offline manager tests: 7 passed")
    quit()

func _manager() -> Offline:
    var manager = Offline.new()
    manager.gold_per_hour = 8
    manager.wood_per_hour = 4
    manager.cap_hours = 12
    manager.min_minutes = 10
    return manager

func _test_missing_timestamp() -> void:
    var result = _manager().settle(2000, null, 0, 200)
    assert(not result.eligible)
    assert(result.reason == "no_timestamp")
    assert(result.gold == 0 and result.wood == 0)

func _test_invalid_timestamp() -> void:
    var result = _manager().settle(2000, "not-a-time", 0, 200)
    assert(not result.eligible)
    assert(result.reason == "no_timestamp")
    result = _manager().settle(2000, -1, 0, 200)
    assert(result.reason == "invalid_timestamp")

func _test_invalid_current_time() -> void:
    var result = _manager().settle(0, 1000, 0, 200)
    assert(not result.eligible)
    assert(result.reason == "invalid_now")

func _test_clock_rollback() -> void:
    var result = _manager().settle(999, 1000, 0, 200)
    assert(not result.eligible)
    assert(result.reason == "clock_rollback")
    assert(result.gold == 0 and result.wood == 0)

func _test_below_threshold() -> void:
    var result = _manager().settle(1599, 1000, 0, 200)
    assert(not result.eligible)
    assert(result.reason == "below_threshold")
    assert(result.elapsed_seconds == 599)

func _test_normal_settlement() -> void:
    var result = _manager().settle(4600, 1000, 0, 200)
    assert(result.eligible)
    assert(result.reason == "ok")
    assert(result.billed_seconds == 3600)
    assert(result.gold == 8)
    assert(result.wood == 4)

func _test_cap_and_wood_limit() -> void:
    var result = _manager().settle(1000 + 24 * 3600, 1000, 198, 200)
    assert(result.eligible)
    assert(result.reason == "capped")
    assert(result.billed_seconds == 12 * 3600)
    assert(result.gold == 96)
    assert(result.wood == 2)
