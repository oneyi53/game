class_name WorldProjection
extends RefCounted

# Isometric projection is render-only. Never write projected screen
# positions back into CharacterBody2D.global_position or save data.

const MAP_WIDTH: float = 3000.0
const MAP_HEIGHT: float = 2250.0
const ISO_X_SCALE: float = 0.5
const ISO_Y_SCALE: float = 0.25
const HORIZONTAL_OFFSET: float = MAP_HEIGHT * ISO_X_SCALE

static func world_to_screen(world_position: Vector2) -> Vector2:
    return Vector2(
        (world_position.x - world_position.y) * ISO_X_SCALE + HORIZONTAL_OFFSET,
        (world_position.x + world_position.y) * ISO_Y_SCALE
    )

static func screen_depth(world_position: Vector2) -> float:
    return world_position.x + world_position.y

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
