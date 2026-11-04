extends SceneTree

const Formation = preload("res://scripts/core/formation_manager.gd")

func _initialize() -> void:
    _test_initial_roster_is_bounded()
    _test_saved_formation_round_trip()
    _test_legacy_roster_migration()
    _test_unknown_and_duplicate_ids_are_ignored()
    _test_any_owned_hero_can_lead()
    _test_reserve_hero_can_replace_leader_at_capacity()
    _test_add_requires_owned_hero_and_free_slot()
    _test_remove_leader_promotes_next_member()
    _test_party_cannot_become_empty()
    _test_swap_can_change_leader()
    _test_available_roster()
    _test_invalid_saved_shape_fails()
    _test_empty_owned_roster_fails()
    print("Hero formation tests: 13 passed")
    quit()

func _test_initial_roster_is_bounded() -> void:
    var manager = Formation.new()
    assert(manager.configure(["captain", "archer", "guardian", "mage", "healer", "assassin"]))
    assert(manager.active_ids == ["captain", "archer", "guardian", "mage"])
    assert(manager.max_party_size == 4)
    assert(manager.validate())

func _test_saved_formation_round_trip() -> void:
    var manager = Formation.new()
    assert(manager.configure(["captain", "archer", "guardian", "mage"], {"active_ids": ["mage", "captain", "archer"]}))
    assert(manager.active_ids == ["mage", "captain", "archer"])
    var restored = Formation.new()
    assert(restored.configure(["captain", "archer", "guardian", "mage"], manager.save_data()))
    assert(restored.active_ids == manager.active_ids)

func _test_legacy_roster_migration() -> void:
    var manager = Formation.new()
    assert(manager.configure(["captain", "archer", "guardian", "mage", "healer"], null, ["mage", "captain", "archer", "guardian", "healer"]))
    assert(manager.active_ids == ["mage", "captain", "archer", "guardian"])

func _test_unknown_and_duplicate_ids_are_ignored() -> void:
    var manager = Formation.new()
    assert(manager.configure(["captain", "archer", "mage"], {"active_ids": ["mage", "archer", "archer", "missing"]}))
    assert(manager.active_ids == ["mage", "archer"])

func _test_any_owned_hero_can_lead() -> void:
    var manager = Formation.new()
    assert(manager.configure(["captain", "archer", "mage"], {"active_ids": ["captain", "archer"]}))
    assert(manager.set_leader("archer"))
    assert(manager.active_ids == ["archer", "captain"])
    assert(manager.is_leader("archer"))
    assert(not manager.is_leader("captain"))
    assert(not manager.set_leader("not_owned"))
    assert(manager.validate())

func _test_reserve_hero_can_replace_leader_at_capacity() -> void:
    var manager = Formation.new()
    assert(manager.configure(["captain", "archer", "mage", "healer"], {"active_ids": ["captain", "archer", "mage"]}, [], 3))
    assert(manager.set_leader("healer"))
    assert(manager.active_ids == ["healer", "archer", "mage"])
    assert(manager.available_ids() == ["captain"])
    assert(manager.validate())

func _test_add_requires_owned_hero_and_free_slot() -> void:
    var manager = Formation.new()
    assert(manager.configure(["captain", "archer", "guardian", "mage", "healer"], {"active_ids": ["captain"]}))
    assert(manager.add_to_party("archer"))
    assert(not manager.add_to_party("archer"))
    assert(not manager.add_to_party("not_owned"))
    assert(manager.add_to_party("guardian"))
    assert(manager.add_to_party("mage"))
    assert(not manager.add_to_party("healer"))
    assert(manager.validate())

func _test_remove_leader_promotes_next_member() -> void:
    var manager = Formation.new()
    assert(manager.configure(["captain", "archer", "mage"], {"active_ids": ["archer", "captain", "mage"]}))
    assert(manager.remove_from_party("archer"))
    assert(manager.active_ids == ["captain", "mage"])
    assert(manager.is_leader("captain"))
    assert(manager.validate())

func _test_party_cannot_become_empty() -> void:
    var manager = Formation.new()
    assert(manager.configure(["captain"], {"active_ids": ["captain"]}))
    assert(not manager.remove_from_party("captain"))
    assert(manager.active_ids == ["captain"])

func _test_swap_can_change_leader() -> void:
    var manager = Formation.new()
    assert(manager.configure(["captain", "archer", "guardian"], {"active_ids": ["captain", "archer", "guardian"]}))
    assert(manager.swap_slots(0, 1))
    assert(manager.active_ids == ["archer", "captain", "guardian"])
    assert(manager.is_leader("archer"))
    assert(not manager.swap_slots(-1, 1))
    assert(not manager.swap_slots(1, 8))

func _test_available_roster() -> void:
    var manager = Formation.new()
    assert(manager.configure(["captain", "archer", "guardian"], {"active_ids": ["captain", "archer"]}))
    assert(manager.available_ids() == ["guardian"])
    assert(manager.is_active("archer"))
    assert(not manager.is_active("guardian"))

func _test_invalid_saved_shape_fails() -> void:
    var manager = Formation.new()
    assert(not manager.configure(["captain", "archer"], {"active_ids": "captain"}))

func _test_empty_owned_roster_fails() -> void:
    var manager = Formation.new()
    assert(not manager.configure([]))
