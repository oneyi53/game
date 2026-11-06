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
var last_damage: int = 0
var damage_show_timer: float = 0.0
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
    if damage_show_timer > 0.0:
        damage_show_timer -= delta
        queue_redraw()
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
    last_damage = damage
    damage_show_timer = 0.8
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
    draw_rect(Rect2(-32.0, -100.0, 64.0, 6.0), Color(0.08, 0.08, 0.08, 0.92))
    var fill: float = 64.0 * float(hp) / float(max_hp) if max_hp > 0 else 0.0
    draw_rect(Rect2(-32.0, -100.0, fill, 6.0), Color(0.95, 0.22, 0.2))
    if damage_show_timer > 0.0:
        var dmg_font: Font = ThemeDB.fallback_font
        if dmg_font != null:
            var dmg_text: String = str(last_damage)
            var dmg_size: Vector2 = dmg_font.get_string_size(dmg_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 28)
            var dmg_y: float = -130.0 - (0.8 - damage_show_timer) * 50.0
            draw_string(dmg_font, Vector2(-dmg_size.x * 0.5, dmg_y), dmg_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 28, Color(1.0, 0.85, 0.2))
