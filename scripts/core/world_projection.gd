class_name WorldProjection
extends RefCounted

# Portrait-oriented isometric projection. Logical world coordinates remain
# unchanged for movement, combat and saves; only their rendered projection
# is rotated so the playable land fills a 720x1280 mobile viewport.
const MAP_WIDTH: float = 1600.0
const MAP_HEIGHT: float = 1400.0
const ISO_X_SCALE: float = 0.4
const ISO_Y_SCALE: float = 0.8
const VERTICAL_OFFSET: float = MAP_HEIGHT * ISO_Y_SCALE

static func world_to_screen(world_position: Vector2) -> Vector2:
    return Vector2(
        (world_position.x + world_position.y) * ISO_X_SCALE,
        (world_position.x - world_position.y) * ISO_Y_SCALE + VERTICAL_OFFSET
    )

# Convert a screen-space joystick direction into logical world movement.
static func screen_to_world_direction(screen_direction: Vector2) -> Vector2:
    return Vector2(
        1.25 * screen_direction.x + 0.625 * screen_direction.y,
        1.25 * screen_direction.x - 0.625 * screen_direction.y
    )

# Painter's order follows projected vertical depth and remains non-negative.
static func screen_depth(world_position: Vector2) -> float:
    return world_position.x - world_position.y + MAP_HEIGHT

static func world_rect_to_screen_polygon(rect: Rect2) -> PackedVector2Array:
    return PackedVector2Array([
        world_to_screen(rect.position),
        world_to_screen(Vector2(rect.end.x, rect.position.y)),
        world_to_screen(rect.end),
        world_to_screen(Vector2(rect.position.x, rect.end.y))
    ])

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
