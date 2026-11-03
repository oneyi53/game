class_name HeroVirtualJoystick
extends Control

# Dynamic virtual joystick: the base appears at the initial press point
# in the lower-left movement area, follows that touch until release,
# and disappears when released. Mouse input mirrors touch for desktop tests.

const DEAD_ZONE: float = 0.12
const RADIUS: float = 60.0
const KNOB_RADIUS: float = 25.0
const KNOB_TRAVEL: float = 40.0

var vector: Vector2 = Vector2.ZERO
var dragging: bool = false
var touch_index: int = -1
var touch_origin: Vector2 = Vector2.ZERO

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    set_process_input(true)
    queue_redraw()

func _input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        if event.pressed and not dragging and _is_movement_area(event.position):
            dragging = true
            touch_index = event.index
            touch_origin = event.position
            _update_vector(event.position)
            get_viewport().set_input_as_handled()
        elif not event.pressed and dragging and event.index == touch_index:
            _end_drag()
            get_viewport().set_input_as_handled()
    elif event is InputEventScreenDrag:
        if dragging and event.index == touch_index:
            _update_vector(event.position)
            get_viewport().set_input_as_handled()
    elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        if event.pressed and not dragging and _is_movement_area(event.position):
            dragging = true
            touch_index = -1
            touch_origin = event.position
            _update_vector(event.position)
            get_viewport().set_input_as_handled()
        elif not event.pressed and dragging and touch_index == -1:
            _end_drag()
            get_viewport().set_input_as_handled()
    elif event is InputEventMouseMotion and dragging and touch_index == -1:
        _update_vector(event.position)
        get_viewport().set_input_as_handled()

func _is_movement_area(pos: Vector2) -> bool:
    var viewport_size: Vector2 = get_viewport_rect().size
    # Reserve the right side for action buttons and the upper band for HUD.
    return pos.x <= viewport_size.x * 0.62 and pos.y >= viewport_size.y * 0.32

func _update_vector(pos: Vector2) -> void:
    var offset: Vector2 = pos - touch_origin
    if offset.length() > RADIUS:
        offset = offset.normalized() * RADIUS
    vector = offset / RADIUS
    queue_redraw()

func _end_drag() -> void:
    dragging = false
    touch_index = -1
    vector = Vector2.ZERO
    queue_redraw()

func _draw() -> void:
    if not dragging:
        return
    draw_circle(touch_origin, RADIUS, Color(1.0, 1.0, 1.0, 0.25))
    draw_circle(touch_origin + vector * KNOB_TRAVEL, KNOB_RADIUS, Color(1.0, 1.0, 1.0, 0.6))
