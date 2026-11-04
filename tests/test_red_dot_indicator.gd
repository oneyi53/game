extends SceneTree

const RedDot = preload("res://scripts/ui/components/red_dot_indicator.gd")

var passed := 0

func _initialize() -> void:
    call_deferred("_run_tests")

func _run_tests() -> void:
    await process_frame
    await _test_default_hidden()
    await _test_runtime_visibility_updates()
    await _test_repeated_updates_do_not_duplicate_nodes()
    await _test_multiple_indicators_are_independent()
    await _test_parent_input_passthrough()
    await _test_attach_layout_and_size()
    print("Red dot indicator tests: %d passed" % passed)
    quit()

func _test_default_hidden() -> void:
    var indicator := RedDot.new()
    root.add_child(indicator)
    await process_frame
    assert(not indicator.visible)
    assert(not indicator.is_active())
    passed += 1
    indicator.queue_free()
    await process_frame

func _test_runtime_visibility_updates() -> void:
    var indicator := RedDot.new()
    root.add_child(indicator)
    await process_frame
    indicator.set_active(true)
    assert(indicator.visible)
    assert(indicator.is_active())
    indicator.set_active(false)
    assert(not indicator.visible)
    assert(not indicator.is_active())
    passed += 1
    indicator.queue_free()
    await process_frame

func _test_repeated_updates_do_not_duplicate_nodes() -> void:
    var parent := Control.new()
    root.add_child(parent)
    var indicator := RedDot.new()
    indicator.attach_to(parent)
    await process_frame
    var initial_children := parent.get_child_count()
    for i in range(10):
        indicator.set_active(i % 2 == 0)
        indicator.set_active(false)
        indicator.set_active(true)
    assert(parent.get_child_count() == initial_children)
    assert(parent.get_child_count() == 1)
    passed += 1
    parent.queue_free()
    await process_frame

func _test_multiple_indicators_are_independent() -> void:
    var first := RedDot.new()
    var second := RedDot.new()
    root.add_child(first)
    root.add_child(second)
    await process_frame
    first.set_active(true)
    assert(first.is_active())
    assert(not second.is_active())
    second.set_active(true)
    first.set_active(false)
    assert(not first.is_active())
    assert(second.is_active())
    passed += 1
    first.queue_free()
    second.queue_free()
    await process_frame

func _test_parent_input_passthrough() -> void:
    var parent := Button.new()
    root.add_child(parent)
    var indicator := RedDot.new()
    indicator.attach_to(parent)
    await process_frame
    assert(indicator.mouse_filter == Control.MOUSE_FILTER_IGNORE)
    assert(indicator.focus_mode == Control.FOCUS_NONE)
    assert(parent.mouse_filter != Control.MOUSE_FILTER_IGNORE)
    passed += 1
    parent.queue_free()
    await process_frame

func _test_attach_layout_and_size() -> void:
    var parent := Control.new()
    parent.size = Vector2(200.0, 100.0)
    root.add_child(parent)
    var indicator := RedDot.new()
    indicator.attach_to(parent, Vector2(0.25, 0.75), Vector2(4.0, -6.0))
    indicator.set_dot_size(18.0)
    await process_frame
    assert(indicator.get_parent() == parent)
    assert(indicator.custom_minimum_size == Vector2(18.0, 18.0))
    assert(is_equal_approx(indicator.anchor_left, 0.25))
    assert(is_equal_approx(indicator.anchor_top, 0.75))
    assert(is_equal_approx(indicator.offset_left, -5.0))
    assert(is_equal_approx(indicator.offset_right, 13.0))
    assert(is_equal_approx(indicator.offset_top, -15.0))
    assert(is_equal_approx(indicator.offset_bottom, 3.0))
    passed += 1
    parent.queue_free()
    await process_frame
