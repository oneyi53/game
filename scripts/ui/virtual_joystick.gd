class_name HeroVirtualJoystick
extends Control

# Floating full-screen joystick matching the portrait RPG reference behavior.
# GUI controls consume their own events before they reach _unhandled_input.

const BASE_RADIUS: float = 76.0
const KNOB_RADIUS: float = 25.0
const KNOB_TRAVEL: float = 48.0
const IDLE_BASE_POSITION: Vector2 = Vector2(0.45, 0.70)
const EDGE_PADDING: float = 84.0

var vector: Vector2 = Vector2.ZERO
var dragging: bool = false
var touch_index: int = -1
var mouse_dragging: bool = false
var active_base_center: Vector2 = Vector2.ZERO

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    set_process_input(true)
    resized.connect(_on_resized)
    queue_redraw()

func _on_resized() -> void:
    if not dragging:
        active_base_center = _idle_base_center()
    else:
        active_base_center = _clamp_base_center(active_base_center)
    queue_redraw()

func _idle_base_center() -> Vector2:
    return size * IDLE_BASE_POSITION

func _base_center() -> Vector2:
    return active_base_center if dragging else _idle_base_center()

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventScreenTouch and event.pressed and not dragging:
        _begin_drag(event.position, event.index, false)
        if dragging:
            get_viewport().set_input_as_handled()
    elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not dragging:
        _begin_drag(event.position, -1, true)
        if dragging:
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
    return Rect2(Vector2.ZERO, size).has_point(pos)

func _begin_drag(pos: Vector2, index: int, from_mouse: bool) -> void:
    if not _can_start_at(pos):
        return
    dragging = true
    touch_index = index
    mouse_dragging = from_mouse
    active_base_center = _clamp_base_center(pos)
    _update_vector(pos)
    queue_redraw()

func _clamp_base_center(pos: Vector2) -> Vector2:
    var padding := minf(EDGE_PADDING, minf(size.x, size.y) * 0.25)
    return Vector2(
        clampf(pos.x, padding, maxf(padding, size.x - padding)),
        clampf(pos.y, padding, maxf(padding, size.y - padding))
    )

func _update_vector(pos: Vector2) -> void:
    var offset: Vector2 = pos - active_base_center
    if offset.length() > BASE_RADIUS:
        offset = offset.normalized() * BASE_RADIUS
    vector = offset / BASE_RADIUS
    queue_redraw()

func _end_drag() -> void:
    dragging = false
    touch_index = -1
    mouse_dragging = false
    vector = Vector2.ZERO
    active_base_center = _idle_base_center()
    queue_redraw()

func _draw() -> void:
    var center := _base_center()
    draw_circle(center, BASE_RADIUS, Color(0.92, 0.96, 1.0, 0.10 if not dragging else 0.16))
    draw_arc(center, BASE_RADIUS, 0.0, TAU, 72, Color(1.0, 1.0, 1.0, 0.24), 2.0, true)
    draw_circle(center, BASE_RADIUS * 0.68, Color(1.0, 1.0, 1.0, 0.035))
    var knob_center := center + vector * KNOB_TRAVEL if dragging else center
    draw_circle(knob_center, KNOB_RADIUS + 4.0, Color(0.12, 0.18, 0.22, 0.12))
    draw_circle(knob_center, KNOB_RADIUS, Color(0.94, 0.97, 1.0, 0.34 if dragging else 0.20))
    draw_arc(knob_center, KNOB_RADIUS, 0.0, TAU, 48, Color(1.0, 1.0, 1.0, 0.42), 1.5, true)
