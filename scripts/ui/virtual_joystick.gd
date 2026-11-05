class_name HeroVirtualJoystick
extends Control

# Fixed-position translucent joystick inspired by the supplied mobile RPG
# reference. It only captures touches that begin near its visible base, so
# the rest of the world remains available for taps and gestures.

const BASE_RADIUS: float = 76.0
const ACTIVATE_RADIUS: float = 108.0
const KNOB_RADIUS: float = 25.0
const KNOB_TRAVEL: float = 48.0
const BASE_POSITION: Vector2 = Vector2(0.45, 0.70)

var vector: Vector2 = Vector2.ZERO
var dragging: bool = false
var touch_index: int = -1
var mouse_dragging: bool = false

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    set_process_input(true)
    resized.connect(queue_redraw)
    queue_redraw()

func _base_center() -> Vector2:
    return size * BASE_POSITION

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventScreenTouch and event.pressed and not dragging:
        if _can_start_at(event.position):
            dragging = true
            touch_index = event.index
            mouse_dragging = false
            _update_vector(event.position)
            get_viewport().set_input_as_handled()
    elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not dragging:
        if _can_start_at(event.position):
            dragging = true
            touch_index = -1
            mouse_dragging = true
            _update_vector(event.position)
            get_viewport().set_input_as_handled()

func _input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        if dragging and not mouse_dragging and event.index == touch_index and not event.pressed:
            _end_drag()
            get_viewport().set_input_as_handled()
    elif event is InputEventScreenDrag:
        if dragging and not mouse_dragging and event.index == touch_index:
            _update_vector(event.position)
            get_viewport().set_input_as_handled()
    elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        if dragging and mouse_dragging and not event.pressed:
            _end_drag()
            get_viewport().set_input_as_handled()
    elif event is InputEventMouseMotion and dragging and mouse_dragging:
        _update_vector(event.position)
        get_viewport().set_input_as_handled()

func _notification(what: int) -> void:
    if what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
        _end_drag()

func _can_start_at(pos: Vector2) -> bool:
    return pos.distance_to(_base_center()) <= ACTIVATE_RADIUS

func _update_vector(pos: Vector2) -> void:
    var offset: Vector2 = pos - _base_center()
    if offset.length() > BASE_RADIUS:
        offset = offset.normalized() * BASE_RADIUS
    vector = offset / BASE_RADIUS
    queue_redraw()

func _end_drag() -> void:
    dragging = false
    touch_index = -1
    mouse_dragging = false
    vector = Vector2.ZERO
    queue_redraw()

func _draw() -> void:
    var center := _base_center()
    # Low-contrast base remains visible while idle, matching the reference.
    draw_circle(center, BASE_RADIUS, Color(0.92, 0.96, 1.0, 0.10))
    draw_arc(center, BASE_RADIUS, 0.0, TAU, 72, Color(1.0, 1.0, 1.0, 0.24), 2.0, true)
    draw_circle(center, BASE_RADIUS * 0.68, Color(1.0, 1.0, 1.0, 0.035))
    var knob_center := center + vector * KNOB_TRAVEL if dragging else center
    draw_circle(knob_center, KNOB_RADIUS + 4.0, Color(0.12, 0.18, 0.22, 0.12))
    draw_circle(knob_center, KNOB_RADIUS, Color(0.94, 0.97, 1.0, 0.34 if dragging else 0.20))
    draw_arc(knob_center, KNOB_RADIUS, 0.0, TAU, 48, Color(1.0, 1.0, 1.0, 0.42), 1.5, true)
