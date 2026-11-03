class_name Boss
extends CharacterBody2D

const Projection = preload("res://scripts/core/world_projection.gd")

# Boss. Two phases: below half health it moves faster, hits harder
# and telegraphs more often. Every telegraph shows a red ground circle
# for 0.8 s before damage lands. If the boss is pulled farther than
# its leash range from its spawn point, it walks back and returns to
# full health and phase 1.

signal died(enemy)

var enemy_id: String = ""
var enemy_name: String = ""
var max_hp: int = 400
var hp: int = 400
var attack: int = 20
var defense: int = 3
var move_speed: float = 80.0
var attack_range: float = 60.0
var attack_cooldown: float = 1.2
var aggro_range: float = 320.0
var leash_range: float = 420.0
var reward_gold: int = 100
var boss_color: Color = Color(0.13, 0.53, 0.13)
var dead: bool = false
var spawn_position: Vector2 = Vector2.ZERO
var phase: int = 1
var returning: bool = false
var target_hero: Node2D = null
var retarget_timer: float = 0.0
var attack_timer: float = 0.0
var telegraph_timer: float = 3.0
var telegraph_active: bool = false
var telegraph_time: float = 0.0

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
    leash_range = float(p_data["leash_range"])
    reward_gold = int(p_data["reward_gold"])
    boss_color = Color(str(p_data["color"]))
    queue_redraw()

func _effective_attack() -> int:
    if phase >= 2:
        return int(float(attack) * 1.5)
    return attack

func _effective_speed() -> float:
    if phase >= 2:
        return move_speed * 1.3
    return move_speed

func _physics_process(delta: float) -> void:
    if dead:
        return
    if returning:
        var back_diff: Vector2 = spawn_position - global_position
        if back_diff.length() < 10.0:
            returning = false
            hp = max_hp
            phase = 1
            telegraph_active = false
            telegraph_timer = 3.0
            queue_redraw()
        else:
            velocity = back_diff.normalized() * move_speed
            move_and_slide()
        return
    if global_position.distance_to(spawn_position) > leash_range:
        returning = true
        telegraph_active = false
        queue_redraw()
        return
    if hp <= max_hp / 2 and phase == 1:
        phase = 2
        queue_redraw()
    retarget_timer -= delta
    if retarget_timer <= 0.0:
        retarget_timer = 0.5
        _retarget()
    _update_telegraph(delta)
    if target_hero == null or bool(target_hero.get("dead")):
        velocity = Vector2.ZERO
        move_and_slide()
        return
    var diff: Vector2 = target_hero.global_position - global_position
    if diff.length() > attack_range:
        velocity = diff.normalized() * _effective_speed()
        move_and_slide()
    else:
        velocity = Vector2.ZERO
        move_and_slide()
        attack_timer -= delta
        if attack_timer <= 0.0:
            attack_timer = attack_cooldown
            if target_hero.has_method("take_damage"):
                target_hero.take_damage(_effective_attack())
    global_position.x = clamp(global_position.x, 20.0, 1580.0)
    global_position.y = clamp(global_position.y, 20.0, 1180.0)

func _update_telegraph(delta: float) -> void:
    if telegraph_active:
        telegraph_time -= delta
        if telegraph_time <= 0.0:
            telegraph_active = false
            telegraph_timer = 2.5 if phase >= 2 else 4.0
            for hero in get_tree().get_nodes_in_group("heroes"):
                if hero == null or bool(hero.get("dead")):
                    continue
                if global_position.distance_to(hero.global_position) <= 95.0:
                    if hero.has_method("take_damage"):
                        hero.take_damage(_effective_attack())
            queue_redraw()
        return
    telegraph_timer -= delta
    if telegraph_timer <= 0.0:
        var anyone_close: bool = false
        for hero in get_tree().get_nodes_in_group("heroes"):
            if hero == null or bool(hero.get("dead")):
                continue
            if global_position.distance_to(hero.global_position) <= 110.0:
                anyone_close = true
                break
        if anyone_close:
            telegraph_active = true
            telegraph_time = 0.8
            queue_redraw()

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
    draw_set_transform(Projection.world_to_screen(global_position) - global_position)
    if dead:
        return
    if telegraph_active:
        draw_circle(Vector2.ZERO, 95.0, Color(1.0, 0.0, 0.0, 0.25))
    # Visual only: body radius, telegraph radius, hp bar and all
    # stats are unchanged. Phase 2 only brightens the leaf crown.
    draw_circle(Vector2.ZERO, 28.0, boss_color)
    var leaf: Color = Color(0.6, 0.95, 0.4) if phase >= 2 else Color(0.6, 0.9, 0.4)
    draw_circle(Vector2(0.0, -8.0), 8.0, leaf)
    if enemy_id == "boss_tree":
        # Leaf crown: broad canopy circles + branch arms.
        draw_circle(Vector2(-16.0, -18.0), 10.0, leaf)
        draw_circle(Vector2(16.0, -18.0), 10.0, leaf)
        draw_circle(Vector2(0.0, -26.0), 11.0, leaf)
        draw_line(Vector2(-24.0, 2.0), Vector2(-34.0, -6.0), Color(0.4, 0.3, 0.15), 3.0)
        draw_line(Vector2(24.0, 2.0), Vector2(34.0, -6.0), Color(0.4, 0.3, 0.15), 3.0)
    elif enemy_id == "boss_thorn":
        # Thorn king: moss-green + stone-brown patches, thorn spikes.
        draw_circle(Vector2(-10.0, -12.0), 5.0, Color(0.5, 0.65, 0.4))
        draw_circle(Vector2(12.0, 8.0), 5.0, Color(0.55, 0.45, 0.3))
        draw_line(Vector2(-22.0, -10.0), Vector2(-30.0, -16.0), Color(0.2, 0.55, 0.3), 2.0)
        draw_line(Vector2(22.0, -10.0), Vector2(30.0, -16.0), Color(0.2, 0.55, 0.3), 2.0)
    draw_rect(Rect2(-30.0, -44.0, 60.0, 7.0), Color.BLACK)
    var fill: float = 60.0 * float(hp) / float(max_hp) if max_hp > 0 else 0.0
    draw_rect(Rect2(-30.0, -44.0, fill, 7.0), Color(0.9, 0.2, 0.2))
