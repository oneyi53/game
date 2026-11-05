extends SceneTree

const RedDotServiceScript = preload("res://scripts/core/red_dot_service.gd")

var passed := 0

func _initialize() -> void:
	_test_empty_state_is_hidden()
	_test_source_state_updates()
	_test_parent_aggregates_child_state()
	_test_nested_parent_aggregation()
	_test_parent_can_have_direct_source()
	_test_independent_targets_do_not_leak()
	_test_invalid_hierarchy_is_rejected_atomically()
	_test_cycles_are_rejected()
	_test_source_replacement_is_atomic()
	_test_snapshot_contains_all_known_targets()
	print("Red dot service tests: %d passed" % passed)
	quit()

func _new_service():
	return RedDotServiceScript.new()

func _test_empty_state_is_hidden() -> void:
	var service = _new_service()
	assert(not service.is_visible("hud.daily"))
	assert(service.get_snapshot().is_empty())
	passed += 1

func _test_source_state_updates() -> void:
	var service = _new_service()
	assert(service.set_source_state("daily.reward", true))
	assert(service.is_visible("daily.reward"))
	assert(service.set_source_state("daily.reward", false))
	assert(not service.is_visible("daily.reward"))
	assert(service.clear_source_state("daily.reward"))
	assert(not service.clear_source_state("daily.reward"))
	passed += 1

func _test_parent_aggregates_child_state() -> void:
	var service = _new_service()
	assert(service.set_hierarchy({"hud": ["daily", "recruit"], "town": ["recruit"]}))
	assert(service.set_source_state("daily", true))
	assert(service.is_visible("hud"))
	assert(not service.is_visible("town"))
	assert(service.set_source_state("recruit", true))
	assert(service.is_visible("town"))
	assert(service.set_source_state("daily", false))
	assert(service.is_visible("hud"))
	assert(service.set_source_state("recruit", false))
	assert(not service.is_visible("hud"))
	assert(not service.is_visible("town"))
	passed += 1

func _test_nested_parent_aggregation() -> void:
	var service = _new_service()
	assert(service.set_hierarchy({
		"root": ["hud", "town"],
		"hud": ["daily", "quest"],
		"town": ["recruit", "backpack"]
	}))
	assert(service.set_source_state("backpack", true))
	assert(service.is_visible("town"))
	assert(service.is_visible("root"))
	assert(not service.is_visible("hud"))
	passed += 1

func _test_parent_can_have_direct_source() -> void:
	var service = _new_service()
	assert(service.set_hierarchy({"hud": ["daily"]}))
	assert(service.set_source_state("hud", true))
	assert(service.is_visible("hud"))
	assert(service.set_source_state("hud", false))
	assert(not service.is_visible("hud"))
	passed += 1

func _test_independent_targets_do_not_leak() -> void:
	var service = _new_service()
	assert(service.set_hierarchy({"town": ["recruit", "backpack"]}))
	assert(service.set_source_state("recruit", true))
	assert(service.is_visible("town"))
	assert(not service.is_visible("backpack"))
	assert(not service.is_visible("hud"))
	passed += 1

func _test_invalid_hierarchy_is_rejected_atomically() -> void:
	var service = _new_service()
	assert(service.set_hierarchy({"hud": ["daily"]}))
	assert(not service.set_hierarchy({"hud": ["daily", "daily"]}))
	assert(service.is_visible("hud") == false)
	assert(not service.set_hierarchy({"": ["daily"]}))
	assert(not service.set_hierarchy({"hud": "daily"}))
	assert(service.get_snapshot().has("daily"))
	passed += 1

func _test_cycles_are_rejected() -> void:
	var service = _new_service()
	assert(not service.set_hierarchy({"a": ["b"], "b": ["a"]}))
	assert(not service.set_hierarchy({"a": ["b"], "b": ["c"], "c": ["a"]}))
	assert(service.get_snapshot().is_empty())
	passed += 1

func _test_source_replacement_is_atomic() -> void:
	var service = _new_service()
	assert(service.set_source_state("daily", true))
	assert(not service.replace_source_states({"daily": false, "quest": "yes"}))
	assert(service.is_visible("daily"))
	assert(not service.is_visible("quest"))
	assert(service.replace_source_states({"daily": false, "quest": true}))
	assert(not service.is_visible("daily"))
	assert(service.is_visible("quest"))
	passed += 1

func _test_snapshot_contains_all_known_targets() -> void:
	var service = _new_service()
	assert(service.set_hierarchy({"hud": ["daily"], "town": ["recruit"]}))
	assert(service.set_source_state("daily", true))
	var snapshot: Dictionary = service.get_snapshot()
	assert(snapshot["hud"])
	assert(snapshot["daily"])
	assert(not snapshot["town"])
	assert(not snapshot["recruit"])
	snapshot["hud"] = false
	assert(service.is_visible("hud"))
	passed += 1
