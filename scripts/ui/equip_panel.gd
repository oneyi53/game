class_name EquipPanel
extends Control

signal swap_requested(hero_id, set_id)
signal unequip_requested(hero_id, slot)

@onready var panel_label: RichTextLabel = $PanelLabel

const SET_PIECE_TEXTURES := {
    "dawn_vanguard": [
        preload("res://assets/art-v1/sprites/equipment_sets/dawn_vanguard_weapon.png"),
        preload("res://assets/art-v1/sprites/equipment_sets/dawn_vanguard_helmet.png"),
        preload("res://assets/art-v1/sprites/equipment_sets/dawn_vanguard_chest.png"),
        preload("res://assets/art-v1/sprites/equipment_sets/dawn_vanguard_gloves.png"),
        preload("res://assets/art-v1/sprites/equipment_sets/dawn_vanguard_boots.png"),
        preload("res://assets/art-v1/sprites/equipment_sets/dawn_vanguard_accessory.png")
    ],
    "forest_bulwark": [
        preload("res://assets/art-v1/sprites/equipment_sets/forest_bulwark_weapon.png"),
        preload("res://assets/art-v1/sprites/equipment_sets/forest_bulwark_helmet.png"),
        preload("res://assets/art-v1/sprites/equipment_sets/forest_bulwark_chest.png"),
        preload("res://assets/art-v1/sprites/equipment_sets/forest_bulwark_gloves.png"),
        preload("res://assets/art-v1/sprites/equipment_sets/forest_bulwark_boots.png"),
        preload("res://assets/art-v1/sprites/equipment_sets/forest_bulwark_accessory.png")
    ],
    "starfeather_hunt": [
        preload("res://assets/art-v1/sprites/equipment_sets/starfeather_hunt_weapon.png"),
        preload("res://assets/art-v1/sprites/equipment_sets/starfeather_hunt_helmet.png"),
        preload("res://assets/art-v1/sprites/equipment_sets/starfeather_hunt_chest.png"),
        preload("res://assets/art-v1/sprites/equipment_sets/starfeather_hunt_gloves.png"),
        preload("res://assets/art-v1/sprites/equipment_sets/starfeather_hunt_boots.png"),
        preload("res://assets/art-v1/sprites/equipment_sets/starfeather_hunt_accessory.png")
    ]
}

var heroes: Array = []
var hero_entries: Array = []
var manager: EquipmentManager = null
var item_definitions: Dictionary = {}
var lines: Array = []
var dynamic_mode: bool = false
var scroll: ScrollContainer = null
var list_box: VBoxContainer = null

func set_data(p_heroes: Array, p_manager: EquipmentManager) -> void:
    heroes = p_heroes
    hero_entries.clear()
    for hero in heroes:
        if hero != null:
            hero_entries.append({"id": str(hero.hero_id), "name": str(hero.hero_name)})
    manager = p_manager
    dynamic_mode = true
    if panel_label != null:
        panel_label.visible = false
    _ensure_dynamic()
    rebuild()

func set_roster(p_hero_ids: Array, p_hero_definitions: Array, p_manager: EquipmentManager) -> void:
    hero_entries.clear()
    manager = p_manager
    for hero_id_value in p_hero_ids:
        var hero_id: String = str(hero_id_value)
        var hero_name: String = hero_id
        for definition in p_hero_definitions:
            if str(definition.get("id", "")) == hero_id:
                hero_name = str(definition.get("name", hero_id))
                break
        hero_entries.append({"id": hero_id, "name": hero_name})
    dynamic_mode = true
    if panel_label != null:
        panel_label.visible = false
    _ensure_dynamic()
    rebuild()

func set_item_definitions(definitions: Dictionary) -> void:
    item_definitions = definitions
    rebuild()

func set_lines(p_lines: Array) -> void:
    lines = p_lines
    dynamic_mode = false
    if scroll != null:
        scroll.visible = false
    if panel_label != null:
        panel_label.visible = true
    refresh()

func refresh() -> void:
    if dynamic_mode:
        rebuild()
        return
    if panel_label == null:
        return
    var text: String = ""
    for line in lines:
        text += str(line) + "\n"
    panel_label.text = text.strip_edges()

func _ensure_dynamic() -> void:
    if scroll != null:
        scroll.visible = true
        return
    scroll = ScrollContainer.new()
    scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
    add_child(scroll)
    list_box = VBoxContainer.new()
    list_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    scroll.add_child(list_box)

func rebuild() -> void:
    if manager == null or list_box == null:
        return
    for child in list_box.get_children():
        list_box.remove_child(child)
        child.queue_free()
    for hero_entry in hero_entries:
        var hero_id: String = str(hero_entry.get("id", ""))
        var hero_name: String = str(hero_entry.get("name", hero_id))
        if hero_id == "":
            continue
        var current: String = manager.equipped_set_id_for_hero(hero_id)
        var counts: Dictionary = manager.set_counts_for_hero(hero_id)
        var current_count: int = int(counts.get(current, 0))
        var row_label := Label.new()
        row_label.text = hero_name + ("（预备）" if not _is_runtime_hero(hero_id) else "") + ("：未穿戴套装" if current == "" else "：" + manager.set_name(current) + " " + str(current_count) + "/6 件套装部件")
        list_box.add_child(row_label)

        var worn: Dictionary = manager.loose_equipped_for_hero(hero_id)
        var slot_names: Dictionary = {"weapon": "武器", "chest": "护甲", "gloves": "护腕", "boots": "鞋子", "offhand": "副手"}
        for slot_value in ["weapon", "chest", "gloves", "boots", "offhand"]:
            var slot: String = str(slot_value)
            var gear_row := HBoxContainer.new()
            gear_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
            var gear_label := Label.new()
            var item_id: String = str(worn.get(slot, ""))
            var item_entry: Dictionary = item_definitions.get(item_id, {})
            gear_label.text = str(slot_names[slot]) + "：" + ("未穿戴" if item_id == "" else str(item_entry.get("name", item_id)))
            gear_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
            gear_row.add_child(gear_label)
            if item_id != "":
                var remove_button := Button.new()
                remove_button.text = "卸下"
                remove_button.pressed.connect(_on_unequip_button_pressed.bind(hero_id, slot))
                gear_row.add_child(remove_button)
            list_box.add_child(gear_row)

        var sets_row := HBoxContainer.new()
        sets_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        list_box.add_child(sets_row)
        for set_value in manager.set_ids():
            var set_id: String = str(set_value)
            var card := VBoxContainer.new()
            card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
            sets_row.add_child(card)
            var icons := HBoxContainer.new()
            icons.add_theme_constant_override("separation", 1)
            card.add_child(icons)
            for texture in SET_PIECE_TEXTURES.get(set_id, []):
                var icon := TextureRect.new()
                icon.texture = texture
                icon.custom_minimum_size = Vector2(26.0, 26.0)
                icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
                icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
                icons.add_child(icon)
            var button := Button.new()
            button.text = manager.set_name(set_id)
            button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
            button.disabled = (set_id == current)
            button.pressed.connect(_on_set_button_pressed.bind(hero_id, set_id))
            card.add_child(button)


func _is_runtime_hero(hero_id: String) -> bool:
    for hero in heroes:
        if hero != null and str(hero.hero_id) == hero_id:
            return true
    return false

func _on_unequip_button_pressed(hero_id: String, slot: String) -> void:
    unequip_requested.emit(hero_id, slot)

func _on_set_button_pressed(hero_id: String, set_id: String) -> void:
    swap_requested.emit(hero_id, set_id)
