extends SceneTree

const JoystickScript = preload("res://scripts/ui/virtual_joystick.gd")

func _initialize() -> void:
    var joystick = JoystickScript.new()
    root.add_child(joystick)
    joystick.size = Vector2(720, 1280)
    var center: Vector2 = joystick._base_center()
    assert(center.distance_to(Vector2(324, 896)) < 0.01)
    assert(joystick._can_start_at(center))
    assert(not joystick._can_start_at(center + Vector2(300, 0)))
    joystick._update_vector(center + Vector2(500, 0))
    assert(abs(joystick.vector.length() - 1.0) < 0.001)
    joystick._end_drag()
    assert(joystick.vector == Vector2.ZERO)
    print("Virtual joystick tests: 5 passed")
    quit()
