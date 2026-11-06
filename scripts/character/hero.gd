class_name Hero
extends CharacterBody2D

const WorldProjectionScript = preload("res://scripts/core/world_projection.gd")
const WorldMaps = preload("res://scripts/core/world_map_manager.gd")

# One party member. The captain moves with the joystick or keyboard.
# Followers move toward a fixed offset from the captain and speed up
# when they fall behind, so a straggler rejoins the formation on its own.
# Attack scanning runs on a 0.25 s timer, never every frame.

signal died(hero)
signal hp_changed(hero)

var world_map_id: String = WorldMaps.MOSS_CROWN
var visual_formation_offset: Vector2 = Vector2.ZERO
var hero_id: String = ""
var hero_name: String = ""
var is_captain: bool = false
var data: Dictionary = {}
var max_hp: int = 100
var hp: int = 100
var attack: int = 10
var defense: int = 0
var move_speed: float = 200.0
var attack_range: float = 70.0
var attack_cooldown: float = 0.6
var hero_color: Color = Color.YELLOW
var dead: bool = false
var last_damage: int = 0
var damage_show_timer: float = 0.0
var level: int = 1
var level_attack_pct: float = 0.0
var level_hp_pct: float = 0.0
var move_input: Vector2 = Vector2.ZERO
var formation_offset: Vector2 = Vector2.ZERO
var captain_ref: Hero = null
var attack_timer: float = 0.0
var skill_cooldown_total: float = 5.0
var skill_cooldown_remaining: float = 0.0
var skill_ready: bool = true
var is_healer: bool = false
var is_assassin: bool = false
var crit_chance: float = 0.0
var crit_damage_pct: int = 0
var attack_speed_pct: int = 0
var scan_interval: float = 0.25
var heal_timer: float = 2.0
var dash_timer: float = 0.0

func setup(p_data: Dictionary, p_is_captain: bool) -> void:
    data = p_data
    hero_id = str(p_data["id"])
    hero_name = str(p_data["name"])
    is_captain = p_is_captain
    max_hp = int(p_data["hp"])
    hp = max_hp
    attack = int(p_data["attack"])
    defense = int(p_data["defense"])
    move_speed = float(p_data["move_speed"])
    attack_range = float(p_data["attack_range"])
    attack_cooldown = float(p_data["attack_cooldown"])
    hero_color = Color(str(p_data["color"]))
    is_healer = hero_id == "healer"
    is_assassin = hero_id == "assassin"
    queue_redraw()

# Stores the hero's level growth so reset_to_base_stats can rebuild
# the grown base stats. Level growth compounds on the base table
# values only; equipment bonuses are applied afterwards by the
# caller, never compounded into the base.
func set_level(p_level: int, p_attack_pct: float, p_hp_pct: float) -> void:
    level = p_level
    level_attack_pct = p_attack_pct
    level_hp_pct = p_hp_pct

# Restores the base stats from the hero table so a new set bonus
# can be applied from scratch instead of compounding on top of the
# old set's bonus. Called by main before re-applying after a swap
# or a level-up; current hp is handled by the caller (kept as a
# ratio of max hp). The restored base already includes level
# growth, so a swap or level-up never drops the hero to level 1.
func reset_to_base_stats() -> void:
    var growth_steps: int = maxi(0, level - 1)
    max_hp = int(round(float(data["hp"]) * pow(1.0 + level_hp_pct / 100.0, float(growth_steps))))
    attack = int(round(float(data["attack"]) * pow(1.0 + level_attack_pct / 100.0, float(growth_steps))))
    defense = int(data["defense"])
    crit_chance = 0.0
    crit_damage_pct = 0
    attack_speed_pct = 0
    scan_interval = 0.25

func apply_loose_equipment_bonus(bonus: Dictionary) -> void:
    attack += int(bonus.get("attack", 0))
    var hp_bonus: int = int(bonus.get("hp", 0))
    max_hp += hp_bonus
    defense += int(bonus.get("defense", 0))
    hp = mini(max_hp, hp + hp_bonus)
    queue_redraw()

func apply_camp_bonus(attack_pct: float, hp_pct: float) -> void:
    # Camp bonuses are applied after level growth and equipment, never compounded.
    attack = int(round(float(attack) * (1.0 + attack_pct / 100.0)))
    max_hp = int(round(float(max_hp) * (1.0 + hp_pct / 100.0)))
    hp = max_hp
    queue_redraw()

func apply_equipment_bonus(bonus: Dictionary) -> void:
    max_hp = int(round(float(max_hp) * (1.0 + float(bonus.get("hp_pct", 0)) / 100.0)))
    hp = max_hp
    attack = int(round(float(attack) * (1.0 + float(bonus.get("attack_pct", 0)) / 100.0)))
    defense = int(round(float(defense) * (1.0 + float(bonus.get("defense_pct", 0)) / 100.0)))
    crit_chance = float(bonus.get("crit_pct", 0)) / 100.0
    crit_damage_pct = int(bonus.get("crit_damage_pct", 0))
    attack_speed_pct = int(bonus.get("attack_speed_pct", 0))
    scan_interval = 0.25 / (1.0 + float(attack_speed_pct) / 100.0)
    queue_redraw()

func heal(amount: int) -> void:
    if dead:
        return
    hp = mini(max_hp, hp + amount)
    queue_redraw()
    hp_changed.emit(self)

func _physics_process(delta: float) -> void:
    if dead:
        velocity = Vector2.ZERO
        move_and_slide()
        return
    if skill_cooldown_remaining > 0.0:
        skill_cooldown_remaining -= delta
        if skill_cooldown_remaining <= 0.0:
            skill_cooldown_remaining = 0.0
            skill_ready = true
    if is_captain:
        velocity = move_input * move_speed
    else:
        velocity = Vector2.ZERO
        if captain_ref != null:
            var target_pos: Vector2 = captain_ref.global_position + formation_offset
            var diff: Vector2 = target_pos - global_position
            if diff.length() > 30.0:
                var speed: float = move_speed * 2.0 if diff.length() > 180.0 else move_speed
                velocity = diff.normalized() * speed
    move_and_slide()
    global_position = WorldMaps.clamp_position(global_position)
    if dash_timer > 0.0:
        dash_timer -= delta
    if is_healer:
        heal_timer -= delta
        if heal_timer <= 0.0:
            heal_timer = 2.0
            _heal_lowest_ally()
    attack_timer -= delta
    if damage_show_timer > 0.0:
        damage_show_timer -= delta
        queue_redraw()
    if attack_timer <= 0.0:
        attack_timer = scan_interval
        _scan_and_attack()

func _heal_lowest_ally() -> void:
    if dead:
        return
    var best: Node2D = null
    var best_ratio: float = 1.0
    for ally in get_tree().get_nodes_in_group("heroes"):
        if ally == null or ally == self:
            continue
        if str(ally.get("world_map_id")) != world_map_id:
            continue
        if bool(ally.get("dead")):
            continue
        var max_value: int = int(ally.get("max_hp"))
        if max_value <= 0:
            continue
        var ratio: float = float(ally.get("hp")) / float(max_value)
        if ratio < best_ratio:
            best_ratio = ratio
            best = ally
    if best != null and best.has_method("heal"):
        best.heal(attack)

func _scan_and_attack() -> void:
    if dead or is_healer:
        return
    if is_assassin and dash_timer <= 0.0:
        var dash_target: Node2D = null
        var dash_dist: float = 200.0
        for enemy in get_tree().get_nodes_in_group("enemies"):
            if enemy == null or bool(enemy.get("dead")):
                continue
            if str(enemy.get_meta("world_map_id", WorldMaps.MOSS_CROWN)) != world_map_id:
                continue
            var dist: float = global_position.distance_to(enemy.global_position)
            if dist <= dash_dist and dist > attack_range:
                dash_dist = dist
                dash_target = enemy
        if dash_target != null:
            var direction: Vector2 = (dash_target.global_position - global_position).normalized()
            global_position = dash_target.global_position - direction * 30.0
            dash_timer = 5.0
    var best: Node2D = null
    var best_dist: float = attack_range
    var best_hp: int = 0
    for enemy in get_tree().get_nodes_in_group("enemies"):
        if enemy == null:
            continue
        if bool(enemy.get("dead")):
            continue
        if str(enemy.get_meta("world_map_id", WorldMaps.MOSS_CROWN)) != world_map_id:
            continue
        var dist: float = global_position.distance_to(enemy.global_position)
        if dist > attack_range:
            continue
        if is_assassin:
            var enemy_hp: int = int(enemy.get("hp"))
            if best == null or enemy_hp < best_hp:
                best = enemy
                best_hp = enemy_hp
                best_dist = dist
        elif dist <= best_dist:
            best_dist = dist
            best = enemy
    if best == null:
        return
    var final_damage: int = attack
    if is_assassin:
        var target_max: int = int(best.get("max_hp"))
        if target_max > 0 and float(best.get("hp")) / float(target_max) <= 0.4:
            final_damage = int(round(float(final_damage) * 1.15))
    if crit_chance > 0.0 and randf() < crit_chance:
        final_damage = int(round(float(final_damage) * (2.0 + float(crit_damage_pct) / 100.0)))
    if best.has_method("take_damage"):
        best.take_damage(final_damage)

func take_damage(amount: int) -> void:
    if dead:
        return
    var damage: int = maxi(1, amount - defense)
    hp -= damage
    last_damage = damage
    damage_show_timer = 0.8
    if hp <= 0:
        hp = 0
        dead = true
        visible = false
        died.emit(self)
    queue_redraw()
    hp_changed.emit(self)

func respawn(at_position: Vector2) -> void:
    global_position = at_position
    hp = maxi(1, max_hp / 2)
    dead = false
    visible = true
    velocity = Vector2.ZERO
    queue_redraw()
    hp_changed.emit(self)

func use_skill() -> bool:
    if not is_captain or not skill_ready:
        return false
    skill_ready = false
    skill_cooldown_remaining = skill_cooldown_total
    for enemy in get_tree().get_nodes_in_group("enemies"):
        if enemy == null:
            continue
        if bool(enemy.get("dead")):
            continue
        if str(enemy.get_meta("world_map_id", WorldMaps.MOSS_CROWN)) != world_map_id:
            continue
        if global_position.distance_to(enemy.global_position) <= 140.0:
            if enemy.has_method("take_damage"):
                enemy.take_damage(attack * 2)
    return true

const HERO_TEXTURES := {
    "captain": preload("res://assets/art-v1/sprites/heroes/captain.png"),
    "archer": preload("res://assets/art-v1/sprites/heroes/archer.png"),
    "guardian": preload("res://assets/art-v1/sprites/heroes/guardian.png"),
    "mage": preload("res://assets/art-v1/sprites/heroes/mage.png"),
    "healer": preload("res://assets/art-v1/sprites/heroes/healer.png"),
    "assassin": preload("res://assets/art-v1/sprites/heroes/assassin.png")
}

func _draw() -> void:
    if dead:
        return
    var visual_world_position: Vector2 = global_position + visual_formation_offset
    var offset: Vector2 = WorldProjectionScript.world_to_screen(visual_world_position) - global_position
    draw_set_transform(offset, 0.0, Vector2(1.0, 0.42))
    draw_circle(Vector2.ZERO, 14.0, Color(0.05, 0.18, 0.05, 0.28))
    draw_set_transform(offset)
    var texture: Texture2D = HERO_TEXTURES.get(hero_id)
    if texture != null:
        draw_texture_rect(texture, Rect2(-48.0, -90.0, 96.0, 96.0), false)
    else:
        draw_circle(Vector2.ZERO, 18.0, hero_color)
    draw_rect(Rect2(-32.0, -100.0, 64.0, 6.0), Color(0.08, 0.08, 0.08, 0.9))
    var fill: float = 64.0 * float(hp) / float(max_hp) if max_hp > 0 else 0.0
    draw_rect(Rect2(-32.0, -100.0, fill, 6.0), Color(0.2, 0.9, 0.3))
    if damage_show_timer > 0.0:
        var dmg_font: Font = ThemeDB.fallback_font
        if dmg_font != null:
            var dmg_text: String = str(last_damage)
            var dmg_size: Vector2 = dmg_font.get_string_size(dmg_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 28)
            var dmg_y: float = -130.0 - (0.8 - damage_show_timer) * 50.0
            draw_string(dmg_font, Vector2(-dmg_size.x * 0.5, dmg_y), dmg_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 28, Color(1.0, 0.85, 0.2))
