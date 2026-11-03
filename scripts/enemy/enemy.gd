class_name Enemy
extends CharacterBody2D

const WorldProjectionScript = preload("res://scripts/core/world_projection.gd")

# Ordinary monster. It retargets on a 0.5 s timer, never every frame,
# chases the nearest living party member inside its aggro range and
# attacks when that member is inside its attack range.

signal died(enemy)

var enemy_id: String = ""
var enemy_name: String = ""
var max_hp: int = 40
var hp: int = 40
var attack: int = 8
var defense: int = 0
var move_speed: float = 70.0
var attack_range: float = 40.0
var attack_cooldown: float = 1.0
var aggro_range: float = 220.0
var enemy_color: Color = Color.GREEN
var dead: bool = false
var target_hero: Node2D = null
var retarget_timer: float = 0.0
var attack_timer: float = 0.0

func setup(p_data: Dictionary) -> void:
    enemy_id = str(p_data["id"])
    enemy_name = str(p_data["name"])
    max_hp = int(p_data["hp"])
    hp = max_hp
    attack = int(p_data["attack"])
    defense = int(p_data["defense"])
    move_speed = float(p_data["move_speed"])
    attack_range = float(p_data["attack_range"])
    attack_cooldown = float(p_data["attack_cooldown"])
    aggro_range = float(p_data["aggro_range"])
    enemy_color = Color(str(p_data["color"]))
    queue_redraw()

func _physics_process(delta: float) -> void:
    if dead:
        return
    retarget_timer -= delta
    if retarget_timer <= 0.0:
        retarget_timer = 0.5
        _retarget()
    if target_hero == null or bool(target_hero.get("dead")):
        velocity = Vector2.ZERO
        move_and_slide()
        return
    var diff: Vector2 = target_hero.global_position - global_position
    if diff.length() > attack_range:
        velocity = diff.normalized() * move_speed
        move_and_slide()
    else:
        velocity = Vector2.ZERO
        move_and_slide()
        attack_timer -= delta
        if attack_timer <= 0.0:
            attack_timer = attack_cooldown
            if target_hero.has_method("take_damage"):
                target_hero.take_damage(attack)
    global_position.x = clamp(global_position.x, 20.0, 1580.0)
    global_position.y = clamp(global_position.y, 20.0, 1180.0)

func _retarget() -> void:
    var best: Node2D = null
    var best_dist: float = aggro_range
    for hero in get_tree().get_nodes_in_group("heroes"):
        if hero == null:
            continue
        if bool(hero.get("dead")):
            continue
        var dist: float = global_position.distance_to(hero.global_position)
        if dist <= best_dist:
            best_dist = dist
            best = hero
    target_hero = best

func take_damage(amount: int) -> void:
    if dead:
        return
    var damage: int = maxi(1, amount - defense)
    hp -= damage
    queue_redraw()
    if hp <= 0:
        hp = 0
        dead = true
        died.emit(self)
        queue_free()

func _draw() -> void:
    if dead:
        return
    var offset: Vector2 = WorldProjectionScript.world_to_screen(global_position) - global_position
    draw_set_transform(offset, 0.0, Vector2(1.0, 0.42))
    draw_circle(Vector2.ZERO, 13.0, Color(0.05, 0.18, 0.05, 0.25))
    draw_set_transform(offset)
    match enemy_id:
        "slime":
            draw_colored_polygon(PackedVector2Array([Vector2(-15.0, -3.0), Vector2(-13.0, -15.0), Vector2(-6.0, -21.0), Vector2(7.0, -21.0), Vector2(14.0, -13.0), Vector2(15.0, -3.0)]), enemy_color)
            draw_circle(Vector2(-5.0, -12.0), 3.0, Color.WHITE)
            draw_circle(Vector2(5.0, -12.0), 2.0, Color.WHITE)
            draw_circle(Vector2(-4.0, -6.0), 1.5, Color(0.1, 0.2, 0.1))
            draw_circle(Vector2(4.0, -6.0), 1.5, Color(0.1, 0.2, 0.1))
        "wolf":
            draw_colored_polygon(PackedVector2Array([Vector2(-12.0, -3.0), Vector2(-10.0, -20.0), Vector2(-5.0, -25.0), Vector2(7.0, -23.0), Vector2(14.0, -12.0), Vector2(12.0, -3.0)]), enemy_color)
            draw_colored_polygon(PackedVector2Array([Vector2(-11.0, -20.0), Vector2(-10.0, -32.0), Vector2(-3.0, -22.0)]), enemy_color.darkened(0.15))
            draw_colored_polygon(PackedVector2Array([Vector2(4.0, -22.0), Vector2(11.0, -32.0), Vector2(12.0, -19.0)]), enemy_color.darkened(0.15))
            draw_circle(Vector2(7.0, -15.0), 1.8, Color(0.1, 0.1, 0.1))
            draw_line(Vector2(-10.0, -5.0), Vector2(-17.0, -1.0), enemy_color.darkened(0.2), 4.0)
        "thorn_vine":
            draw_colored_polygon(PackedVector2Array([Vector2(-10.0, 0.0), Vector2(-14.0, -12.0), Vector2(-8.0, -25.0), Vector2(0.0, -18.0), Vector2(8.0, -26.0), Vector2(14.0, -12.0), Vector2(10.0, 0.0)]), enemy_color)
            draw_line(Vector2(-10.0, -12.0), Vector2(-20.0, -20.0), Color(0.2, 0.6, 0.3), 3.0)
            draw_line(Vector2(10.0, -12.0), Vector2(20.0, -20.0), Color(0.2, 0.6, 0.3), 3.0)
            draw_circle(Vector2(0.0, -10.0), 3.0, Color(0.8, 0.9, 0.35))
        "forest_wasp":
            draw_circle(Vector2(-12.0, -18.0), 8.0, Color(0.9, 1.0, 1.0, 0.48))
            draw_circle(Vector2(12.0, -18.0), 8.0, Color(0.9, 1.0, 1.0, 0.48))
            draw_colored_polygon(PackedVector2Array([Vector2(-8.0, -6.0), Vector2(-9.0, -19.0), Vector2(0.0, -26.0), Vector2(9.0, -19.0), Vector2(8.0, -6.0)]), enemy_color)
            draw_rect(Rect2(-9.0, -13.0, 18.0, 4.0), Color(0.18, 0.18, 0.1))
            draw_line(Vector2(0.0, -24.0), Vector2(0.0, -31.0), Color(0.2, 0.2, 0.1), 2.0)
        "valley_firefly":
            draw_circle(Vector2.ZERO, 10.0, enemy_color.lightened(0.12))
            draw_circle(Vector2(0.0, -2.0), 5.0, Color(1.0, 0.98, 0.55))
            draw_circle(Vector2(-10.0, -14.0), 5.0, Color(0.9, 1.0, 0.7, 0.55))
            draw_circle(Vector2(10.0, -14.0), 5.0, Color(0.9, 1.0, 0.7, 0.55))
        "withered_puppet":
            draw_colored_polygon(PackedVector2Array([Vector2(-11.0, 0.0), Vector2(-10.0, -19.0), Vector2(-6.0, -25.0), Vector2(7.0, -24.0), Vector2(11.0, -17.0), Vector2(9.0, 0.0)]), enemy_color)
            draw_line(Vector2(-7.0, -16.0), Vector2(-16.0, -8.0), Color(0.55, 0.35, 0.2), 3.0)
            draw_line(Vector2(7.0, -16.0), Vector2(16.0, -8.0), Color(0.55, 0.35, 0.2), 3.0)
            draw_circle(Vector2(-3.0, -17.0), 2.0, Color(1.0, 0.85, 0.45))
            draw_circle(Vector2(4.0, -17.0), 2.0, Color(1.0, 0.85, 0.45))
        "stream_spirit":
            draw_colored_polygon(PackedVector2Array([Vector2(-11.0, -2.0), Vector2(-15.0, -14.0), Vector2(-7.0, -25.0), Vector2(0.0, -31.0), Vector2(8.0, -22.0), Vector2(14.0, -10.0), Vector2(9.0, -2.0)]), enemy_color.lightened(0.15))
            draw_arc(Vector2(0.0, -9.0), 9.0, 0.2, 2.9, 14, Color(0.9, 1.0, 1.0, 0.85), 2.0)
        "valley_mushroom":
            draw_rect(Rect2(-5.0, -15.0, 10.0, 15.0), Color(0.92, 0.82, 0.68))
            draw_colored_polygon(PackedVector2Array([Vector2(-17.0, -15.0), Vector2(-14.0, -24.0), Vector2(-6.0, -30.0), Vector2(7.0, -30.0), Vector2(15.0, -23.0), Vector2(18.0, -15.0)]), enemy_color)
            draw_circle(Vector2(-7.0, -22.0), 2.5, Color(1.0, 0.9, 0.9))
            draw_circle(Vector2(7.0, -24.0), 2.5, Color(1.0, 0.9, 0.9))
        "dawn_deer":
            draw_colored_polygon(PackedVector2Array([Vector2(-12.0, -4.0), Vector2(-11.0, -19.0), Vector2(4.0, -22.0), Vector2(13.0, -12.0), Vector2(11.0, -3.0)]), enemy_color)
            draw_line(Vector2(-5.0, -20.0), Vector2(-10.0, -31.0), Color(0.7, 0.58, 0.38), 2.0)
            draw_line(Vector2(-10.0, -31.0), Vector2(-15.0, -34.0), Color(0.7, 0.58, 0.38), 2.0)
            draw_line(Vector2(5.0, -20.0), Vector2(10.0, -31.0), Color(0.7, 0.58, 0.38), 2.0)
            draw_line(Vector2(10.0, -31.0), Vector2(15.0, -34.0), Color(0.7, 0.58, 0.38), 2.0)
            draw_circle(Vector2(4.0, -17.0), 2.0, Color(0.12, 0.12, 0.12))
        "hill_rock":
            draw_colored_polygon(PackedVector2Array([Vector2(-15.0, -2.0), Vector2(-13.0, -17.0), Vector2(-5.0, -26.0), Vector2(8.0, -24.0), Vector2(15.0, -13.0), Vector2(12.0, -2.0)]), enemy_color)
            draw_colored_polygon(PackedVector2Array([Vector2(-8.0, -18.0), Vector2(-4.0, -24.0), Vector2(2.0, -20.0)]), Color(0.75, 0.75, 0.72))
            draw_circle(Vector2(7.0, -7.0), 3.0, Color(1.0, 0.8, 0.2))
    draw_rect(Rect2(-16.0, -39.0, 32.0, 5.0), Color(0.08, 0.08, 0.08, 0.9))
    var fill: float = 32.0 * float(hp) / float(max_hp) if max_hp > 0 else 0.0
    draw_rect(Rect2(-16.0, -39.0, fill, 5.0), Color(0.9, 0.2, 0.2))
