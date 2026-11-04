class_name EquipPanel
extends Control

# Set swapping remains atomic; the original six-piece PNGs are now
# displayed in each set card so all available equipment art is visible.
signal swap_requested(hero_id, set_id)

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
var manager: EquipmentManager = null
var lines: Array = []
var dynamic_mode: bool = false
var scroll: ScrollContainer = null
var list_box: VBoxContainer = null

func set_data(p_heroes: Array, p_manager: EquipmentManager) -> void:
    heroes = p_heroes
    manager = p_manager
    dynamic_mode = true
    if panel_label != null:
        panel_label.visible = false
    _ensure_dynamic()
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
    for hero in heroes:
        if hero == null:
            continue
        var hero_id: String = str(hero.hero_id)
        var current: String = manager.equipped_set_id_for_hero(hero_id)
        var row_label: Label = Label.new()
        row_label.text = str(hero.hero_name) + ("：未穿戴套装" if current == "" else "：" + manager.set_name(current) + " 6 件")
        list_box.add_child(row_label)
        var sets_row: HBoxContainer = HBoxContainer.new()
        sets_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        list_box.add_child(sets_row)
        for set_value in manager.set_ids():
            var set_id: String = str(set_value)
            var card: VBoxContainer = VBoxContainer.new()
            card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
            sets_row.add_child(card)
            var icons: HBoxContainer = HBoxContainer.new()
            icons.add_theme_constant_override("separation", 1)
            card.add_child(icons)
            var textures: Array = SET_PIECE_TEXTURES.get(set_id, [])
            for texture in textures:
                var icon: TextureRect = TextureRect.new()
                icon.texture = texture
                icon.custom_minimum_size = Vector2(26.0, 26.0)
                icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
                icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
                icons.add_child(icon)
            var button: Button = Button.new()
            button.text = manager.set_name(set_id)
            button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
            button.disabled = (set_id == current)
            button.pressed.connect(_on_set_button_pressed.bind(hero_id, set_id))
            card.add_child(button)

func _on_set_button_pressed(hero_id: String, set_id: String) -> void:
    swap_requested.emit(hero_id, set_id)
