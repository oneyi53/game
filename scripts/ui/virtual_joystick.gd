class_name HeroVirtualJoystick
extends Control

# Full-screen floating joystick. A press on any unhandled/empty screen
# area creates the joystick at that point. Interactive UI controls get
# first refusal through GUI input; only the originating pointer drives it.

const RADIUS: float = 60.0
const KNOB_RADIUS: float = 25.0
const KNOB_TRAVEL: float = 40.0

var vector: Vector2 = Vector2.ZERO
var dragging: bool = false
var touch_index: int = -1
var mouse_dragging: bool = false
var touch_origin: Vector2 = Vector2.ZERO

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    set_process_input(true)
    queue_redraw()

# Start only after GUI controls have had a chance to consume the press.
func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventScreenTouch and event.pressed and not dragging:
        dragging = true
        touch_index = event.index
        mouse_dragging = false
        touch_origin = event.position
        _update_vector(event.position)
        get_viewport().set_input_as_handled()
    elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not dragging:
        dragging = true
        touch_index = -1
        mouse_dragging = true
        touch_origin = event.position
        _update_vector(event.position)
        get_viewport().set_input_as_handled()

# Once started, track and release globally so leaving the original point
# or control bounds cannot leave a stale movement vector behind.
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

func _update_vector(pos: Vector2) -> void:
    var offset: Vector2 = pos - touch_origin
    if offset.length() > RADIUS:
        offset = offset.normalized() * RADIUS
    vector = offset / RADIUS
    queue_redraw()

func _end_drag() -> void:
    dragging = false
    touch_index = -1
    mouse_dragging = false
    vector = Vector2.ZERO
    queue_redraw()

func _draw() -> void:
    if not dragging:
        return
    draw_circle(touch_origin, RADIUS, Color(1.0, 1.0, 1.0, 0.25))
    draw_circle(touch_origin + vector * KNOB_TRAVEL, KNOB_RADIUS, Color(1.0, 1.0, 1.0, 0.6))
