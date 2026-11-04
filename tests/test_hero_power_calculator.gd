extends SceneTree

const Calculator = preload("res://scripts/progression/hero_power_calculator.gd")

func _initialize() -> void:
    _test_level_equipment_camp_and_loose_stats()
    _test_power_uses_final_combat_stats()
    _test_power_never_negative()
    print("Hero power calculator tests: 3 passed")
    quit()

func _test_level_equipment_camp_and_loose_stats() -> void:
    var hero_data: Dictionary = {
        "attack": 20,
        "hp": 100,
        "defense": 5,
        "move_speed": 200,
        "attack_range": 100
    }
    var equipment: Dictionary = {
        "attack_pct": 10,
        "hp_pct": 20,
        "defense_pct": 20,
        "crit_pct": 15,
        "crit_damage_pct": 30,
        "attack_speed_pct": 10
    }
    var loose: Dictionary = {"attack": 3, "hp": 4, "defense": 2}
    var stats: Dictionary = Calculator.final_stats(hero_data, 2, 5.0, 5.0, equipment, 5.0, 8.0, loose)
    assert(int(stats["attack"]) == 27)
    assert(int(stats["max_hp"]) == 140)
    assert(int(stats["defense"]) == 8)
    assert(is_equal_approx(float(stats["crit_chance"]), 0.15))
    assert(int(stats["crit_damage_pct"]) == 30)
    assert(int(stats["attack_speed_pct"]) == 10)

func _test_power_uses_final_combat_stats() -> void:
    var stats: Dictionary = {
        "attack": 27,
        "max_hp": 140,
        "defense": 8,
        "crit_chance": 0.15,
        "crit_damage_pct": 30,
        "attack_speed_pct": 10,
        "move_speed": 200,
        "attack_range": 100
    }
    assert(Calculator.power_from_stats(stats) == 745)

func _test_power_never_negative() -> void:
    assert(Calculator.power_from_stats({}) == 0)
    assert(Calculator.power_from_stats({"attack": -100, "max_hp": -100}) == 0)
