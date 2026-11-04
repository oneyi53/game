class_name HeroPanel
extends Control

const HeroPowerCalculator = preload("res://scripts/progression/hero_power_calculator.gd")

signal leader_requested(hero_id: String)
signal add_requested(hero_id: String)
signal remove_requested(hero_id: String)

@onready var panel_label: RichTextLabel = $PanelLabel
@onready var formation_list: VBoxContainer = $FormationScroll/FormationList

var heroes: Array = []
var formation_manager = null
var hero_definitions: Array = []
var level_manager = null
var equipment_manager = null
var camp_manager = null
var item_definitions: Dictionary = {}

func set_heroes(p_heroes: Array) -> void:
    heroes = p_heroes
    refresh()

func set_formation_data(p_formation_manager, p_hero_definitions: Array, p_level_manager, p_equipment_manager = null, p_camp_manager = null, p_item_definitions: Dictionary = {}) -> void:
    formation_manager = p_formation_manager
    hero_definitions = p_hero_definitions
    level_manager = p_level_manager
    equipment_manager = p_equipment_manager
    camp_manager = p_camp_manager
    item_definitions = p_item_definitions
    refresh()

func refresh() -> void:
    if panel_label == null:
        return
    var summary_lines: Array[String] = ["英雄编队"]
    if formation_manager != null and not formation_manager.active_ids.is_empty():
        var leader_name: String = _hero_name(str(formation_manager.active_ids[0]))
        var team_power: int = 0
        for active_id in formation_manager.active_ids:
            team_power += _power_for_hero(str(active_id))
        summary_lines[0] = "英雄编队  " + str(formation_manager.active_ids.size()) + "/" + str(formation_manager.max_party_size) + "    队长：" + leader_name + "    总战力：" + str(team_power)
    for hero in heroes:
        if hero == null:
            continue
        summary_lines.append(
            str(hero.hero_name) + "（" + str(hero.data.get("role", "")) + "）"
            + " Lv." + str(hero.level)
            + " HP " + str(hero.hp) + "/" + str(hero.max_hp)
            + " ATK " + str(hero.attack)
            + " DEF " + str(hero.defense)
            + " 战力 " + str(_power_for_hero(str(hero.hero_id)))
        )
    panel_label.text = "\n".join(summary_lines)
    if formation_list == null or formation_manager == null:
        return
    for child in formation_list.get_children():
        formation_list.remove_child(child)
        child.queue_free()
    for hero_id_value in formation_manager.owned_ids:
        var hero_id: String = str(hero_id_value)
        var active: bool = formation_manager.is_active(hero_id)
        var leader: bool = formation_manager.is_leader(hero_id)
        var row := HBoxContainer.new()
        row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        var info := Label.new()
        var state_text: String = "队长 · " if leader else ("出战 · " if active else "预备 · ")
        var hero_level: int = level_manager.level(hero_id) if level_manager != null else 1
        var stats: Dictionary = _stats_for_hero(hero_id)
        var role: String = str(_hero_definition(hero_id).get("role", ""))
        var stat_line: String = "攻击 " + str(stats.get("attack", 0)) + " 生命 " + str(stats.get("max_hp", 0)) + " 防御 " + str(stats.get("defense", 0))
        var combat_line: String = "暴击 " + str(int(round(float(stats.get("crit_chance", 0.0)) * 100.0))) + "% 攻速 +" + str(stats.get("attack_speed_pct", 0)) + "%"
        info.text = state_text + _hero_name(hero_id) + "（" + role + "） Lv." + str(hero_level) + "  战力 " + str(HeroPowerCalculator.power_from_stats(stats)) + "\n" + stat_line + "  " + combat_line
        info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        info.custom_minimum_size = Vector2(220, 52)
        info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        row.add_child(info)
        var leader_button := Button.new()
        leader_button.custom_minimum_size = Vector2(108, 48)
        if leader:
            leader_button.text = "当前队长"
            leader_button.disabled = true
        else:
            leader_button.text = "替换队长" if not active and formation_manager.active_ids.size() >= formation_manager.max_party_size else "设为队长"
            leader_button.pressed.connect(_emit_leader.bind(hero_id))
        row.add_child(leader_button)
        var party_button := Button.new()
        party_button.custom_minimum_size = Vector2(76, 48)
        if active:
            party_button.text = "下阵"
            party_button.disabled = formation_manager.active_ids.size() <= 1
            party_button.pressed.connect(_emit_remove.bind(hero_id))
        else:
            party_button.text = "上阵"
            party_button.disabled = formation_manager.active_ids.size() >= formation_manager.max_party_size
            party_button.pressed.connect(_emit_add.bind(hero_id))
        row.add_child(party_button)
        formation_list.add_child(row)


func _hero_definition(hero_id: String) -> Dictionary:
    for definition in hero_definitions:
        if str(definition.get("id", "")) == hero_id:
            return definition
    return {}

func _stats_for_hero(hero_id: String) -> Dictionary:
    var definition: Dictionary = _hero_definition(hero_id)
    if definition.is_empty():
        return {}
    var hero_level: int = level_manager.level(hero_id) if level_manager != null else 1
    var attack_growth: float = level_manager.attack_growth_pct_per_level if level_manager != null else 0.0
    var hp_growth: float = level_manager.hp_growth_pct_per_level if level_manager != null else 0.0
    var equipment_bonus: Dictionary = equipment_manager.bonus_for_hero(hero_id) if equipment_manager != null else {}
    var loose_bonus: Dictionary = equipment_manager.loose_bonus_for_hero(hero_id, item_definitions) if equipment_manager != null else {}
    var camp_attack: float = 5.0 if camp_manager != null and camp_manager.is_built("blacksmith") else 0.0
    var camp_hp: float = 8.0 if camp_manager != null and camp_manager.is_built("training_ground") else 0.0
    return HeroPowerCalculator.final_stats(definition, hero_level, attack_growth, hp_growth, equipment_bonus, camp_attack, camp_hp, loose_bonus)

func _power_for_hero(hero_id: String) -> int:
    return HeroPowerCalculator.power_from_stats(_stats_for_hero(hero_id))

func _hero_name(hero_id: String) -> String:
    for definition in hero_definitions:
        if str(definition.get("id", "")) == hero_id:
            return str(definition.get("name", hero_id))
    return hero_id

func _emit_leader(hero_id: String) -> void:
    leader_requested.emit(hero_id)

func _emit_add(hero_id: String) -> void:
    add_requested.emit(hero_id)

func _emit_remove(hero_id: String) -> void:
    remove_requested.emit(hero_id)
