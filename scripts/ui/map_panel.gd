class_name MapPanel
extends Control

# World map panel (reference: world map screen).
# Header shows the current area; below it one card per sub-map
# (name, safe/wild, locked state). Tapping a card travels there
# when unlocked. There is no overview image to zoom, so no zoom
# buttons: the panel only lists the sub-maps.
signal map_selected(map_index: int)
signal close_requested

@onready var header_label: Label = $HeaderLabel
@onready var map_grid: GridContainer = $MapScroll/MapGrid
@onready var close_button: Button = $CloseButton

var maps: Array = []
var current_map_id: String = ""

func _ready() -> void:
    if close_button != null:
        close_button.pressed.connect(func() -> void: close_requested.emit())

func set_maps(p_maps: Array, p_current_map_id: String) -> void:
    maps = p_maps
    current_map_id = p_current_map_id
    refresh()

func refresh() -> void:
    if header_label != null:
        var current_name: String = current_map_id
        for entry in maps:
            if str(entry.get("id", "")) == current_map_id:
                current_name = str(entry.get("name", current_map_id))
        header_label.text = "世界地图  当前：" + current_name
    if map_grid == null:
        return
    for child in map_grid.get_children():
        map_grid.remove_child(child)
        child.queue_free()
    for i in range(maps.size()):
        var entry: Dictionary = maps[i]
        var card := PanelContainer.new()
        card.custom_minimum_size = Vector2(300, 150)
        var box := VBoxContainer.new()
        box.add_theme_constant_override("separation", 4)
        card.add_child(box)
        var name_label := Label.new()
        name_label.text = str(entry.get("name", ""))
        name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        box.add_child(name_label)
        var info_label := Label.new()
        var state_text: String = "当前" if str(entry.get("id", "")) == current_map_id else ("已解锁" if bool(entry.get("unlocked", false)) else "未解锁")
        var safe_text: String = "安全区" if bool(entry.get("safe", false)) else "野外"
        info_label.text = state_text + " · " + safe_text
        info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        box.add_child(info_label)
        var go_button := Button.new()
        go_button.custom_minimum_size = Vector2(120, 48)
        go_button.text = "前往"
        go_button.disabled = not bool(entry.get("unlocked", false)) or str(entry.get("id", "")) == current_map_id
        go_button.pressed.connect(func() -> void: map_selected.emit(i))
        box.add_child(go_button)
        map_grid.add_child(card)
