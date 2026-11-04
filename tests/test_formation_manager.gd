extends SceneTree

const Formation = preload("res://scripts/core/formation_manager.gd")

func _initialize() -> void:
    _test_initial_roster_is_bounded()
    _test_saved_formation_round_trip()
    _test_legacy_roster_migration()
    _test_unknown_and_duplicate_ids_are_ignored()
    _test_captain_is_mandatory_and_first()
    _test_add_requires_owned_hero_and_free_slot()
    _test_remove_cannot_remove_captain()
    _test_swap_cannot_move_captain()
    _test_available_roster()
    _test_invalid_saved_shape_fails()
    print("Hero formation tests: 10 passed")
    quit()

func _test_initial_roster_is_bounded() -> void:
    var manager = Formation.new()
    assert(manager.configure(["captain", "archer", "guardian", "mage", "healer", "assassin"]))
    assert(manager.active_ids == ["captain", "archer", "guardian", "mage"])
    assert(manager.max_party_size == 4)
    assert(manager.validate())

func _test_saved_formation_round_trip() -> void:
    var manager = Formation.new()
    assert(manager.configure(["captain", "archer", "guardian", "mage"], {"active_ids": ["captain", "mage", "archer"]}))
    assert(manager.active_ids == ["captain", "mage", "archer"])
    var restored = Formation.new()
    assert(restored.configure(["captain", "archer", "guardian", "mage"], manager.save_data()))
    assert(restored.active_ids == manager.active_ids)

func _test_legacy_roster_migration() -> void:
    var manager = Formation.new()
    assert(manager.configure(["captain", "archer", "guardian", "mage", "healer"], null, ["captain", "archer", "guardian", "mage", "healer"]))
    assert(manager.active_ids == ["captain", "archer", "guardian", "mage"])

func _test_unknown_and_duplicate_ids_are_ignored() -> void:
    var manager = Formation.new()
    assert(manager.configure(["captain", "archer", "mage"], {"active_ids": ["captain", "archer", "archer", "missing", "mage"]}))
    assert(manager.active_ids == ["captain", "archer", "mage"])

func _test_captain_is_mandatory_and_first() -> void:
    var manager = Formation.new()
    assert(manager.configure(["archer", "captain", "mage"], {"active_ids": ["mage", "archer"]}))
    assert(manager.active_ids[0] == "captain")
    assert(manager.active_ids.size() == 3)
    var invalid = Formation.new()
    assert(not invalid.configure(["archer", "mage"]))

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

func _test_remove_cannot_remove_captain() -> void:
    var manager = Formation.new()
    assert(manager.configure(["captain", "archer"], {"active_ids": ["captain", "archer"]}))
    assert(not manager.remove_from_party("captain"))
    assert(manager.remove_from_party("archer"))
    assert(not manager.remove_from_party("archer"))
    assert(manager.validate())

func _test_swap_cannot_move_captain() -> void:
    var manager = Formation.new()
    assert(manager.configure(["captain", "archer", "guardian"], {"active_ids": ["captain", "archer", "guardian"]}))
    assert(not manager.swap_slots(0, 1))
    assert(manager.swap_slots(1, 2))
    assert(manager.active_ids == ["captain", "guardian", "archer"])
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
