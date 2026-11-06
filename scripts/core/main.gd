class_name Main
extends Node2D

# M1 main scene. Loads tables, spawns the party, monsters, boss and
# chest, runs the camera, the skill/interact/save buttons and saving.
# If a table is invalid, startup stops with an on-screen error and no
# fallback data is used. Unit count is capped at MAX_UNITS by the
# initial spawn plan (see _spawn_enemies): with a four-hero active party,
# main boss alive 4 + 2 + 1 = 7; main boss dead, elite alive 4 + 2 + 2 + 1 = 9;
# both bosses dead, third-zone quest open 4 + 1 + 1 + 4 = 10; both bosses
# dead, third-zone quest done, fourth zone open 4 + 1 + 1 + 2 + 2 = 10.
# When the third zone opens, the first and second zones each drop
# to 1 initial monster so the third zone's 4 still fit. When the
# fourth zone opens, the third zone drops to 2 initial monsters so
# the fourth zone's 2 still fit. The dropped species (wolf, forest
# wasp, then stream spirit, valley mushroom) are not lost: they go
# into the respawn queue with the same 8 s timer and spawn as soon
# as a unit slot frees, so no old kill quest can stall in a save
# that already beat the elite boss. Ordinary monsters
# respawn 8 s after death
# at their spawn point (bosses never respawn); without respawn the
# 8/6 kill quests were only completable by save/reload farming, since
# only 4 monsters spawned per run and nothing respawned.

const WorldProjectionScript = preload("res://scripts/core/world_projection.gd")
const WorldMapManagerScript = preload("res://scripts/core/world_map_manager.gd")
const WorldSaveMigrationScript = preload("res://scripts/core/world_save_migration.gd")
const FormationManagerScript = preload("res://scripts/core/formation_manager.gd")
const MAX_UNITS: int = 12
const RESPAWN_DELAY: float = 8.0

const HERO_SCENE: PackedScene = preload("res://scenes/hero.tscn")
const ENEMY_SCENE: PackedScene = preload("res://scenes/enemy.tscn")
const BOSS_SCENE: PackedScene = preload("res://scenes/boss.tscn")
const CAMPFIRE_SCENE: PackedScene = preload("res://scenes/campfire.tscn")
const EFFECT_PLAYER = preload("res://scripts/fx/effect_player.gd")
const EFFECT_ATLAS: Texture2D = preload("res://assets/art-v1/effects/effect_atlas.png")

@onready var camera: Camera2D = $Camera
@onready var heroes_root: Node2D = $Heroes
@onready var enemies_root: Node2D = $Enemies
@onready var chest_node: Chest = $Chest
@onready var hud: Hud = $UI/HUD
@onready var joystick: HeroVirtualJoystick = $UI/Joystick
@onready var hero_panel: HeroPanel = $UI/HeroPanel
@onready var equip_panel: EquipPanel = $UI/EquipPanel
@onready var camp_panel: CampPanel = $UI/CampPanel
@onready var backpack_panel: BackpackPanel = $UI/BackpackPanel
@onready var offline_panel: OfflinePanel = $UI/OfflinePanel
@onready var recruit_panel: RecruitPanel = $UI/RecruitPanel
@onready var quest_panel: QuestPanel = $UI/QuestPanel
@onready var map_panel: MapPanel = $UI/MapPanel
@onready var error_label: Label = $UI/ErrorLabel

var teleport_panel: PanelContainer = null
var teleport_list: VBoxContainer = null

var data_loader: DataLoader = null
var save_manager: SaveManager = null
var quest_manager: QuestManager = null
var equipment_manager: EquipmentManager = null
var camp_manager: CampManager = null
var backpack_manager: BackpackManager = null
var offline_manager: OfflineManager = null
var recruitment_manager: RecruitmentManager = null
var formation_manager: FormationManager = null
var level_manager: LevelManager = null
var pending_offline: Dictionary = {}
var world_map_manager: WorldMapManager = WorldMapManagerScript.new()
var active_map_id: String = WorldMapManagerScript.MOSS_CROWN
var map_positions: Dictionary = {}
var world_state_migrated: bool = false
var campfire_node: Node2D = null
var heroes: Array = []
var hero_hp_cache: Dictionary = {}
var enemies: Array = []
var boss: Boss = null
var elite_boss: Boss = null
var captain: Hero = null
var gold: int = 0
var wood: int = 0
var wood_cap: int = 200
var wood_drop_chance: float = 0.5
var wood_drop_min: int = 1
var wood_drop_max: int = 2
var chest_opened: bool = false
var boss_defeated: bool = false
var elite_defeated: bool = false
var valley_quest_done: bool = false
var respawn_queue: Array = []
var config_failed: bool = false
var gold_drop_chance: float = 0.3
var gold_drop_min: int = 1
var gold_drop_max: int = 2

func _ready() -> void:
    data_loader = DataLoader.new()
    if not data_loader.load_all():
        config_failed = true
        error_label.text = "配置错误，无法启动：" + data_loader.error_message
        push_error(data_loader.error_message)
        return
    quest_manager = QuestManager.new()
    if not quest_manager.load_quests():
        config_failed = true
        error_label.text = "配置错误，无法启动：" + quest_manager.error_message
        push_error(quest_manager.error_message)
        return
    quest_manager.quest_completed.connect(_on_quest_completed)
    equipment_manager = EquipmentManager.new()
    if not equipment_manager.load_sets():
        config_failed = true
        error_label.text = "配置错误，无法启动：" + equipment_manager.error_message
        push_error(equipment_manager.error_message)
        return
    camp_manager = CampManager.new()
    if not camp_manager.load_all():
        config_failed = true
        error_label.text = "配置错误，无法启动：" + camp_manager.error_message
        push_error(camp_manager.error_message)
        return
    backpack_manager = BackpackManager.new()
    if not backpack_manager.load_all():
        config_failed = true
        error_label.text = "配置错误，无法启动：" + backpack_manager.error_message
        push_error(backpack_manager.error_message)
        return
    offline_manager = OfflineManager.new()
    if not offline_manager.load_all():
        config_failed = true
        error_label.text = "配置错误，无法启动：" + offline_manager.error_message
        push_error(offline_manager.error_message)
        return
    var hero_ids: Array = []
    for hero_data in data_loader.heroes:
        hero_ids.append(str(hero_data["id"]))
    recruitment_manager = RecruitmentManager.new()
    if not recruitment_manager.load_all(hero_ids):
        config_failed = true
        error_label.text = "配置错误，无法启动：" + recruitment_manager.error_message
        push_error(recruitment_manager.error_message)
        return
    level_manager = LevelManager.new()
    if not level_manager.load_all():
        config_failed = true
        error_label.text = "配置错误，无法启动：" + level_manager.error_message
        push_error(level_manager.error_message)
        return
    var gold_drop = data_loader.items.get("gold_drop", {})
    if gold_drop is Dictionary:
        gold_drop_chance = float(gold_drop.get("chance", 0.3))
        gold_drop_min = int(gold_drop.get("min", 1))
        gold_drop_max = int(gold_drop.get("max", 2))
    wood_cap = int(data_loader.items.get("wood_cap", 200))
    var wood_drop = data_loader.items.get("wood_drop", {})
    if wood_drop is Dictionary:
        wood_drop_chance = float(wood_drop.get("chance", 0.5))
        wood_drop_min = int(wood_drop.get("min", 1))
        wood_drop_max = int(wood_drop.get("max", 2))
    save_manager = SaveManager.new()
    var load_result: Dictionary = save_manager.load_game()
    var save_data: Dictionary = save_manager.default_data()
    var had_save: bool = false
    if load_result["status"] == "ok":
        save_data = load_result["data"]
        had_save = true
    elif load_result["status"] == "restored_from_backup":
        save_data = load_result["data"]
        had_save = true
        hud.show_message("主存档损坏，已用备份恢复")
    elif load_result["status"] == "corrupted":
        hud.show_message("存档损坏且无可用备份，从头开始")
    # A genuinely new install has no save files; do not label it corrupted.
    gold = int(save_data.get("gold", 0))
    backpack_manager.load_saved(save_data.get("backpack", {}))
    wood = mini(wood_cap, maxi(0, int(save_data.get("wood", 0))))
    # Offline settlement (simplified): computed once from the
    # saved timestamp, applied to gold/wood here, shown and saved
    # once after the panels are wired below. An old save without
    # last_saved_unix gets nothing retroactively; its next save
    # stamps the timestamp, so later sessions can settle.
    pending_offline = offline_manager.settle(int(Time.get_unix_time_from_system()), save_data.get("last_saved_unix", 0), wood, wood_cap)
    if bool(pending_offline.get("eligible", false)):
        gold += int(pending_offline.get("gold", 0))
        wood = mini(wood_cap, wood + int(pending_offline.get("wood", 0)))
    camp_manager.load_camp(save_data.get("camp", {}))
    # Recruitment migration: a save file without a "recruitment"
    # field is an old full-roster save, so all heroes stay
    # recruited at level 1; only a game with no save file at all
    # starts with the captain alone. Nothing else in the save is
    # touched by this migration.
    recruitment_manager.load_saved(save_data.get("recruitment", {}), had_save, hero_ids)
    level_manager.load_saved(save_data.get("levels", {}), hero_ids)
    formation_manager = FormationManagerScript.new()
    var owned_hero_ids: Array = []
    for owned_hero_id in recruitment_manager.entry_order:
        if recruitment_manager.is_recruited(str(owned_hero_id)):
            owned_hero_ids.append(str(owned_hero_id))
    var saved_formation = save_data.get("formation", {})
    if not formation_manager.configure(owned_hero_ids, saved_formation, owned_hero_ids):
        hud.show_message("编队数据异常，已按已拥有英雄恢复")
        if not formation_manager.configure(owned_hero_ids):
            config_failed = true
            error_label.text = "编队初始化失败：" + formation_manager.error_message
            push_error(error_label.text)
            return
    chest_opened = bool(save_data.get("chest_opened", false))
    boss_defeated = bool(save_data.get("boss_defeated", false))
    elite_defeated = bool(save_data.get("elite_defeated", false))
    quest_manager.load_progress(save_data.get("quests", {}))
    equipment_manager.load_equipped(save_data.get("equipment", {}))
    equipment_manager.load_loose_equipped(save_data.get("loose_equipment", {}), backpack_manager.items)
    # Fourth zone gate: only after the third-zone quest is done.
    # It reuses the saved quest completion, so no new save field is
    # needed; an old save without that quest entry defaults closed.
    # It also implies the elite boss is dead, but check both so a
    # hand-edited save cannot open the zone out of order.
    valley_quest_done = elite_defeated and quest_manager.is_completed("side_valley_puppet")
    # Actual spawn plan, mirroring _spawn_enemies exactly: the
    # first and second zones each spawn 1 initial monster once the
    # third zone opens (elite defeated), otherwise 2 each when open.
    # Once the fourth zone opens, the third zone drops to 2.
    var planned_units: int = formation_manager.active_ids.size()
    if valley_quest_done:
        planned_units += 1 + 1 + 2 + 2
    elif elite_defeated:
        planned_units += 1 + 1 + 4
    else:
        planned_units += 2
        if boss_defeated:
            planned_units += 2
    if not boss_defeated:
        planned_units += 1
    elif not elite_defeated:
        planned_units += 1
    if planned_units > MAX_UNITS:
        config_failed = true
        error_label.text = "单位数量超过上限：" + str(planned_units)
        push_error(error_label.text)
        return
    var migration_result: Dictionary = WorldSaveMigrationScript.migrate_save(save_data)
    save_data = migration_result["data"]
    world_state_migrated = bool(migration_result.get("migrated", false))
    active_map_id = str(migration_result.get("map_id", WorldMapManagerScript.MOSS_CROWN))
    if not world_map_manager.is_unlocked(active_map_id, boss_defeated, elite_defeated, valley_quest_done):
        active_map_id = WorldMapManagerScript.MOSS_CROWN
    var saved_map_positions = save_data.get("map_positions", {})
    if saved_map_positions is Dictionary:
        for saved_map_id in saved_map_positions:
            var saved_map_position = saved_map_positions[saved_map_id]
            if world_map_manager.is_known_map(str(saved_map_id)) and saved_map_position is Dictionary:
                map_positions[str(saved_map_id)] = Vector2(float(saved_map_position.get("x", 600.0)), float(saved_map_position.get("y", 600.0)))
    _spawn_heroes(save_data)
    _spawn_enemies()
    _spawn_campfire()
    $Map.set_active_map(active_map_id)
    $Map.building_pressed.connect(_on_town_building_pressed)
    _apply_active_map_visibility()
    var chest_loot: Dictionary = data_loader.items["chest_loot"]
    chest_node.setup(int(chest_loot["gold"]), chest_opened)
    chest_node.opened.connect(_on_chest_opened)
    _ensure_teleport_panel()
    hud.teleport_pressed.connect(_on_teleport_pressed)
    hud.map_pressed.connect(_on_map_pressed)
    hud.set_teleport_available(_has_unlocked_campfire())
    hud.skill_pressed.connect(_on_skill_pressed)
    hud.interact_pressed.connect(_on_interact_pressed)
    hud.save_pressed.connect(_on_save_pressed)
    hud.hero_panel_pressed.connect(_on_hero_panel_pressed)
    hud.equip_panel_pressed.connect(_on_equip_panel_pressed)
    hud.camp_panel_pressed.connect(_on_camp_panel_pressed)
    hud.backpack_panel_pressed.connect(_on_backpack_panel_pressed)
    hud.recruit_panel_pressed.connect(_on_recruit_panel_pressed)
    hud.quest_pressed.connect(_on_quest_panel_pressed)
    hud.offline_pressed.connect(_on_offline_panel_pressed)
    hud.set_quest_manager(quest_manager)
    hero_panel.close_requested.connect(func() -> void: hero_panel.visible = false)
    backpack_panel.close_requested.connect(func() -> void: backpack_panel.visible = false)
    map_panel.map_selected.connect(_on_map_panel_selected)
    map_panel.close_requested.connect(func() -> void: map_panel.visible = false)
    recruit_panel.set_data(recruitment_manager, level_manager, data_loader.heroes)
    recruit_panel.synthesize_requested.connect(_on_recruit_synthesize)
    recruit_panel.visible = false
    backpack_panel.set_manager(backpack_manager, heroes)
    backpack_panel.set_hero_roster(formation_manager.owned_ids, data_loader.heroes, formation_manager.active_ids)
    backpack_panel.equip_requested.connect(_on_backpack_equip)
    backpack_panel.decompose_requested.connect(_on_backpack_decompose)
    backpack_panel.claim_requested.connect(_on_backpack_claim)
    backpack_panel.visible = false
    hud.set_gold(gold)
    hud.set_wood(wood, wood_cap)
    camp_panel.set_manager(camp_manager)
    camp_panel.build_requested.connect(_on_camp_build)
    camp_panel.hero_panel_requested.connect(_on_camp_hero_panel_pressed)
    camp_panel.visible = false
    _refresh_quest_label()
    hero_panel.set_heroes(heroes)
    hero_panel.set_formation_data(formation_manager, data_loader.heroes, level_manager, equipment_manager, camp_manager, backpack_manager.items)
    _refresh_top_bar()
    hero_panel.leader_requested.connect(_on_formation_leader_requested)
    hero_panel.add_requested.connect(_on_formation_add_requested)
    hero_panel.remove_requested.connect(_on_formation_remove_requested)
    hero_panel.visible = false
    equip_panel.set_roster(formation_manager.owned_ids, data_loader.heroes, equipment_manager, heroes)
    equip_panel.set_item_definitions(backpack_manager.items)
    equip_panel.swap_requested.connect(_on_equip_swap)
    equip_panel.unequip_requested.connect(_on_loose_unequip)
    equip_panel.visible = false
    offline_panel.visible = false
    if bool(pending_offline.get("eligible", false)):
        # Save at once so this offline span cannot be claimed
        # again; the panel only displays what is already credited.
        hud.set_gold(gold)
        hud.set_wood(wood, wood_cap)
        _save_game()
        var off_gold: int = int(pending_offline.get("gold", 0))
        var off_wood: int = int(pending_offline.get("wood", 0))
        if off_gold > 0 or off_wood > 0:
            var billed: int = int(pending_offline.get("billed_seconds", 0))
            var lines: Array = ["离线结算：离线 " + str(billed / 3600) + " 小时 " + str((billed % 3600) / 60) + " 分钟（按封顶后算）"]
            if off_gold > 0:
                lines.append("金币 +" + str(off_gold))
            if off_wood > 0:
                lines.append("木材 +" + str(off_wood))
            offline_panel.show_settlement(lines)
    camera.make_current()
    if captain != null:
        camera.position = _projected_camera_position(captain.global_position)
    if world_state_migrated and had_save and not bool(pending_offline.get("eligible", false)):
        # SaveManager preserves the previous valid save as backup before
        # replacing it with the map-local format.
        _save_game()

func _spawn_heroes(save_data: Dictionary) -> void:
    # Only active formation members spawn. The first slot is the
    # replaceable leader; owned reserve heroes keep their progression
    # and equipment data in the managers without requiring a world node.
    var offsets: Array = [Vector2.ZERO, Vector2(-70.0, 35.0), Vector2(70.0, 35.0), Vector2(0.0, 85.0), Vector2(-70.0, 85.0), Vector2(70.0, 85.0)]
    var start_pos: Vector2 = world_map_manager.spawn_position(active_map_id)
    if map_positions.has(active_map_id):
        start_pos = map_positions[active_map_id]
    elif str(save_data.get("map_id", "")) == active_map_id and save_data.get("player_position") is Dictionary:
        var saved_pos: Dictionary = save_data["player_position"]
        start_pos = Vector2(float(saved_pos.get("x", start_pos.x)), float(saved_pos.get("y", start_pos.y)))
    start_pos = WorldMapManagerScript.clamp_position(start_pos)
    # Restore per-hero HP after level and equipment have rebuilt max_hp.
    # Older saves without a heroes array retain the full-health default.
    var saved_hp_by_id: Dictionary = {}
    var saved_heroes = save_data.get("heroes", [])
    if saved_heroes is Array:
        for saved_hero in saved_heroes:
            if saved_hero is Dictionary and saved_hero.has("id") and saved_hero.has("hp"):
                var saved_hero_id: String = str(saved_hero["id"])
                var saved_hp_value: int = int(saved_hero["hp"])
                saved_hp_by_id[saved_hero_id] = saved_hp_value
                hero_hp_cache[saved_hero_id] = saved_hp_value
    var spawn_index: int = 0
    for hero_id_value in formation_manager.active_ids:
        var hero_id: String = str(hero_id_value)
        var hero_data: Dictionary = {}
        for entry in data_loader.heroes:
            if str(entry["id"]) == hero_id:
                hero_data = entry
                break
        if hero_data.is_empty():
            continue
        var hero = HERO_SCENE.instantiate()
        hero.setup(hero_data, spawn_index == 0)
        hero.world_map_id = active_map_id
        hero.visual_formation_offset = offsets[spawn_index] * 2.1
        hero.set_level(level_manager.level(hero_id), level_manager.attack_growth_pct_per_level, level_manager.hp_growth_pct_per_level)
        _rebuild_hero_stats(hero, false)
        if saved_hp_by_id.has(hero_id):
            var saved_hp: int = int(saved_hp_by_id[hero_id])
            # A hero saved during the 3-second death delay resumes at the
            # same half-health amount used by the normal respawn routine.
            hero.hp = maxi(1, hero.max_hp / 2) if saved_hp <= 0 else clampi(saved_hp, 1, hero.max_hp)
            hero_hp_cache[hero_id] = hero.hp
            hero.queue_redraw()
        else:
            hero_hp_cache[hero_id] = hero.hp
        hero.global_position = start_pos + offsets[spawn_index]
        hero.formation_offset = offsets[spawn_index]
        heroes_root.add_child(hero)
        hero.add_to_group("heroes")
        hero.died.connect(_on_hero_died)
        hero.hp_changed.connect(_on_hero_hp_changed)
        heroes.append(hero)
        if spawn_index == 0:
            captain = hero
        spawn_index += 1
    for hero in heroes:
        if hero != captain:
            hero.captain_ref = captain

# Spawns a newly recruited hero mid-run at the captain's side, with
# its level growth and preset equipment applied, so the party grows
# without a reload. Returns false if the hero is already present.
func _spawn_recruited_hero(hero_id: String) -> bool:
    for hero in heroes:
        if hero.hero_id == hero_id:
            return false
    var hero_data: Dictionary = {}
    for entry in data_loader.heroes:
        if str(entry["id"]) == hero_id:
            hero_data = entry
            break
    if hero_data.is_empty() or captain == null:
        return false
    var offsets: Array = [Vector2.ZERO, Vector2(-70.0, 35.0), Vector2(70.0, 35.0), Vector2(0.0, 85.0), Vector2(-70.0, 85.0), Vector2(70.0, 85.0)]
    var index: int = heroes.size()
    var hero = HERO_SCENE.instantiate()
    hero.setup(hero_data, false)
    hero.world_map_id = active_map_id
    hero.visual_formation_offset = offsets[index] * 2.1
    hero.set_level(level_manager.level(hero_id), level_manager.attack_growth_pct_per_level, level_manager.hp_growth_pct_per_level)
    _rebuild_hero_stats(hero, false)
    hero.global_position = captain.global_position + offsets[index]
    hero.formation_offset = offsets[index]
    heroes_root.add_child(hero)
    hero.add_to_group("heroes")
    hero.died.connect(_on_hero_died)
    hero.hp_changed.connect(_on_hero_hp_changed)
    hero.captain_ref = captain
    heroes.append(hero)
    return true

func _grant_party_xp(amount: int) -> void:
    if level_manager == null or amount <= 0:
        return
    for hero in heroes:
        var result: Dictionary = level_manager.gain_xp(hero.hero_id, amount)
        var gained: int = int(result.get("levels_gained", 0))
        if gained <= 0:
            continue
        var hp_ratio: float = float(hero.hp) / float(hero.max_hp) if hero.max_hp > 0 else 1.0
        hero.set_level(level_manager.level(hero.hero_id), level_manager.attack_growth_pct_per_level, level_manager.hp_growth_pct_per_level)
        _rebuild_hero_stats(hero, true)
        hero.hp = maxi(1, int(round(hp_ratio * float(hero.max_hp))))
        hero.queue_redraw()
        hud.show_message(str(hero.hero_name) + " 升到 " + str(level_manager.level(hero.hero_id)) + " 级！")
    _refresh_top_bar()
    if hero_panel.visible:
        hero_panel.refresh()

func _spawn_enemy_at(enemy_id: String, _legacy_pos: Vector2) -> bool:
    var enemy_data = data_loader.get_enemy(enemy_id)
    if enemy_data == null:
        config_failed = true
        error_label.text = "配置错误，无法启动：" + data_loader.error_message
        push_error(data_loader.error_message)
        return false
    var enemy = ENEMY_SCENE.instantiate()
    enemy.setup(enemy_data)
    var enemy_map_id: String = world_map_manager.map_for_enemy(enemy_id)
    var local_spawn: Vector2 = world_map_manager.enemy_spawn_position(enemy_id)
    enemy.global_position = local_spawn
    enemy.set_meta("spawn_pos", local_spawn)
    enemy.set_meta("world_map_id", enemy_map_id)
    enemies_root.add_child(enemy)
    enemy.add_to_group("enemies")
    enemy.died.connect(_on_enemy_died)
    enemies.append(enemy)
    return true

func _spawn_enemies() -> void:
    # Third zone (south, the Fallen Leaf Valley) opens only after
    # the elite boss is defeated; its monsters never spawn before
    # that. Once it opens, the first and second zones each drop to
    # 1 initial monster (the other species still respawns after a
    # kill), keeping the initial total at or below MAX_UNITS.
    # Fourth zone (southeast, the Morning Dew Grove) opens only
    # after the third-zone quest is done; once it opens, the third
    # zone drops to 2 initial monsters (the other two species still
    # respawn after a kill), keeping the initial total at 12.
    var placements: Array = []
    placements.append({"id": "slime", "pos": Vector2(1000.0, 500.0)})
    if not elite_defeated:
        placements.append({"id": "wolf", "pos": Vector2(900.0, 820.0)})
    # Second zone (north, the Moss Crown Clearing) opens only after
    # the main boss is defeated; its monsters never spawn before that.
    if boss_defeated:
        placements.append({"id": "thorn_vine", "pos": Vector2(420.0, 200.0)})
        if not elite_defeated:
            placements.append({"id": "forest_wasp", "pos": Vector2(760.0, 150.0)})
    if elite_defeated:
        placements.append({"id": "valley_firefly", "pos": Vector2(200.0, 980.0)})
        placements.append({"id": "withered_puppet", "pos": Vector2(480.0, 1020.0)})
        if not valley_quest_done:
            placements.append({"id": "stream_spirit", "pos": Vector2(620.0, 940.0)})
            placements.append({"id": "valley_mushroom", "pos": Vector2(300.0, 1100.0)})
        # Species dropped from the initial plan above (wolf, wasp)
        # re-enter through the ordinary respawn queue: after the
        # 8 s timer they spawn whenever a unit slot is free, so
        # their kill quests remain completable after the elite kill.
        respawn_queue.append({"id": "wolf", "pos": Vector2(900.0, 820.0), "timer": RESPAWN_DELAY})
        respawn_queue.append({"id": "forest_wasp", "pos": Vector2(760.0, 150.0), "timer": RESPAWN_DELAY})
    if valley_quest_done:
        placements.append({"id": "dawn_deer", "pos": Vector2(1100.0, 1000.0)})
        placements.append({"id": "hill_rock", "pos": Vector2(1400.0, 1080.0)})
        # Third-zone species dropped from the initial plan above
        # (stream spirit, valley mushroom) re-enter through the
        # ordinary respawn queue, same pattern as wolf and wasp.
        respawn_queue.append({"id": "stream_spirit", "pos": Vector2(620.0, 940.0), "timer": RESPAWN_DELAY})
        respawn_queue.append({"id": "valley_mushroom", "pos": Vector2(300.0, 1100.0), "timer": RESPAWN_DELAY})
    for placement in placements:
        if not _spawn_enemy_at(str(placement["id"]), placement["pos"]):
            return
    if not boss_defeated:
        var boss_data = data_loader.get_enemy(data_loader.boss_id)
        if boss_data == null:
            config_failed = true
            error_label.text = "配置错误，无法启动：" + data_loader.error_message
            push_error(data_loader.error_message)
            return
        boss = BOSS_SCENE.instantiate()
        boss.setup(boss_data)
        boss.global_position = world_map_manager.enemy_spawn_position(data_loader.boss_id)
        boss.spawn_position = boss.global_position
        boss.set_meta("world_map_id", world_map_manager.map_for_enemy(data_loader.boss_id))
        enemies_root.add_child(boss)
        boss.add_to_group("enemies")
        boss.died.connect(_on_enemy_died)
        enemies.append(boss)
    elif not elite_defeated:
        var elite_data = data_loader.get_enemy(data_loader.elite_boss_id)
        if elite_data == null:
            config_failed = true
            error_label.text = "配置错误，无法启动：" + data_loader.error_message
            push_error(data_loader.error_message)
            return
        elite_boss = BOSS_SCENE.instantiate()
        elite_boss.setup(elite_data)
        elite_boss.global_position = world_map_manager.enemy_spawn_position(data_loader.elite_boss_id)
        elite_boss.spawn_position = elite_boss.global_position
        elite_boss.set_meta("world_map_id", world_map_manager.map_for_enemy(data_loader.elite_boss_id))
        enemies_root.add_child(elite_boss)
        elite_boss.add_to_group("enemies")
        elite_boss.died.connect(_on_enemy_died)
        enemies.append(elite_boss)

func _spawn_campfire() -> void:
    # Framework campfire only: it unlocks a future area flag and
    # never gates any existing zone. Existing zones keep their
    # boss / quest gates exactly as before, so an old save that
    # already opened them stays open whether or not this campfire
    # is ever visited. If campfires.json ever gains more entries,
    # each gets its own node the same way.
    if camp_manager == null or camp_manager.campfire_order.is_empty():
        return
    var entry = camp_manager.campfire(camp_manager.campfire_order[0])
    if entry == null:
        return
    var pos = entry["position"]
    campfire_node = CAMPFIRE_SCENE.instantiate()
    campfire_node.global_position = Vector2(float(pos["x"]), float(pos["y"]))
    add_child(campfire_node)

func _tick_respawns(delta: float) -> void:
    if respawn_queue.is_empty():
        return
    var ready: Array = []
    for entry in respawn_queue:
        entry["timer"] = float(entry["timer"]) - delta
        if float(entry["timer"]) <= 0.0 and world_map_manager.map_for_enemy(str(entry["id"])) == active_map_id:
            ready.append(entry)
    for entry in ready:
        if heroes.size() + enemies.size() >= MAX_UNITS:
            continue
        respawn_queue.erase(entry)
        _spawn_enemy_at(str(entry["id"]), entry["pos"])


func _serialize_map_positions() -> Dictionary:
    var serialized: Dictionary = {}
    for map_id in map_positions:
        var position: Vector2 = map_positions[map_id]
        serialized[str(map_id)] = {"x": position.x, "y": position.y}
    if captain != null:
        serialized[active_map_id] = {"x": captain.global_position.x, "y": captain.global_position.y}
    return serialized


func _on_map_pressed() -> void:
    _show_map_panel()

func _show_map_panel() -> void:
    var order: Array = [WorldMapManagerScript.TOWN, WorldMapManagerScript.MOSS_CROWN, WorldMapManagerScript.FALLEN_LEAF, WorldMapManagerScript.MORNING_DEW]
    var entries: Array = []
    for map_id in order:
        entries.append({
            "id": str(map_id),
            "name": world_map_manager.map_name(str(map_id)),
            "safe": world_map_manager.is_safe_map(str(map_id)),
            "unlocked": world_map_manager.is_unlocked(str(map_id), boss_defeated, elite_defeated, valley_quest_done),
        })
    map_panel.set_maps(entries, active_map_id)
    _toggle_menu_panel(map_panel)

func _on_map_panel_selected(map_index: int) -> void:
    map_panel.visible = false
    _on_map_selected(map_index)


func _on_map_selected(map_index: int) -> void:
    var target_map_id: String = WorldMapManagerScript.MOSS_CROWN
    match map_index:
        0: target_map_id = WorldMapManagerScript.TOWN
        1: target_map_id = WorldMapManagerScript.MOSS_CROWN
        2: target_map_id = WorldMapManagerScript.FALLEN_LEAF
        3: target_map_id = WorldMapManagerScript.MORNING_DEW
    if not world_map_manager.is_unlocked(target_map_id, boss_defeated, elite_defeated, valley_quest_done):
        hud.show_message("该地图尚未解锁，先完成对应首领与任务")
        return
    _switch_map(target_map_id)


func _apply_active_map_visibility() -> void:
    for enemy in enemies:
        if not is_instance_valid(enemy):
            continue
        var belongs: bool = str(enemy.get_meta("world_map_id", WorldMapManagerScript.MOSS_CROWN)) == active_map_id
        enemy.visible = belongs
        enemy.process_mode = Node.PROCESS_MODE_INHERIT if belongs else Node.PROCESS_MODE_DISABLED
        if enemy is CollisionObject2D:
            enemy.set_deferred("collision_layer", 1 if belongs else 0)
            enemy.set_deferred("collision_mask", 1 if belongs else 0)
    if chest_node != null:
        chest_node.visible = active_map_id == WorldMapManagerScript.MOSS_CROWN
    if campfire_node != null:
        campfire_node.visible = active_map_id == WorldMapManagerScript.MOSS_CROWN


func _switch_map(target_map_id: String) -> void:
    if target_map_id == active_map_id or not world_map_manager.is_known_map(target_map_id) or captain == null:
        return
    if not world_map_manager.is_unlocked(target_map_id, boss_defeated, elite_defeated, valley_quest_done):
        hud.show_message("该地图尚未解锁")
        return
    map_positions[active_map_id] = captain.global_position
    for hero in heroes:
        hero.move_input = Vector2.ZERO
        hero.velocity = Vector2.ZERO
    active_map_id = target_map_id
    $Map.set_active_map(active_map_id)
    var target_position: Vector2 = map_positions.get(active_map_id, world_map_manager.spawn_position(active_map_id))
    target_position = WorldMapManagerScript.clamp_position(target_position)
    for hero in heroes:
        hero.world_map_id = active_map_id
        hero.global_position = WorldMapManagerScript.clamp_position(target_position + hero.formation_offset)
    _apply_active_map_visibility()
    camera.position = _projected_camera_position(captain.global_position)
    hud.show_message("已进入：" + world_map_manager.map_name(active_map_id))
    _save_game()


func _projected_camera_position(logical_position: Vector2) -> Vector2:
    var bounds: Rect2 = WorldProjectionScript.projected_bounds()
    var visible_size: Vector2 = get_viewport_rect().size / camera.zoom
    var min_x: float = bounds.position.x + visible_size.x * 0.5
    var max_x: float = bounds.end.x - visible_size.x * 0.5
    var center_x: float = (bounds.position.x + bounds.end.x) * 0.5
    var projected: Vector2 = WorldProjectionScript.world_to_screen(logical_position)
    var camera_x: float = center_x if min_x > max_x else clampf(projected.x, min_x, max_x)
    var min_y: float = bounds.position.y + visible_size.y * 0.5
    var max_y: float = bounds.end.y - visible_size.y * 0.5
    var camera_y: float = (bounds.position.y + bounds.end.y) * 0.5 if min_y > max_y else clampf(projected.y, min_y, max_y)
    return Vector2(camera_x, camera_y)


func _set_world_depth_order(unit: Node2D) -> void:
    var depth_index: int = clampi(int(WorldProjectionScript.screen_depth(unit.global_position) / 4.0), 0, 1024)
    if unit.z_index != depth_index:
        unit.z_index = depth_index


func _update_world_visuals() -> void:
    for unit in heroes:
        if is_instance_valid(unit):
            _set_world_depth_order(unit)
            if unit.velocity.length_squared() > 0.01:
                unit.queue_redraw()
    for unit in enemies:
        if is_instance_valid(unit) and unit.visible:
            _set_world_depth_order(unit)
    if chest_node != null and is_instance_valid(chest_node) and chest_node.visible:
        _set_world_depth_order(chest_node)
    if campfire_node != null and is_instance_valid(campfire_node) and campfire_node.visible:
        _set_world_depth_order(campfire_node)

func _process(delta: float) -> void:
    if config_failed or captain == null:
        return
    _update_world_visuals()
    camera.position = _projected_camera_position(captain.global_position)
    hud.set_skill_cooldown(captain.skill_cooldown_remaining, captain.skill_ready)
    var in_combat: bool = false
    for enemy in enemies:
        if enemy == null or not is_instance_valid(enemy):
            continue
        if bool(enemy.get("dead")):
            continue
        if str(enemy.get_meta("world_map_id", WorldMapManagerScript.MOSS_CROWN)) != active_map_id:
            continue
        if captain.global_position.distance_to(enemy.global_position) <= 140.0:
            in_combat = true
            break
    hud.set_combat_mode(in_combat)
    var boss_fight_name: String = ""
    for boss_node in [boss, elite_boss]:
        if boss_node == null or not is_instance_valid(boss_node):
            continue
        if bool(boss_node.get("dead")):
            continue
        if boss_node.target_hero != null and not bool(boss_node.target_hero.get("dead")):
            boss_fight_name = str(boss_node.enemy_name)
            break
    hud.set_boss_banner(boss_fight_name != "", boss_fight_name)
    var screen_input: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    if joystick.vector.length() > 0.1:
        screen_input = joystick.vector
    var world_input := Vector2(screen_input.x + 2.0 * screen_input.y, -screen_input.x + 2.0 * screen_input.y)
    captain.move_input = world_input.normalized()
    _tick_respawns(delta)

func _unhandled_input(event: InputEvent) -> void:
    if config_failed:
        return
    if event is InputEventKey and event.pressed and not event.echo:
        if event.keycode == KEY_SPACE:
            _on_skill_pressed()
        elif event.keycode == KEY_E:
            _on_interact_pressed()
        elif event.keycode == KEY_S:
            _on_save_pressed()
        elif event.keycode == KEY_H:
            _on_hero_panel_pressed()
        elif event.keycode == KEY_Q:
            _on_equip_panel_pressed()
        elif event.keycode == KEY_C:
            _on_camp_panel_pressed()
        elif event.keycode == KEY_B:
            _on_backpack_panel_pressed()
        elif event.keycode == KEY_R:
            _on_recruit_panel_pressed()

func _on_skill_pressed() -> void:
    if captain == null:
        return
    var hit_positions: Array[Vector2] = []
    for enemy in get_tree().get_nodes_in_group("enemies"):
        if enemy == null or bool(enemy.get("dead")):
            continue
        if str(enemy.get_meta("world_map_id", WorldMapManagerScript.MOSS_CROWN)) != active_map_id:
            continue
        if captain.global_position.distance_to(enemy.global_position) <= 140.0:
            hit_positions.append(enemy.global_position)
    if captain.use_skill():
        # Atlas entries are standalone illustrations, not animation frames.
        EFFECT_PLAYER.play(self, EFFECT_ATLAS, captain.global_position, Rect2(900.0, 175.0, 180.0, 170.0), Vector2(220.0, 210.0), 0.48, randf_range(-0.12, 0.12))
        for hit_position in hit_positions:
            EFFECT_PLAYER.play(self, EFFECT_ATLAS, hit_position, Rect2(905.0, 335.0, 165.0, 120.0), Vector2(92.0, 76.0), 0.34, randf_range(-0.2, 0.2))
        hud.show_message("释放技能！")
    else:
        hud.show_message("技能冷却中")

func _on_interact_pressed() -> void:
    if captain == null:
        return
    if campfire_node != null and campfire_node.visible and camp_manager != null and not camp_manager.campfire_order.is_empty():
        var entry = camp_manager.campfire(camp_manager.campfire_order[0])
        if entry != null and captain.global_position.distance_to(campfire_node.global_position) < 80.0:
            _on_campfire_interact(entry)
            return
    if chest_node == null or not chest_node.visible:
        return
    if captain.global_position.distance_to(chest_node.global_position) < 80.0:
        var gained: int = chest_node.try_open()
        if gained == 0 and chest_node.is_open:
            hud.show_message("宝箱已经开过了")

func _on_campfire_interact(entry: Dictionary) -> void:
    var campfire_id: String = str(entry["id"])
    if camp_manager.is_campfire_unlocked(campfire_id):
        hud.show_message(str(entry["teleport_intro"]))
        _open_teleport_panel()
        return
    var cost: int = int(entry["cost_wood"])
    if wood < cost:
        hud.show_message(str(entry["fog_prompt"]) + " " + str(entry["insufficient_prompt"]) + "（需要 " + str(cost) + " 木材，当前 " + str(wood) + "）")
        return
    wood -= cost
    camp_manager.unlock_campfire(campfire_id)
    hud.set_wood(wood, wood_cap)
    hud.set_teleport_available(true)
    hud.show_message(str(entry["dispel_prompt"]))
    _save_game()
    _open_teleport_panel()

# Only one full-screen menu/settlement panel may be visible at a time.
# Tapping the active menu button closes it; tapping another switches panels.

func _has_unlocked_campfire() -> bool:
    if camp_manager == null:
        return false
    for campfire_id in camp_manager.campfire_order:
        if camp_manager.is_campfire_unlocked(str(campfire_id)):
            return true
    return false

func _ensure_teleport_panel() -> void:
    if teleport_panel != null:
        return
    teleport_panel = PanelContainer.new()
    teleport_panel.name = "TeleportPanel"
    teleport_panel.set_anchors_preset(Control.PRESET_CENTER)
    teleport_panel.offset_left = -190.0
    teleport_panel.offset_top = -220.0
    teleport_panel.offset_right = 190.0
    teleport_panel.offset_bottom = 220.0
    teleport_panel.z_index = 100
    teleport_panel.visible = false
    $UI.add_child(teleport_panel)
    var layout := VBoxContainer.new()
    layout.add_theme_constant_override("separation", 12)
    teleport_panel.add_child(layout)
    var title := Label.new()
    title.text = "营火传送"
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    layout.add_child(title)
    var note := Label.new()
    note.text = "可在已解锁的独立地图之间传送"
    note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    layout.add_child(note)
    teleport_list = VBoxContainer.new()
    layout.add_child(teleport_list)
    _refresh_teleport_destinations()
    var close_button := Button.new()
    close_button.text = "关闭"
    close_button.pressed.connect(_close_teleport_panel)
    layout.add_child(close_button)

func _refresh_teleport_destinations() -> void:
    if teleport_list == null:
        return
    for child in teleport_list.get_children():
        teleport_list.remove_child(child)
        child.queue_free()
    _add_teleport_destination("forest_entry", "森林入口", true, "冒险起点")
    _add_teleport_destination("campfire", "营火据点", campfire_node != null, "已激活的营火")
    _add_teleport_destination("moss_crown", "苔冠空地", true, "已开放")
    _add_teleport_destination("fallen_leaf", "落叶幽谷", elite_defeated, "击败精英首领后开放")
    _add_teleport_destination("morning_dew", "朝露林地", valley_quest_done, "完成落叶幽谷主线后开放")

func _add_teleport_destination(destination_id: String, label: String, available: bool, hint: String) -> void:
    var button := Button.new()
    button.text = label + ("  ·  " + hint if available else "  ·  未开放（" + hint + "）")
    button.custom_minimum_size = Vector2(0.0, 48.0)
    button.disabled = not available
    button.pressed.connect(_on_teleport_destination_pressed.bind(destination_id))
    teleport_list.add_child(button)

func _on_teleport_pressed() -> void:
    if not _has_unlocked_campfire():
        hud.show_message("先在森林营火处花费木材解锁传送")
        return
    if teleport_panel == null:
        _ensure_teleport_panel()
    _open_teleport_panel()

func _open_teleport_panel() -> void:
    if not _has_unlocked_campfire():
        return
    if teleport_panel == null:
        _ensure_teleport_panel()
    _refresh_teleport_destinations()
    var panels: Array[Control] = [hero_panel, equip_panel, camp_panel, backpack_panel, recruit_panel, offline_panel, quest_panel, map_panel]
    for panel in panels:
        panel.visible = false
    teleport_panel.visible = true

func _close_teleport_panel() -> void:
    if teleport_panel != null:
        teleport_panel.visible = false

func _on_teleport_destination_pressed(destination_id: String) -> void:
    if captain == null or not _has_unlocked_campfire():
        _close_teleport_panel()
        return
    var target_map_id: String = WorldMapManagerScript.MOSS_CROWN
    var destination: Vector2 = world_map_manager.spawn_position(target_map_id)
    var destination_name: String = ""
    match destination_id:
        "forest_entry":
            destination_name = "森林入口"
        "campfire":
            if campfire_node == null:
                hud.show_message("传送失败：营火据点不可用")
                return
            destination = campfire_node.global_position + Vector2(0.0, 96.0)
            destination_name = "营火据点"
        "moss_crown":
            destination_name = "苔冠空地"
        "fallen_leaf":
            target_map_id = WorldMapManagerScript.FALLEN_LEAF
            if not world_map_manager.is_unlocked(target_map_id, boss_defeated, elite_defeated, valley_quest_done):
                hud.show_message("击败精英首领后才能前往落叶幽谷")
                return
            destination = world_map_manager.spawn_position(target_map_id)
            destination_name = "落叶幽谷"
        "morning_dew":
            target_map_id = WorldMapManagerScript.MORNING_DEW
            if not world_map_manager.is_unlocked(target_map_id, boss_defeated, elite_defeated, valley_quest_done):
                hud.show_message("完成落叶幽谷主线后才能前往朝露林地")
                return
            destination = world_map_manager.spawn_position(target_map_id)
            destination_name = "朝露林地"
        _:
            hud.show_message("传送失败：未知目的地")
            return
    if target_map_id != active_map_id:
        _switch_map(target_map_id)
    for hero in heroes:
        if hero == null or not is_instance_valid(hero):
            continue
        hero.move_input = Vector2.ZERO
        hero.velocity = Vector2.ZERO
        hero.world_map_id = active_map_id
        hero.global_position = WorldMapManagerScript.clamp_position(destination + hero.formation_offset)
    camera.position = _projected_camera_position(captain.global_position)
    _close_teleport_panel()
    hud.show_message("已传送至 " + destination_name)
    _save_game()

func _toggle_menu_panel(target: Control) -> void:
    var should_open: bool = not target.visible
    var panels: Array[Control] = [hero_panel, equip_panel, camp_panel, backpack_panel, recruit_panel, offline_panel, quest_panel, map_panel]
    if teleport_panel != null:
        panels.append(teleport_panel)
    for panel in panels:
        panel.visible = false
    target.visible = should_open

func _on_backpack_panel_pressed() -> void:
    _toggle_menu_panel(backpack_panel)
    if backpack_panel.visible:
        backpack_panel.refresh()

func _on_backpack_equip(index: int, hero_id: String) -> void:
    if backpack_manager == null or equipment_manager == null or index < 0 or index >= backpack_manager.backpack.size():
        hud.show_message("穿戴失败：未知散件")
        return
    if recruitment_manager == null or not recruitment_manager.is_recruited(hero_id):
        hud.show_message("穿戴失败：英雄未拥有")
        return
    var item_id: String = str(backpack_manager.backpack[index])
    var entry = backpack_manager.item(item_id)
    if entry == null:
        hud.show_message("穿戴失败：装备数据不存在")
        return
    var result: Dictionary = equipment_manager.equip_loose_item(hero_id, item_id, backpack_manager.items)
    if not bool(result.get("ok", false)):
        hud.show_message("穿戴失败：该散件没有对应装备槽")
        return
    backpack_manager.remove_at(index)
    var replaced: String = str(result.get("replaced", ""))
    if replaced != "":
        backpack_manager.add(replaced)
    for hero in heroes:
        if hero != null and hero.hero_id == hero_id:
            _rebuild_hero_stats(hero, true)
            break
    backpack_panel.refresh()
    equip_panel.refresh()
    if hero_panel.visible:
        hero_panel.refresh()
    hud.show_message("已为 " + str(entry["name"]) + " 穿戴 " + str(hero_id))
    _save_game()

func _on_backpack_decompose(index: int) -> void:
    if backpack_manager == null or index < 0 or index >= backpack_manager.backpack.size():
        hud.show_message("分解失败：未知散件")
        return
    var item_id: String = str(backpack_manager.backpack[index])
    var entry = backpack_manager.item(item_id)
    if entry == null or not backpack_manager.remove_at(index):
        hud.show_message("分解失败：未知散件")
        return
    gold += backpack_manager.decompose_gold
    hud.set_gold(gold)
    backpack_panel.refresh()
    hud.show_message("分解 " + str(entry["name"]) + "，获得金币 +" + str(backpack_manager.decompose_gold))
    _save_game()

func _on_backpack_claim(index: int) -> void:
    if backpack_manager == null or index < 0 or index >= backpack_manager.mailbox.size():
        hud.show_message("领取失败：未知邮件")
        return
    if backpack_manager.is_full():
        hud.show_message("背包已满，先分解一件再领取")
        return
    var item_id: String = str(backpack_manager.mailbox[index])
    var entry = backpack_manager.item(item_id)
    if entry == null or not backpack_manager.claim_at(index):
        hud.show_message("领取失败：未知邮件")
        return
    backpack_panel.refresh()
    hud.show_message("已从邮箱领取 " + str(entry["name"]))
    _save_game()

func _on_camp_panel_pressed() -> void:
    _toggle_menu_panel(camp_panel)
    if camp_panel.visible:
        camp_panel.refresh()

func _on_camp_hero_panel_pressed() -> void:
    camp_panel.visible = false
    _on_hero_panel_pressed()

func _rebuild_hero_stats(hero: Hero, preserve_hp_ratio: bool = true) -> void:
    if hero == null:
        return
    var hp_ratio: float = float(hero.hp) / float(hero.max_hp) if hero.max_hp > 0 else 1.0
    hero.reset_to_base_stats()
    hero.apply_equipment_bonus(equipment_manager.bonus_for_hero(hero.hero_id))
    var camp_attack_pct: float = 5.0 if camp_manager.is_built("blacksmith") else 0.0
    var camp_hp_pct: float = 8.0 if camp_manager.is_built("training_ground") else 0.0
    hero.apply_camp_bonus(camp_attack_pct, camp_hp_pct)
    hero.apply_loose_equipment_bonus(equipment_manager.loose_bonus_for_hero(hero.hero_id, backpack_manager.items))
    if preserve_hp_ratio:
        hero.hp = clampi(int(round(hp_ratio * float(hero.max_hp))), 1, hero.max_hp)
    hero.queue_redraw()

func _refresh_party_camp_bonuses() -> void:
    for hero in heroes:
        _rebuild_hero_stats(hero, true)
    if hero_panel.visible:
        hero_panel.refresh()
    equip_panel.refresh()

func _on_camp_build(building_id: String) -> void:
    var entry = camp_manager.building(building_id)
    if entry == null:
        hud.show_message("建造失败：未知建筑")
        return
    if camp_manager.is_built(building_id):
        hud.show_message("该建筑已建成")
        return
    var cost: int = int(entry["cost_wood"])
    if wood < cost:
        hud.show_message("木材不足，需要 " + str(cost) + " 木材，当前 " + str(wood))
        return
    wood -= cost
    camp_manager.build(building_id)
    _refresh_party_camp_bonuses()
    hud.set_wood(wood, wood_cap)
    camp_panel.refresh()
    hud.show_message(str(entry["built_message"]))
    _save_game()

func _on_save_pressed() -> void:
    _save_game()
    hud.show_message("已手动保存")


func _on_formation_leader_requested(hero_id: String) -> void:
    if formation_manager == null or not formation_manager.set_leader(hero_id):
        hud.show_message("无法更换队长")
        return
    _rebuild_party_runtime()
    hud.show_message("队长已更换")

func _on_formation_add_requested(hero_id: String) -> void:
    if formation_manager == null or not formation_manager.add_to_party(hero_id):
        hud.show_message("无法上阵：队伍已满或英雄未拥有")
        return
    _rebuild_party_runtime()
    hud.show_message("英雄已上阵")

func _on_formation_remove_requested(hero_id: String) -> void:
    if formation_manager == null or not formation_manager.remove_from_party(hero_id):
        hud.show_message("至少保留一名出战英雄")
        return
    _rebuild_party_runtime()
    hud.show_message("英雄已下阵")

func _rebuild_party_runtime() -> void:
    if formation_manager == null:
        return
    var saved_position: Vector2 = captain.global_position if captain != null else world_map_manager.spawn_position(active_map_id)
    map_positions[active_map_id] = saved_position
    for hero in heroes:
        if hero != null and is_instance_valid(hero):
            hero_hp_cache[hero.hero_id] = hero.hp
            hero.remove_from_group("heroes")
            heroes_root.remove_child(hero)
            hero.queue_free()
    heroes.clear()
    captain = null
    var saved_hero_states: Array = []
    for cached_hero_id in hero_hp_cache.keys():
        saved_hero_states.append({"id": str(cached_hero_id), "hp": int(hero_hp_cache[cached_hero_id])})
    var runtime_save: Dictionary = {
        "map_id": active_map_id,
        "player_position": {"x": saved_position.x, "y": saved_position.y},
        "heroes": saved_hero_states
    }
    _spawn_heroes(runtime_save)
    if captain != null:
        camera.position = _projected_camera_position(captain.global_position)
    hero_panel.set_heroes(heroes)
    hero_panel.set_formation_data(formation_manager, data_loader.heroes, level_manager)
    equip_panel.set_data(heroes, equipment_manager)
    backpack_panel.set_manager(backpack_manager, heroes)
    _save_game()

func _on_town_building_pressed(building_id: String) -> void:
    if active_map_id != WorldMapManagerScript.TOWN:
        return
    match building_id:
        "recruit":
            _on_recruit_panel_pressed()
            hud.show_message("已进入英雄招募所")
        "camp":
            _on_camp_panel_pressed()
            hud.show_message("已进入营地工坊")
        "equipment":
            _on_equip_panel_pressed()
            hud.show_message("已进入装备工坊")
        "backpack":
            _on_backpack_panel_pressed()
            hud.show_message("已打开仓库")
        _:
            return

func _on_hero_panel_pressed() -> void:
    _toggle_menu_panel(hero_panel)
    if hero_panel.visible:
        hero_panel.refresh()

func _on_equip_panel_pressed() -> void:
    _toggle_menu_panel(equip_panel)
    if equip_panel.visible:
        equip_panel.refresh()

func _refresh_quest_label() -> void:
    hud.refresh_quest_panel()

func _refresh_top_bar() -> void:
    if hud == null or captain == null or formation_manager == null:
        return
    var total: int = 0
    for hero_id in formation_manager.active_ids:
        total += hero_panel._power_for_hero(hero_id)
    hud.set_power(total)
    if level_manager != null:
        hud.set_avatar_level(level_manager.level(captain.hero_id))

func _on_quest_panel_pressed() -> void:
    var panels: Array[Control] = [hero_panel, equip_panel, camp_panel, backpack_panel, recruit_panel, offline_panel, quest_panel, map_panel]
    if teleport_panel != null:
        panels.append(teleport_panel)
    for panel in panels:
        panel.visible = false
    hud.toggle_quest_panel()

func _on_offline_panel_pressed() -> void:
    if offline_panel.scroll == null:
        hud.show_message("暂无离线结算可查看")
        return
    _toggle_menu_panel(offline_panel)

func _on_recruit_panel_pressed() -> void:
    _toggle_menu_panel(recruit_panel)
    if recruit_panel.visible:
        recruit_panel.refresh()

func _on_recruit_synthesize(hero_id: String) -> void:
    var entry = recruitment_manager.entry(hero_id)
    if entry == null or str(entry["unlock_type"]) != "fragments":
        hud.show_message("合成失败：未知英雄")
        return
    if recruitment_manager.is_recruited(hero_id):
        hud.show_message("该英雄已加入")
        return
    if not recruitment_manager.synthesize_with_fragments(hero_id):
        hud.show_message("合成失败：碎片不足或英雄状态已变化")
        return
    var hero_name: String = ""
    for hero_data in data_loader.heroes:
        if str(hero_data["id"]) == hero_id:
            hero_name = str(hero_data["name"])
            break
    var deployed: bool = formation_manager.add_to_party(hero_id)
    if deployed:
        _spawn_recruited_hero(hero_id)
    recruit_panel.refresh()
    hero_panel.set_formation_data(formation_manager, data_loader.heroes, level_manager)
    equip_panel.set_roster(formation_manager.owned_ids, data_loader.heroes, equipment_manager, heroes)
    backpack_panel.set_hero_roster(formation_manager.owned_ids, data_loader.heroes)
    if deployed:
        hud.show_message("新英雄加入并上阵：" + hero_name + "！")
    else:
        hud.show_message("新英雄加入收藏：" + hero_name + "；队伍已满，可在英雄编队中更换队长")
    _refresh_top_bar()
    _save_game()

func _on_quest_completed(quest_id: String, quest_name: String, complete_line: String, reward_gold: int) -> void:
    _refresh_quest_label()
    if reward_gold > 0:
        gold += reward_gold
        hud.set_gold(gold)
        hud.show_message("任务完成：" + quest_name + " " + complete_line + " 获得金币 +" + str(reward_gold))
    else:
        hud.show_message("任务完成：" + quest_name + " " + complete_line)
    # Quest-unlocked heroes join immediately, before the save below,
    # so the saved party already includes them. A quest already
    # completed in an old save never re-fires, and old saves were
    # migrated to the full roster anyway, so this cannot double-add.
    var unlock_hero_id: String = recruitment_manager.hero_id_for_quest(quest_id)
    if unlock_hero_id != "" and recruitment_manager.recruit(unlock_hero_id):
        var hero_name: String = ""
        for hero_data in data_loader.heroes:
            if str(hero_data["id"]) == unlock_hero_id:
                hero_name = str(hero_data["name"])
                break
        _spawn_recruited_hero(unlock_hero_id)
        recruit_panel.refresh()
        if hero_panel.visible:
            hero_panel.refresh()
        hud.show_message("新英雄加入：" + hero_name + "！")
    _save_game()

func _on_loose_unequip(hero_id: String, slot: String) -> void:
    if equipment_manager == null or backpack_manager == null:
        return
    var item_id: String = equipment_manager.unequip_loose_item(hero_id, slot)
    if item_id == "":
        return
    var destination: String = backpack_manager.add(item_id)
    for hero in heroes:
        if hero != null and hero.hero_id == hero_id:
            _rebuild_hero_stats(hero, true)
            break
    equip_panel.refresh()
    backpack_panel.refresh()
    if hero_panel.visible:
        hero_panel.refresh()
    hud.show_message("已卸下装备" + ("，背包已满，已寄到邮箱" if destination == "mailbox" else ""))
    _save_game()

func _on_equip_swap(hero_id: String, set_id: String) -> void:
    if equipment_manager == null or not equipment_manager.equip_set_for_hero(hero_id, set_id):
        hud.show_message("换装失败：未知套装")
        return
    for hero in heroes:
        if hero.hero_id != hero_id:
            continue
        var hp_ratio: float = float(hero.hp) / float(hero.max_hp) if hero.max_hp > 0 else 1.0
        _rebuild_hero_stats(hero, true)
        hero.hp = maxi(1, int(round(hp_ratio * float(hero.max_hp))))
        hero.queue_redraw()
    if hero_panel.visible:
        hero_panel.refresh()
    equip_panel.refresh()
    hud.show_message("已换装：" + equipment_manager.set_name(set_id))
    _save_game()

func _save_game() -> void:
    if captain == null:
        return
    var hero_states: Array = []
    for hero in heroes:
        hero_hp_cache[hero.hero_id] = hero.hp
    for hero_id_value in recruitment_manager.entry_order:
        var saved_hero_id: String = str(hero_id_value)
        if recruitment_manager.is_recruited(saved_hero_id) and hero_hp_cache.has(saved_hero_id):
            hero_states.append({"id": saved_hero_id, "hp": int(hero_hp_cache[saved_hero_id])})
    var data: Dictionary = {
        "gold": gold,
        "wood": wood,
        "last_saved_unix": int(Time.get_unix_time_from_system()),
        "backpack": backpack_manager.save_data(),
        "camp": camp_manager.save_camp(),
        "chest_opened": chest_opened,
        "boss_defeated": boss_defeated,
        "elite_defeated": elite_defeated,
        "map_id": active_map_id,
        "map_positions": _serialize_map_positions(),
        "player_position": {"x": captain.global_position.x, "y": captain.global_position.y},
        "heroes": hero_states,
        "recruitment": recruitment_manager.save_data(),
        "formation": formation_manager.save_data(),
        "levels": level_manager.save_data(),
        "quests": quest_manager.save_progress(),
        "equipment": equipment_manager.save_equipped(),
        "loose_equipment": equipment_manager.save_loose_equipped(),
    }
    if not save_manager.save_game(data):
        hud.show_message("保存失败")

func _on_chest_opened(amount: int) -> void:
    gold += amount
    chest_opened = true
    hud.set_gold(gold)
    hud.show_message("获得金币 +" + str(amount))
    quest_manager.on_chest_opened()
    _refresh_quest_label()
    _save_game()

func _on_enemy_died(enemy) -> void:
    enemies.erase(enemy)
    if enemy == boss:
        boss_defeated = true
        gold += boss.reward_gold
        hud.set_gold(gold)
        hud.show_message("击败 BOSS，获得金币 +" + str(boss.reward_gold))
        _grant_party_xp(level_manager.xp_per_boss)
        quest_manager.on_enemy_killed(str(enemy.enemy_id), true)
        _refresh_quest_label()
        _save_game()
        return
    if enemy == elite_boss:
        elite_defeated = true
        gold += elite_boss.reward_gold
        hud.set_gold(gold)
        hud.show_message("击败精英 BOSS，获得金币 +" + str(elite_boss.reward_gold))
        _grant_party_xp(level_manager.xp_per_boss)
        quest_manager.on_enemy_killed(str(enemy.enemy_id), true)
        _refresh_quest_label()
        _save_game()
        return
    var enemy_id: String = str(enemy.get("enemy_id"))
    quest_manager.on_enemy_killed(enemy_id, false)
    _refresh_quest_label()
    var drop_parts: Array = []
    if randf() < gold_drop_chance:
        var dropped: int = randi_range(gold_drop_min, gold_drop_max)
        gold += dropped
        hud.set_gold(gold)
        drop_parts.append("金币 +" + str(dropped))
    if randf() < wood_drop_chance:
        var wood_dropped: int = randi_range(wood_drop_min, wood_drop_max)
        var room: int = wood_cap - wood
        wood_dropped = mini(wood_dropped, room)
        if wood_dropped > 0:
            wood += wood_dropped
            hud.set_wood(wood, wood_cap)
            drop_parts.append("木材 +" + str(wood_dropped))
    # Fragment drops stop once the fragment hero is recruited, so a
    # full roster never farms useless fragments.
    if recruitment_manager != null and not recruitment_manager.is_recruited("assassin") and randf() < recruitment_manager.fragment_drop_chance:
        var fragment_count: int = recruitment_manager.add_fragment()
        drop_parts.append("砾影碎片 +1（" + str(fragment_count) + "/" + str(recruitment_manager.fragments_required("assassin")) + "）")
    if backpack_manager != null and randf() < backpack_manager.drop_chance:
        var loose_count: int = randi_range(backpack_manager.drop_min, backpack_manager.drop_max)
        for _i in range(loose_count):
            var loose_id: String = str(backpack_manager.item_order[randi() % backpack_manager.item_order.size()])
            var dest: String = backpack_manager.add(loose_id)
            var loose_entry = backpack_manager.item(loose_id)
            if dest == "backpack":
                drop_parts.append("散件 " + str(loose_entry["name"]))
            elif dest == "mailbox":
                drop_parts.append("散件 " + str(loose_entry["name"]) + "（背包已满，已寄到邮箱）")
    if not drop_parts.is_empty():
        var drop_text: String = ""
        for part in drop_parts:
            if drop_text != "":
                drop_text += "、"
            drop_text += str(part)
        hud.show_message("击败 " + str(enemy.get("enemy_name")) + "，获得" + drop_text)
    # Experience is granted after the drop message so a level-up
    # message is not overwritten by the drop message.
    _grant_party_xp(level_manager.xp_per_kill)
    # Ordinary monsters respawn at their spawn point after a delay,
    # so kill quests stay completable inside one run. Bosses never do.
    var spawn_pos: Vector2 = enemy.get_meta("spawn_pos", Vector2.ZERO) if enemy.has_meta("spawn_pos") else Vector2.ZERO
    respawn_queue.append({"id": enemy_id, "pos": spawn_pos, "map_id": world_map_manager.map_for_enemy(enemy_id), "timer": RESPAWN_DELAY})
    _save_game()

func _on_hero_died(hero) -> void:
    hud.show_message(str(hero.hero_name) + " 倒下了，3 秒后复活")
    var death_map_id: String = active_map_id
    var respawn_pos: Vector2 = world_map_manager.spawn_position(death_map_id)
    if hero != captain and captain != null:
        respawn_pos = captain.global_position + Vector2(0.0, 40.0)
    await get_tree().create_timer(3.0).timeout
    if hero != null and is_instance_valid(hero):
        # If the player changed maps during the death delay, respawn
        # with the party in the new map instead of using stale coordinates.
        if death_map_id != active_map_id:
            respawn_pos = world_map_manager.spawn_position(active_map_id) if hero == captain else captain.global_position + Vector2(0.0, 40.0)
        elif hero != captain and captain != null:
            respawn_pos = captain.global_position + Vector2(0.0, 40.0)
        hero.world_map_id = active_map_id
        hero.respawn(WorldMapManagerScript.clamp_position(respawn_pos))
        if hero_panel.visible:
            hero_panel.refresh()

func _on_hero_hp_changed(_hero) -> void:
    if hero_panel.visible:
        hero_panel.refresh()
