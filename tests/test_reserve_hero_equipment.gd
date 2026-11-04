extends SceneTree

const EquipmentManagerScript = preload("res://scripts/progression/equipment_manager.gd")

func _initialize() -> void:
    _test_reserve_hero_can_equip_set()
    _test_reserve_hero_can_equip_loose_item()
    _test_reserve_equipment_round_trip()
    _test_reserve_gear_bonus_uses_hero_id()
    print("Reserve hero equipment tests: 4 passed")
    quit()

func _make_manager():
    var manager = EquipmentManagerScript.new()
    assert(manager.load_sets())
    return manager

func _test_reserve_hero_can_equip_set() -> void:
    var manager = _make_manager()
    assert(manager.equip_set_for_hero("reserve_mage", "forest_bulwark"))
    assert(manager.equipped_set_id_for_hero("reserve_mage") == "forest_bulwark")
    assert(manager.set_counts_for_hero("reserve_mage").get("forest_bulwark", 0) == 6)

func _test_reserve_hero_can_equip_loose_item() -> void:
    var manager = _make_manager()
    var definitions: Dictionary = {"worn_iron_sword": {"stats": {"attack": 7}}}
    var result: Dictionary = manager.equip_loose_item("reserve_mage", "worn_iron_sword", definitions)
    assert(bool(result.get("ok", false)))
    assert(manager.loose_equipped_for_hero("reserve_mage").get("weapon", "") == "worn_iron_sword")

func _test_reserve_equipment_round_trip() -> void:
    var manager = _make_manager()
    assert(manager.equip_set_for_hero("reserve_mage", "starfeather_hunt"))
    var definitions: Dictionary = {"rough_cloth_armor": {"stats": {"hp": 11}}}
    assert(bool(manager.equip_loose_item("reserve_mage", "rough_cloth_armor", definitions).get("ok", false)))
    var restored = _make_manager()
    restored.load_equipped(manager.save_equipped())
    restored.load_loose_equipped(manager.save_loose_equipped(), definitions)
    assert(restored.equipped_set_id_for_hero("reserve_mage") == "starfeather_hunt")
    assert(restored.loose_equipped_for_hero("reserve_mage").get("chest", "") == "rough_cloth_armor")

func _test_reserve_gear_bonus_uses_hero_id() -> void:
    var manager = _make_manager()
    assert(manager.equip_set_for_hero("reserve_mage", "forest_bulwark"))
    var definitions: Dictionary = {"worn_iron_sword": {"stats": {"attack": 7, "hp": 3}}}
    assert(bool(manager.equip_loose_item("reserve_mage", "worn_iron_sword", definitions).get("ok", false)))
    var bonus: Dictionary = manager.loose_bonus_for_hero("reserve_mage", definitions)
    assert(int(bonus.get("attack", 0)) == 7)
    assert(int(bonus.get("hp", 0)) == 3)
