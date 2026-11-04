extends SceneTree

const Registry = preload("res://scripts/core/town_building_registry.gd")
const Projection = preload("res://scripts/core/world_projection.gd")

func _initialize() -> void:
    _test_all_existing_panels_have_one_building()
    _test_building_positions_are_inside_town_projection()
    _test_hit_testing_uses_projected_positions()
    _test_unknown_building_is_ignored()
    print("Town building entrance tests: 4 passed")
    quit()

func _test_all_existing_panels_have_one_building() -> void:
    var expected := {
        "recruit": "recruit",
        "camp": "camp",
        "equipment": "equipment",
        "backpack": "backpack"
    }
    assert(Registry.entries().size() == expected.size())
    for building_id in expected:
        assert(Registry.panel_for(building_id) == expected[building_id])

func _test_building_positions_are_inside_town_projection() -> void:
    var bounds: Rect2 = Projection.projected_bounds()
    for item in Registry.entries():
        var point: Vector2 = Registry.projected_position(str(item["id"]))
        assert(bounds.has_point(point))
        assert(str(item["title"]) != "")

func _test_hit_testing_uses_projected_positions() -> void:
    for item in Registry.entries():
        var building_id: String = str(item["id"])
        var center: Vector2 = Registry.projected_position(building_id)
        assert(Registry.hit_test(center) == building_id)
        assert(Registry.hit_test(center + Vector2(20.0, 0.0)) == building_id)

func _test_unknown_building_is_ignored() -> void:
    assert(Registry.panel_for("not_a_building") == "")
    assert(Registry.hit_test(Vector2(-10000.0, -10000.0)) == "")
