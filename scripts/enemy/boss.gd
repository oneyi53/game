class_name Boss
extends CharacterBody2D

const WorldProjectionScript = preload("res://scripts/core/world_projection.gd")
const WorldMaps = preload("res://scripts/core/world_map_manager.gd")

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
var targeted_attack_timer: float = 5.0
var targeted_telegraph_active: bool = false
var targeted_telegraph_time: float = 0.0
var targeted_telegraph_position: Vector2 = Vector2.ZERO

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
            targeted_telegraph_active = false
            targeted_attack_timer = 5.0
            queue_redraw()
        else:
            velocity = back_diff.normalized() * move_speed
            move_and_slide()
            global_position = WorldMaps.clamp_position(global_position)
        return
    if global_position.distance_to(spawn_position) > leash_range:
        returning = true
        telegraph_active = false
        targeted_telegraph_active = false
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
    _update_targeted_attack(delta)
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
    global_position = WorldMaps.clamp_position(global_position)

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
        if str(hero.get("world_map_id")) != str(get_meta("world_map_id", WorldMaps.MOSS_CROWN)):
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

const BOSS_TEXTURES := {
    "boss_tree": preload("res://assets/art-v1/sprites/bosses/boss_tree.png"),
    "boss_thorn": preload("res://assets/art-v1/sprites/bosses/boss_thorn.png")
}

func _draw() -> void:
    if dead:
        return
    var offset: Vector2 = WorldProjectionScript.world_to_screen(global_position) - global_position
    if targeted_telegraph_active:
        var boss_projected: Vector2 = WorldProjectionScript.world_to_screen(global_position)
        var target_projected: Vector2 = WorldProjectionScript.world_to_screen(targeted_telegraph_position)
        var target_local: Vector2 = target_projected - boss_projected
        var targeted_radius: float = 80.0 if phase == 1 else 95.0
        draw_set_transform(offset + target_local, 0.0, Vector2(0.7071068, 0.3535534))
        draw_circle(Vector2.ZERO, targeted_radius, Color(1.0, 0.55, 0.0, 0.24))
        draw_arc(Vector2.ZERO, targeted_radius, 0.0, TAU, 48, Color(1.0, 0.65, 0.1, 0.95), 3.0, true)
        draw_set_transform(offset)
    if telegraph_active:
        draw_set_transform(offset, 0.0, Vector2(0.7071068, 0.3535534))
        draw_circle(Vector2.ZERO, 95.0, Color(1.0, 0.0, 0.0, 0.22))
        draw_arc(Vector2.ZERO, 95.0, 0.0, TAU, 48, Color(1.0, 0.12, 0.12, 0.95), 3.0, true)
        for angle_step in range(8):
            var angle: float = TAU * float(angle_step) / 8.0
            draw_line(Vector2.ZERO, Vector2(cos(angle), sin(angle)) * 95.0, Color(1.0, 0.18, 0.18, 0.65), 1.5, true)
    draw_set_transform(offset, 0.0, Vector2(1.0, 0.42))
    draw_circle(Vector2.ZERO, 27.0, Color(0.05, 0.18, 0.05, 0.3))
    draw_set_transform(offset)
    var texture: Texture2D = BOSS_TEXTURES.get(enemy_id)
    if texture != null:
        draw_texture_rect(texture, Rect2(-96.0, -180.0, 192.0, 192.0), false)
    else:
        draw_circle(Vector2.ZERO, 28.0, boss_color)
    draw_rect(Rect2(-42.0, -218.0, 84.0, 9.0), Color(0.04, 0.04, 0.04, 0.98))
    var fill: float = 84.0 * float(hp) / float(max_hp) if max_hp > 0 else 0.0
    var phase_color: Color = Color(0.98, 0.62, 0.18) if phase >= 2 else Color(0.95, 0.2, 0.18)
    draw_rect(Rect2(-42.0, -218.0, fill, 9.0), phase_color)

func _update_targeted_attack(delta: float) -> void:
    if returning or dead:
        targeted_telegraph_active = false
        return
    if targeted_telegraph_active:
        targeted_telegraph_time -= delta
        if targeted_telegraph_time <= 0.0:
            _resolve_targeted_attack()
        return
    if target_hero == null or not is_instance_valid(target_hero) or bool(target_hero.get("dead")):
        return
    targeted_attack_timer -= delta
    if targeted_attack_timer <= 0.0:
        targeted_telegraph_active = true
        targeted_telegraph_time = 0.8
        targeted_telegraph_position = target_hero.global_position
        queue_redraw()

func _resolve_targeted_attack() -> void:
    targeted_telegraph_active = false
    var radius: float = 80.0 if phase == 1 else 95.0
    var damage: int = maxi(1, int(round(float(_effective_attack()) * 1.2)))
    var boss_map_id: String = str(get_meta("world_map_id", WorldMaps.MOSS_CROWN))
    for hero in get_tree().get_nodes_in_group("heroes"):
        if hero == null or not is_instance_valid(hero) or bool(hero.get("dead")):
            continue
        if str(hero.get("world_map_id")) != boss_map_id:
            continue
        if targeted_telegraph_position.distance_to(hero.global_position) <= radius:
            if hero.has_method("take_damage"):
                hero.take_damage(damage)
    targeted_attack_timer = 4.0 if phase >= 2 else 6.0
    queue_redraw()
