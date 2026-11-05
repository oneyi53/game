extends SceneTree

const Fog = preload("res://scripts/core/exploration_fog.gd")
const WorldMaps = preload("res://scripts/core/world_map_manager.gd")

func _initialize() -> void:
    _test_empty_region_is_zero()
    _test_default_grid_dimensions()
    _test_duplicate_cells_count_once()
    _test_invalid_and_out_of_bounds_cells_are_ignored()
    _test_partial_edge_cells_are_counted_once()
    _test_custom_map_dimensions()
    _test_invalid_dimensions_are_not_applicable()
    _test_town_exploration_is_not_applicable()
    print("Exploration fog tests: 8 passed")
    quit()

func _test_empty_region_is_zero() -> void:
    var stats: Dictionary = Fog.calculate_exploration_stats([])
    assert(stats["applicable"] == true)
    assert(stats["explored_cells"] == 0)
    assert(stats["total_cells"] == 360)
    assert(stats["percent"] == 0)

func _test_default_grid_dimensions() -> void:
    var stats: Dictionary = Fog.calculate_exploration_stats([])
    assert(stats["total_cells"] == 20 * 18)

func _test_duplicate_cells_count_once() -> void:
    var stats: Dictionary = Fog.calculate_exploration_stats(["0:0", "0:0", "1:0", "1:0"])
    assert(stats["explored_cells"] == 2)
    assert(is_equal_approx(float(stats["ratio"]), 2.0 / 360.0))

func _test_invalid_and_out_of_bounds_cells_are_ignored() -> void:
    var stats: Dictionary = Fog.calculate_exploration_stats([
        "bad", "1", "1:2:3", "-1:0", "0:-1", "20:0", "0:18", "01:1", "1:01", "1.0:1", "1:1"
    ])
    assert(stats["explored_cells"] == 1)

func _test_partial_edge_cells_are_counted_once() -> void:
    var stats: Dictionary = Fog.calculate_exploration_stats(["19:17", "19:17", "19:16"])
    assert(stats["explored_cells"] == 2)
    assert(stats["total_cells"] == 360)

func _test_custom_map_dimensions() -> void:
    var stats: Dictionary = Fog.calculate_exploration_stats(["0:0", "1:0", "0:1"], Vector2(160.0, 80.0), 80.0)
    assert(stats["total_cells"] == 2)
    assert(stats["explored_cells"] == 2)
    assert(stats["percent"] == 100)

func _test_invalid_dimensions_are_not_applicable() -> void:
    var zero_width: Dictionary = Fog.calculate_exploration_stats([], Vector2.ZERO, 80.0)
    var zero_cell: Dictionary = Fog.calculate_exploration_stats([], Vector2(160.0, 160.0), 0.0)
    assert(zero_width["applicable"] == false)
    assert(zero_cell["applicable"] == false)

func _test_town_exploration_is_not_applicable() -> void:
    var fog: ExplorationFog = Fog.new()
    fog.set_map_state(WorldMaps.TOWN, [])
    var stats: Dictionary = fog.get_exploration_stats()
    assert(stats["applicable"] == false)
    assert(stats["percent"] == 0)
    fog.free()
