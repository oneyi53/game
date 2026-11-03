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
        list_box.add_child(row_label)
        var row: HBoxContainer = HBoxContainer.new()
        list_box.add_child(row)
        for set_id in manager.set_ids():
            var button: Button = Button.new()
            button.text = manager.set_name(str(set_id))
            button.disabled = (str(set_id) == current)
            button.pressed.connect(_on_set_button_pressed.bind(hero_id, str(set_id)))
            row.add_child(button)

func _on_set_button_pressed(hero_id: String, set_id: String) -> void:
    swap_requested.emit(hero_id, set_id)
