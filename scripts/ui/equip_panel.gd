class_name EquipPanel
extends Control

# Equipment swap panel: one row per hero showing the six visible pieces
# currently worn, plus one button per complete set. Swapping remains a
# whole-set operation; these sprites are presentation only.

signal swap_requested(hero_id, set_id)

const SLOT_ORDER: Array[String] = ["weapon", "helmet", "chest", "gloves", "boots", "accessory"]
const SLOT_LABELS: Dictionary = {
    "weapon": "武器",
    "helmet": "头盔",
    "chest": "胸甲",
    "gloves": "护手",
    "boots": "战靴",
    "accessory": "饰品"
}

@onready var panel_label: RichTextLabel = $PanelLabel

var heroes: Array = []
var manager: EquipmentManager = null
var lines: Array = []
var dynamic_mode: bool = false
var scroll: ScrollContainer = null
var list_box: VBoxContainer = null
var texture_cache: Dictionary = {}

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

func _piece_texture(set_id: String, slot: String) -> Texture2D:
    var key: String = set_id + "_" + slot
    if texture_cache.has(key):
        return texture_cache[key] as Texture2D
    var path: String = "res://assets/art-v1/sprites/equipment_sets/" + key + ".png"
    var texture := load(path) as Texture2D
    if texture != null:
        texture_cache[key] = texture
    return texture

func _add_piece_preview(parent: Control, set_id: String) -> void:
    var pieces_row := HBoxContainer.new()
    pieces_row.add_theme_constant_override("separation", 4)
    parent.add_child(pieces_row)
    for slot in SLOT_ORDER:
        var piece := TextureRect.new()
        piece.custom_minimum_size = Vector2(44.0, 44.0)
        piece.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        piece.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
        piece.texture = _piece_texture(set_id, slot)
        piece.tooltip_text = str(SLOT_LABELS[slot])
        pieces_row.add_child(piece)

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
            row_label.text = str(hero.hero_name) + "：" + manager.set_name(current) + "（6 件）"
        list_box.add_child(row_label)
        if current != "":
            _add_piece_preview(list_box, current)
        var row: HBoxContainer = HBoxContainer.new()
        row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        list_box.add_child(row)
        for set_id_value in manager.set_ids():
            var set_id: String = str(set_id_value)
            var button: Button = Button.new()
            button.text = manager.set_name(set_id)
            button.icon = _piece_texture(set_id, "weapon")
            button.icon_max_width = 32
            button.disabled = (set_id == current)
            button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
            button.pressed.connect(_on_set_button_pressed.bind(hero_id, set_id))
            row.add_child(button)

func _on_set_button_pressed(hero_id: String, set_id: String) -> void:
    swap_requested.emit(hero_id, set_id)
