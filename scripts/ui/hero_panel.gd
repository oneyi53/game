class_name HeroPanel
extends Control

signal leader_requested(hero_id: String)
signal add_requested(hero_id: String)
signal remove_requested(hero_id: String)

@onready var panel_label: RichTextLabel = $PanelLabel
@onready var formation_list: VBoxContainer = $FormationScroll/FormationList

var heroes: Array = []
var formation_manager = null
var hero_definitions: Array = []
var level_manager = null

func set_heroes(p_heroes: Array) -> void:
    heroes = p_heroes
    refresh()

func set_formation_data(p_formation_manager, p_hero_definitions: Array, p_level_manager) -> void:
    formation_manager = p_formation_manager
    hero_definitions = p_hero_definitions
    level_manager = p_level_manager
    refresh()

func refresh() -> void:
    if panel_label == null:
        return
    if formation_manager != null and not formation_manager.active_ids.is_empty():
        var leader_name: String = _hero_name(str(formation_manager.active_ids[0]))
        panel_label.text = "英雄编队  " + str(formation_manager.active_ids.size()) + "/" + str(formation_manager.max_party_size) + "    当前队长：" + leader_name
    else:
        panel_label.text = "英雄编队"
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
        info.text = state_text + _hero_name(hero_id) + "  Lv." + str(hero_level)
        info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        info.custom_minimum_size = Vector2(220, 34)
        row.add_child(info)
        var leader_button := Button.new()
        leader_button.custom_minimum_size = Vector2(108, 34)
        if leader:
            leader_button.text = "当前队长"
            leader_button.disabled = true
        else:
            leader_button.text = "替换队长" if not active and formation_manager.active_ids.size() >= formation_manager.max_party_size else "设为队长"
            leader_button.pressed.connect(_emit_leader.bind(hero_id))
        row.add_child(leader_button)
        var party_button := Button.new()
        party_button.custom_minimum_size = Vector2(76, 34)
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
