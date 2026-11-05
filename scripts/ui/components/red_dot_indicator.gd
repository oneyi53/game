class_name RedDotIndicator
extends Control

## Purely visual red-dot marker. Business state must be supplied by the caller.
## Attach this as a child of a Control (for example, a Button) so it follows
## that control's layout. MOUSE_FILTER_IGNORE keeps mouse and touch input routed
## to the underlying interactive control.

@export var dot_color: Color = Color(0.95, 0.18, 0.16, 1.0):
    set(value):
        dot_color = value
        queue_redraw()

var _dot_size: Vector2 = Vector2(12.0, 12.0)
var _anchor: Vector2 = Vector2(1.0, 0.0)
var _anchor_offset: Vector2 = Vector2(-3.0, 3.0)

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    focus_mode = Control.FOCUS_NONE
    visible = false
    _apply_anchor_layout()

## Attach to a parent Control and position the dot relative to an anchor point.
## The anchor is normalized in the parent's rectangle; offset is measured in pixels.
func attach_to(target: Control, anchor: Vector2 = Vector2(1.0, 0.0), anchor_offset: Vector2 = Vector2(-3.0, 3.0)) -> void:
    if target == null:
        return
    if get_parent() != target:
        if get_parent() != null:
            get_parent().remove_child(self)
        target.add_child(self)
    _anchor = Vector2(clampf(anchor.x, 0.0, 1.0), clampf(anchor.y, 0.0, 1.0))
    _anchor_offset = anchor_offset
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    focus_mode = Control.FOCUS_NONE
    _apply_anchor_layout()

## Configure a square marker diameter in logical UI pixels.
func set_dot_size(diameter: float) -> void:
    _dot_size = Vector2.ONE * maxf(1.0, diameter)
    custom_minimum_size = _dot_size
    _apply_anchor_layout()
    queue_redraw()

## Update the display state. Repeated updates do not create or remove nodes.
func set_active(active: bool) -> void:
    if visible == active:
        return
    visible = active
    queue_redraw()

func is_active() -> bool:
    return visible

func _apply_anchor_layout() -> void:
    anchor_left = _anchor.x
    anchor_right = _anchor.x
    anchor_top = _anchor.y
    anchor_bottom = _anchor.y
    offset_left = _anchor_offset.x - _dot_size.x * 0.5
    offset_right = _anchor_offset.x + _dot_size.x * 0.5
    offset_top = _anchor_offset.y - _dot_size.y * 0.5
    offset_bottom = _anchor_offset.y + _dot_size.y * 0.5

func _draw() -> void:
    if not visible:
        return
    draw_circle(_dot_size * 0.5, minf(_dot_size.x, _dot_size.y) * 0.5, dot_color)
