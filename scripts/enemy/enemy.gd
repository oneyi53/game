class_name Enemy
extends CharacterBody2D

const Projection = preload("res://scripts/core/world_projection.gd")

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
    var projection_offset: Vector2 = Projection.world_to_screen(global_position) - global_position
    draw_set_transform(projection_offset, 0.0, Vector2(1.0, 0.45))
    draw_circle(Vector2.ZERO, 12.0, Color(0.05, 0.18, 0.05, 0.25))
    draw_set_transform(projection_offset + Vector2(0.0, -14.0))
    # Visual only: body circle radius, hp bar and all stats are
    # unchanged. Details are small marks inside the same 14 px body.
    # A-H art placeholders are mapped by theme here, not by letter:
    # hill_rock = the stone-slope food-storer (art G),
    # dawn_deer = the light-dappled forest-edge runner (art H);
    # the other six use their real names and colours.
    draw_circle(Vector2.ZERO, 14.0, enemy_color)
    match enemy_id:
        "slime":
            # Translucent bubbles inside the soft body.
            draw_circle(Vector2(-4.0, 2.0), 3.0, Color(1.0, 1.0, 1.0, 0.55))
            draw_circle(Vector2(5.0, -3.0), 2.0, Color(1.0, 1.0, 1.0, 0.55))
            draw_circle(Vector2(0.0, -5.0), 2.0, Color(0.1, 0.2, 0.1))
        "wolf":
            # Upright ears + tail line; alert, not menacing.
            draw_colored_polygon(PackedVector2Array([Vector2(-8.0, -12.0), Vector2(-4.0, -20.0), Vector2(-1.0, -12.0)]), Color(0.55, 0.45, 0.35))
            draw_colored_polygon(PackedVector2Array([Vector2(2.0, -12.0), Vector2(6.0, -20.0), Vector2(9.0, -12.0)]), Color(0.55, 0.45, 0.35))
            draw_line(Vector2(-13.0, 4.0), Vector2(-20.0, 10.0), Color(0.55, 0.45, 0.35), 2.0)
        "thorn_vine":
            # Thorn spikes + moss dots.
            draw_line(Vector2(-12.0, -6.0), Vector2(-18.0, -10.0), Color(0.2, 0.6, 0.3), 1.5)
            draw_line(Vector2(12.0, -6.0), Vector2(18.0, -10.0), Color(0.2, 0.6, 0.3), 1.5)
            draw_circle(Vector2(0.0, 6.0), 2.5, Color(0.5, 0.85, 0.4))
        "forest_wasp":
            # Translucent wings + stripe.
            draw_circle(Vector2(-6.0, -8.0), 5.0, Color(1.0, 1.0, 1.0, 0.5))
            draw_circle(Vector2(6.0, -8.0), 5.0, Color(1.0, 1.0, 1.0, 0.5))
            draw_rect(Rect2(-10.0, 2.0, 20.0, 3.0), Color(0.2, 0.2, 0.1))
        "valley_firefly":
            # Glow dots + antennae, bright yellow-green.
            draw_circle(Vector2(-8.0, -6.0), 2.5, Color(1.0, 0.95, 0.4))
            draw_circle(Vector2(8.0, -6.0), 2.5, Color(1.0, 0.95, 0.4))
            draw_line(Vector2(-3.0, -12.0), Vector2(-6.0, -18.0), Color(0.7, 0.9, 0.4), 1.5)
            draw_line(Vector2(3.0, -12.0), Vector2(6.0, -18.0), Color(0.7, 0.9, 0.4), 1.5)
        "withered_puppet":
            # Dry-leaf / wood patches.
            draw_circle(Vector2(-5.0, -4.0), 3.0, Color(0.6, 0.5, 0.3))
            draw_circle(Vector2(6.0, 4.0), 2.5, Color(0.45, 0.6, 0.3))
            draw_line(Vector2(-10.0, 8.0), Vector2(10.0, 8.0), Color(0.45, 0.35, 0.2), 1.5)
        "stream_spirit":
            # Water ripple + droplet.
            draw_circle(Vector2(0.0, -14.0), 3.0, Color(0.85, 0.95, 1.0, 0.85))
            draw_arc(Vector2(0.0, 6.0), 8.0, 0.2, 2.9, 10, Color(0.85, 0.95, 1.0, 0.7), 1.5)
        "valley_mushroom":
            # Cap spots on a rounded body.
            draw_circle(Vector2(-5.0, -6.0), 2.5, Color(1.0, 0.85, 0.85))
            draw_circle(Vector2(5.0, -6.0), 2.5, Color(1.0, 0.85, 0.85))
            draw_circle(Vector2(0.0, 0.0), 2.0, Color(1.0, 0.85, 0.85))
        "dawn_deer":
            # Antler lines + dappled leaf-shadow dots (art H).
            draw_line(Vector2(-5.0, -12.0), Vector2(-9.0, -20.0), Color(0.65, 0.55, 0.4), 1.5)
            draw_line(Vector2(5.0, -12.0), Vector2(9.0, -20.0), Color(0.65, 0.55, 0.4), 1.5)
            draw_circle(Vector2(-11.0, 6.0), 2.0, Color(0.6, 0.85, 0.5, 0.7))
            draw_circle(Vector2(11.0, 6.0), 2.0, Color(0.6, 0.85, 0.5, 0.7))
        "hill_rock":
            # Stone patches + warm-yellow food pouch (art G).
            draw_circle(Vector2(-5.0, -3.0), 3.0, Color(0.55, 0.55, 0.55))
            draw_circle(Vector2(6.0, 5.0), 2.5, Color(0.55, 0.55, 0.55))
            draw_circle(Vector2(0.0, 9.0), 3.0, Color(1.0, 0.8, 0.2))
    draw_rect(Rect2(-16.0, -26.0, 32.0, 5.0), Color.BLACK)
    var fill: float = 32.0 * float(hp) / float(max_hp) if max_hp > 0 else 0.0
    draw_rect(Rect2(-16.0, -26.0, fill, 5.0), Color(0.9, 0.2, 0.2))
