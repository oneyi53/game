class_name MapDrawer
extends Node2D

# Forest map presentation. Gameplay coordinates remain unchanged.
const MAP_WIDTH: int = 1600
const MAP_HEIGHT: int = 1200
const TILE: int = 64

const TREE_TEXTURE: Texture2D = preload("res://assets/art-v1/sprites/scene/tree_green.png")
const GOLDEN_TREE_TEXTURE: Texture2D = preload("res://assets/art-v1/sprites/scene/tree_yellow.png")
const TOWER_TEXTURE: Texture2D = preload("res://assets/art-v1/sprites/scene/tower.png")
const FOUNTAIN_TEXTURE: Texture2D = preload("res://assets/art-v1/sprites/scene/fountain.png")

var tree_positions: Array = [
    Vector2(120, 120), Vector2(300, 180), Vector2(1480, 140), Vector2(1320, 220),
    Vector2(140, 1040), Vector2(420, 1080), Vector2(1500, 1020), Vector2(1240, 1080),
    Vector2(180, 560), Vector2(1420, 640), Vector2(640, 120), Vector2(980, 1080),
    Vector2(220, 320), Vector2(1380, 880), Vector2(760, 240), Vector2(520, 920),
]

func _ready() -> void:
    _spawn_scene_art()

func _spawn_scene_art() -> void:
    # Decorative sprites now have matching physical blockers at their trunks.
    for i in range(tree_positions.size()):
        var tree := Sprite2D.new()
        tree.texture = GOLDEN_TREE_TEXTURE if i % 5 == 0 else TREE_TEXTURE
        tree.centered = false
        tree.offset = Vector2(-48.0, -96.0)
        tree.scale = Vector2(0.19, 0.19)
        tree.position = tree_positions[i]
        tree.z_index = 0
        add_child(tree)
        _add_obstacle(tree_positions[i] + Vector2(0.0, -8.0), 18.0, "TreeBlocker")

    _add_landmark(TOWER_TEXTURE, Vector2(260.0, 300.0), Vector2(0.34, 0.34), Vector2(-72.0, -170.0), 30.0)
    _add_landmark(FOUNTAIN_TEXTURE, Vector2(920.0, 500.0), Vector2(0.32, 0.32), Vector2(-64.0, -128.0), 28.0)

func _add_landmark(texture: Texture2D, world_position: Vector2, visual_scale: Vector2, visual_offset: Vector2, blocker_radius: float) -> void:
    var landmark := Sprite2D.new()
    landmark.texture = texture
    landmark.centered = false
    landmark.offset = visual_offset
    landmark.scale = visual_scale
    landmark.position = world_position
    add_child(landmark)
    _add_obstacle(world_position + Vector2(0.0, -8.0), blocker_radius, "LandmarkBlocker")

func _add_obstacle(world_position: Vector2, radius: float, node_name: String) -> void:
    var body := StaticBody2D.new()
    body.name = node_name
    body.position = world_position
    # Hero and enemy CharacterBody2D nodes use the default layer/mask (1).
    body.collision_layer = 1
    body.collision_mask = 1
    var shape := CollisionShape2D.new()
    var circle := CircleShape2D.new()
    circle.radius = radius
    shape.shape = circle
    body.add_child(shape)
    add_child(body)

func _draw() -> void:
    for xi in range(0, MAP_WIDTH / TILE):
        for yi in range(0, MAP_HEIGHT / TILE):
            var odd: bool = (xi + yi) % 2 == 0
            var tile_color: Color = Color(0.45, 0.76, 0.36) if odd else Color(0.5, 0.8, 0.4)
            draw_rect(Rect2(float(xi * TILE), float(yi * TILE), float(TILE), float(TILE)), tile_color)
    draw_rect(Rect2(0.0, 0.0, float(MAP_WIDTH), float(MAP_HEIGHT)), Color(0.2, 0.45, 0.2), false, 6.0)
    draw_rect(Rect2(200.0, 40.0, 1200.0, 280.0), Color(0.1, 0.4, 0.2, 0.12))
    draw_rect(Rect2(200.0, 40.0, 1200.0, 280.0), Color(0.1, 0.4, 0.2), false, 4.0)
    draw_rect(Rect2(40.0, 880.0, 720.0, 280.0), Color(0.1, 0.35, 0.3, 0.12))
    draw_rect(Rect2(40.0, 880.0, 720.0, 280.0), Color(0.1, 0.35, 0.3), false, 4.0)
    draw_rect(Rect2(840.0, 880.0, 720.0, 280.0), Color(0.5, 0.4, 0.1, 0.12))
    draw_rect(Rect2(840.0, 880.0, 720.0, 280.0), Color(0.5, 0.4, 0.1), false, 4.0)
    var label_font = ThemeDB.fallback_font
    if label_font != null:
        draw_string(label_font, Vector2(220.0, 75.0), "苔冠空地")
        draw_string(label_font, Vector2(60.0, 915.0), "落叶幽谷")
        draw_string(label_font, Vector2(860.0, 915.0), "朝露林地")
    for flower in [Vector2(260.0, 480.0), Vector2(500.0, 620.0), Vector2(900.0, 480.0), Vector2(1100.0, 700.0)]:
        draw_circle(flower, 4.0, Color(1.0, 0.85, 0.2))
        draw_circle(flower + Vector2(6.0, 6.0), 3.0, Color(1.0, 0.55, 0.35))
    for pebble in [Vector2(400.0, 420.0), Vector2(760.0, 760.0), Vector2(1180.0, 520.0)]:
        draw_circle(pebble, 3.0, Color(0.75, 0.75, 0.7))
    for stone in [Vector2(320.0, 180.0), Vector2(900.0, 260.0), Vector2(1250.0, 120.0)]:
        draw_circle(stone, 9.0, Color(0.65, 0.85, 0.7))
        draw_circle(stone + Vector2(4.0, -4.0), 3.0, Color(0.35, 0.7, 0.4))
    for leaf_pos in [Vector2(120.0, 960.0), Vector2(300.0, 1040.0), Vector2(520.0, 960.0), Vector2(660.0, 1080.0), Vector2(200.0, 1120.0)]:
        draw_circle(leaf_pos, 4.0, Color(1.0, 0.75, 0.2))
        draw_circle(leaf_pos + Vector2(7.0, 3.0), 3.0, Color(1.0, 0.55, 0.3))
    for puddle in [Vector2(1000.0, 1000.0), Vector2(1300.0, 1120.0), Vector2(1450.0, 960.0)]:
        draw_circle(puddle, 10.0, Color(0.55, 0.8, 1.0, 0.55))
    draw_rect(Rect2(1120.0, 1020.0, 60.0, 10.0), Color(0.6, 0.45, 0.25))
