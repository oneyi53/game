class_name Enemy
extends CharacterBody2D

const WorldProjectionScript = preload("res://scripts/core/world_projection.gd")
const WorldMaps = preload("res://scripts/core/world_map_manager.gd")

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
var attack_windup: float = 0.28
var attack_windup_remaining: float = 0.0
var hit_flash_remaining: float = 0.0
var knockback_velocity: Vector2 = Vector2.ZERO
var move_acceleration: float = 520.0

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
    if hit_flash_remaining > 0.0:
        hit_flash_remaining = maxf(0.0, hit_flash_remaining - delta)
        queue_redraw()
    if knockback_velocity.length_squared() > 4.0:
        velocity = knockback_velocity
        knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 900.0 * delta)
        move_and_slide()
        global_position = WorldMaps.clamp_position(global_position)
        return
    retarget_timer -= delta
    if retarget_timer <= 0.0:
        retarget_timer = 0.35
        _retarget()
    if target_hero == null or not is_instance_valid(target_hero) or bool(target_hero.get("dead")):
        attack_windup_remaining = 0.0
        velocity = velocity.move_toward(Vector2.ZERO, move_acceleration * delta)
        move_and_slide()
        return
    var diff: Vector2 = target_hero.global_position - global_position
    var distance_to_target: float = diff.length()
    if attack_windup_remaining > 0.0:
        velocity = velocity.move_toward(Vector2.ZERO, move_acceleration * 1.8 * delta)
        move_and_slide()
        attack_windup_remaining -= delta
        if attack_windup_remaining <= 0.0:
            attack_windup_remaining = 0.0
            if is_instance_valid(target_hero) and not bool(target_hero.get("dead")):
                var strike_distance: float = global_position.distance_to(target_hero.global_position)
                if strike_distance <= attack_range + 12.0 and target_hero.has_method("take_damage"):
                    target_hero.take_damage(attack)
            attack_timer = attack_cooldown
        global_position = WorldMaps.clamp_position(global_position)
        return
    if distance_to_target > attack_range:
        var desired_velocity: Vector2 = diff.normalized() * move_speed
        velocity = velocity.move_toward(desired_velocity, move_acceleration * delta)
        move_and_slide()
    else:
        velocity = velocity.move_toward(Vector2.ZERO, move_acceleration * 1.8 * delta)
        move_and_slide()
        attack_timer -= delta
        if attack_timer <= 0.0:
            attack_windup_remaining = attack_windup
    global_position = WorldMaps.clamp_position(global_position)

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
    hit_flash_remaining = 0.12
    attack_windup_remaining = 0.0
    var source: Node2D = null
    for hero in get_tree().get_nodes_in_group("heroes"):
        if hero != null and is_instance_valid(hero) and not bool(hero.get("dead")):
            if str(hero.get("world_map_id")) == str(get_meta("world_map_id", WorldMaps.MOSS_CROWN)):
                if source == null or global_position.distance_squared_to(hero.global_position) < global_position.distance_squared_to(source.global_position):
                    source = hero
    if source != null:
        var push_direction: Vector2 = (global_position - source.global_position).normalized()
        if push_direction == Vector2.ZERO:
            push_direction = Vector2.UP
        knockback_velocity = push_direction * 105.0
    queue_redraw()
    if hp <= 0:
        hp = 0
        dead = true
        died.emit(self)
        queue_free()

const ENEMY_TEXTURES := {
    "slime": preload("res://assets/art-v1/sprites/monsters/slime.png"),
    "wolf": preload("res://assets/art-v1/sprites/monsters/wolf.png"),
    "thorn_vine": preload("res://assets/art-v1/sprites/monsters/thorn_vine.png"),
    "forest_wasp": preload("res://assets/art-v1/sprites/monsters/forest_wasp.png"),
    "valley_firefly": preload("res://assets/art-v1/sprites/monsters/valley_firefly.png"),
    "withered_puppet": preload("res://assets/art-v1/sprites/monsters/withered_puppet.png"),
    "stream_spirit": preload("res://assets/art-v1/sprites/monsters/stream_spirit.png"),
    "valley_mushroom": preload("res://assets/art-v1/sprites/monsters/valley_mushroom.png"),
    "dawn_deer": preload("res://assets/art-v1/sprites/monsters/dawn_deer.png"),
    "hill_rock": preload("res://assets/art-v1/sprites/monsters/hill_rock.png")
}

func _draw() -> void:
    if dead:
        return
    var offset: Vector2 = WorldProjectionScript.world_to_screen(global_position) - global_position
    draw_set_transform(offset, 0.0, Vector2(1.0, 0.42))
    draw_circle(Vector2.ZERO, 13.0, Color(0.05, 0.18, 0.05, 0.25))
    draw_set_transform(offset)
    var texture: Texture2D = ENEMY_TEXTURES.get(enemy_id)
    if texture != null:
        draw_texture_rect(texture, Rect2(-48.0, -90.0, 96.0, 96.0), false)
    else:
        draw_circle(Vector2.ZERO, 16.0, enemy_color)
    if attack_windup_remaining > 0.0:
        var warning_strength: float = 0.5 + 0.5 * sin((attack_windup - attack_windup_remaining) * 32.0)
        draw_arc(Vector2.ZERO, 27.0, 0.0, TAU, 32, Color(1.0, 0.22, 0.12, warning_strength), 3.0)
    if hit_flash_remaining > 0.0:
        draw_rect(Rect2(-40.0, -84.0, 80.0, 76.0), Color(1.0, 0.35, 0.25, 0.28), false, 4.0)
    draw_rect(Rect2(-24.0, -98.0, 48.0, 5.0), Color(0.08, 0.08, 0.08, 0.92))
    var fill: float = 48.0 * float(hp) / float(max_hp) if max_hp > 0 else 0.0
    draw_rect(Rect2(-24.0, -98.0, fill, 5.0), Color(0.95, 0.22, 0.2))
