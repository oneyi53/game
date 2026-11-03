class_name WorldProjection
extends RefCounted

# Shared visual projection for Hero World's 2.5D world.
#
# IMPORTANT:
# Gameplay nodes keep their original world-space coordinates. This
# helper converts those coordinates for rendering only; callers must
# never write the projected result back to CharacterBody2D positions.
#
# Classic 2:1 isometric projection (45-degree ground axes):
# screen_x = (world_x - world_y) / 2
# screen_y = (world_x + world_y) / 4
#
# The horizontal offset makes the complete 1600x1200 logical map fit
# in a positive visual coordinate range. These constants affect only
# presentation and must not be used for gameplay distance checks.

const MAP_WIDTH: float = 1600.0
const MAP_HEIGHT: float = 1200.0
const ISO_X_SCALE: float = 0.5
const ISO_Y_SCALE: float = 0.25
const HORIZONTAL_OFFSET: float = MAP_HEIGHT * ISO_X_SCALE

static func world_to_screen(world_position: Vector2) -> Vector2:
    return Vector2(
        (world_position.x - world_position.y) * ISO_X_SCALE + HORIZONTAL_OFFSET,
        (world_position.x + world_position.y) * ISO_Y_SCALE
    )

static func screen_depth(world_position: Vector2) -> float:
    # Ground-plane depth. Larger values are visually nearer the viewer.
    return world_position.x + world_position.y

static func world_rect_to_screen_polygon(rect: Rect2) -> PackedVector2Array:
    var top_left: Vector2 = world_to_screen(rect.position)
    var top_right: Vector2 = world_to_screen(Vector2(rect.end.x, rect.position.y))
    var bottom_right: Vector2 = world_to_screen(rect.end)
    var bottom_left: Vector2 = world_to_screen(Vector2(rect.position.x, rect.end.y))
    return PackedVector2Array([top_left, top_right, bottom_right, bottom_left])

static func map_corners() -> PackedVector2Array:
    return world_rect_to_screen_polygon(Rect2(0.0, 0.0, MAP_WIDTH, MAP_HEIGHT))

static func projected_bounds() -> Rect2:
    var corners: PackedVector2Array = map_corners()
    var min_x: float = corners[0].x
    var max_x: float = corners[0].x
    var min_y: float = corners[0].y
    var max_y: float = corners[0].y
    for point in corners:
        min_x = minf(min_x, point.x)
        max_x = maxf(max_x, point.x)
        min_y = minf(min_y, point.y)
        max_y = maxf(max_y, point.y)
    return Rect2(Vector2(min_x, min_y), Vector2(max_x - min_x, max_y - min_y))
