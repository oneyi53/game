class_name HeroVirtualJoystick
extends Control

# Left-side virtual joystick. Works with touch and with mouse drag,
# so it can be tested on desktop. Keyboard movement works independently
# and takes over when the joystick is not being dragged.

var vector: Vector2 = Vector2.ZERO
var dragging: bool = false
var touch_index: int = -1

func _gui_input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        if event.pressed and not dragging:
            dragging = true
            touch_index = event.index
            _update_vector(event.position)
        elif not event.pressed and event.index == touch_index:
            dragging = false
            vector = Vector2.ZERO
            queue_redraw()
    elif event is InputEventScreenDrag:
        if dragging and event.index == touch_index:
            _update_vector(event.position)
    elif event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT:
            if event.pressed and not dragging:
                dragging = true
                _update_vector(event.position)
            elif not event.pressed:
                dragging = false
                vector = Vector2.ZERO
                queue_redraw()
    elif event is InputEventMouseMotion:
        if dragging:
            _update_vector(event.position)

func _update_vector(pos: Vector2) -> void:
    var center: Vector2 = size / 2.0
    vector = (pos - center) / 60.0
    if vector.length() > 1.0:
        vector = vector.normalized()
    queue_redraw()

func _draw() -> void:
    var center: Vector2 = size / 2.0
    draw_circle(center, 60.0, Color(1.0, 1.0, 1.0, 0.25))
    draw_circle(center + vector * 40.0, 25.0, Color(1.0, 1.0, 1.0, 0.6))
