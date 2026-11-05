extends SceneTree

const JoystickScript = preload("res://scripts/ui/virtual_joystick.gd")

func _initialize() -> void:
    var joystick = JoystickScript.new()
    root.add_child(joystick)
    joystick.size = Vector2(720, 1280)

    # Idle hint matches the reference screenshot's lower-middle-left position.
    var idle_center: Vector2 = joystick._base_center()
    assert(idle_center.distance_to(Vector2(324, 896)) < 0.01)

    # Full-screen gameplay touches can activate the floating joystick.
    assert(joystick._can_start_at(Vector2(40, 80)))
    assert(joystick._can_start_at(Vector2(680, 1180)))
    assert(not joystick._can_start_at(Vector2(-1, 200)))

    # Base follows touch-down position, with safe edge clamping.
    joystick._begin_drag(Vector2(180, 420), 0, false)
    assert(joystick.dragging)
    assert(joystick._base_center().distance_to(Vector2(180, 420)) < 0.01)
    joystick._update_vector(Vector2(500, 420))
    assert(abs(joystick.vector.length() - 1.0) < 0.001)

    joystick._end_drag()
    assert(not joystick.dragging)
    assert(joystick.vector == Vector2.ZERO)
    assert(joystick._base_center().distance_to(idle_center) < 0.01)

    joystick._begin_drag(Vector2(2, 2), 1, false)
    assert(joystick._base_center().distance_to(Vector2(84, 84)) < 0.01)
    joystick._end_drag()

    print("Virtual joystick tests: 8 passed")
    quit()
