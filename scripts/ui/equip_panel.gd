class_name EquipPanel
extends Control

# Equipment swap panel: one row per hero showing the set currently
# worn, plus one button per set (晨曦先锋 / 森林壁垒 / 星羽游猎).
# Tapping a set button swaps that hero's whole six-piece set at once
# and emits swap_requested; main re-applies the bonus and saves.
# The button for the currently worn set is disabled. There is no
# backpack, upgrade or dismantle UI in M1. set_lines is kept only
# as a label-only fallback and is not used by main.

signal swap_requested(hero_id, set_id)

@onready var panel_label: RichTextLabel = $PanelLabel

var heroes: Array = []
var manager: EquipmentManager = null
var lines: Array = []
var dynamic_mode: bool = false
var scroll: ScrollContainer = null
var list_box: VBoxContainer = null

const EQUIPMENT_ICONS: Dictionary = {
    "dawn_vanguard": {
        "weapon": preload("res://assets/art-v1/sprites/equipment_sets/dawn_vanguard_weapon.png"),
        "helmet": preload("res://assets/art-v1/sprites/equipment_sets/dawn_vanguard_helmet.png"),
        "chest": preload("res://assets/art-v1/sprites/equipment_sets/dawn_vanguard_chest.png"),
        "gloves": preload("res://assets/art-v1/sprites/equipment_sets/dawn_vanguard_gloves.png"),
        "boots": preload("res://assets/art-v1/sprites/equipment_sets/dawn_vanguard_boots.png"),
        "accessory": preload("res://assets/art-v1/sprites/equipment_sets/dawn_vanguard_accessory.png")
    },
    "forest_bulwark": {
        "weapon": preload("res://assets/art-v1/sprites/equipment_sets/forest_bulwark_weapon.png"),
        "helmet": preload("res://assets/art-v1/sprites/equipment_sets/forest_bulwark_helmet.png"),
        "chest": preload("res://assets/art-v1/sprites/equipment_sets/forest_bulwark_chest.png"),
        "gloves": preload("res://assets/art-v1/sprites/equipment_sets/forest_bulwark_gloves.png"),
        "boots": preload("res://assets/art-v1/sprites/equipment_sets/forest_bulwark_boots.png"),
        "accessory": preload("res://assets/art-v1/sprites/equipment_sets/forest_bulwark_accessory.png")
    },
    "starfeather_hunt": {
        "weapon": preload("res://assets/art-v1/sprites/equipment_sets/starfeather_hunt_weapon.png"),
        "helmet": preload("res://assets/art-v1/sprites/equipment_sets/starfeather_hunt_helmet.png"),
        "chest": preload("res://assets/art-v1/sprites/equipment_sets/starfeather_hunt_chest.png"),
        "gloves": preload("res://assets/art-v1/sprites/equipment_sets/starfeather_hunt_gloves.png"),
        "boots": preload("res://assets/art-v1/sprites/equipment_sets/starfeather_hunt_boots.png"),
        "accessory": preload("res://assets/art-v1/sprites/equipment_sets/starfeather_hunt_accessory.png")
    }
}

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
        if current == "":
            row_label.text = str(hero.hero_name) + "：未穿戴套装"
        else:
            row_label.text = str(hero.hero_name) + "：" + manager.set_name(current) + " 6 件"
        row_label.add_theme_font_size_override("font_size", 18)
        list_box.add_child(row_label)
        if current != "" and manager.sets.has(current):
            _add_set_visual(current)
        var tier_label: Label = Label.new()
        var equipped_count: int = int(manager.set_counts_for_hero(hero_id).get(current, 0)) if current != "" else 0
        tier_label.text = "套装进度  %d/2  ·  %d/4  ·  %d/6" % [mini(equipped_count, 2), mini(equipped_count, 4), mini(equipped_count, 6)]
        tier_label.add_theme_color_override("font_color", Color(0.72, 0.84, 0.72))
        list_box.add_child(tier_label)
        var row: HBoxContainer = HBoxContainer.new()
        list_box.add_child(row)
        for set_id in manager.set_ids():
            var button: Button = Button.new()
            button.text = manager.set_name(str(set_id))
            button.disabled = (str(set_id) == current)
            button.pressed.connect(_on_set_button_pressed.bind(hero_id, str(set_id)))
            row.add_child(button)

func _add_set_visual(set_id: String) -> void:
    var entry: Dictionary = manager.sets.get(set_id, {})
    var pieces: Dictionary = entry.get("pieces", {})
    var accent: Color = _set_accent(set_id)
    var grid: GridContainer = GridContainer.new()
    grid.columns = 3
    grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    grid.add_theme_constant_override("h_separation", 6)
    grid.add_theme_constant_override("v_separation", 6)
    list_box.add_child(grid)
    var slot_names: Dictionary = {
        "weapon": "武器",
        "helmet": "头盔",
        "chest": "胸甲",
        "gloves": "护手",
        "boots": "战靴",
        "accessory": "饰品"
    }
    for slot in manager.SLOTS:
        var tile: PanelContainer = PanelContainer.new()
        tile.custom_minimum_size = Vector2(0.0, 82.0)
        var style: StyleBoxFlat = StyleBoxFlat.new()
        style.bg_color = Color(accent.r, accent.g, accent.b, 0.12)
        style.border_color = Color(accent.r, accent.g, accent.b, 0.9)
        style.set_border_width_all(1)
        style.set_corner_radius_all(6)
        style.content_margin_left = 7.0
        style.content_margin_right = 7.0
        style.content_margin_top = 5.0
        style.content_margin_bottom = 5.0
        tile.add_theme_stylebox_override("panel", style)
        var content: HBoxContainer = HBoxContainer.new()
        content.add_theme_constant_override("separation", 7)
        tile.add_child(content)
        var icon: TextureRect = TextureRect.new()
        var set_icons: Dictionary = EQUIPMENT_ICONS.get(set_id, {})
        icon.texture = set_icons.get(slot) as Texture2D
        icon.custom_minimum_size = Vector2(52.0, 52.0)
        icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
        content.add_child(icon)
        var text_column: VBoxContainer = VBoxContainer.new()
        text_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        text_column.add_theme_constant_override("separation", 3)
        content.add_child(text_column)
        var slot_label: Label = Label.new()
        slot_label.text = str(slot_names.get(slot, slot))
        slot_label.add_theme_font_size_override("font_size", 11)
        slot_label.add_theme_color_override("font_color", accent.lightened(0.35))
        text_column.add_child(slot_label)
        var item_label: Label = Label.new()
        item_label.text = str(pieces.get(slot, "未配置"))
        item_label.add_theme_font_size_override("font_size", 13)
        item_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        text_column.add_child(item_label)
        grid.add_child(tile)

func _set_accent(set_id: String) -> Color:
    match set_id:
        "dawn_vanguard":
            return Color(0.95, 0.65, 0.22)
        "forest_bulwark":
            return Color(0.35, 0.78, 0.42)
        "starfeather_hunt":
            return Color(0.38, 0.68, 0.96)
        _:
            return Color(0.72, 0.76, 0.82)

func _on_set_button_pressed(hero_id: String, set_id: String) -> void:
    swap_requested.emit(hero_id, set_id)
