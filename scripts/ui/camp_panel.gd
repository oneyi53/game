class_name CampPanel
extends Control

# Camp panel, reusing the EquipPanel dynamic-list pattern and the
# same panel background / label style: one row per building with
# its intro, its built state, and a build button for unbuilt
# buildings. Tapping build emits build_requested; Main checks the
# wood cost, deducts wood, and saves. Hero management is already
# built: its button opens the hero panel instead of building.
# Building records state and shows the reviewed built message only;
# it grants no stat bonus, upgrade, or level in this block.

signal build_requested(building_id)
signal hero_panel_requested

@onready var panel_label: RichTextLabel = $PanelLabel

var manager: CampManager = null
var scroll: ScrollContainer = null
var list_box: VBoxContainer = null

func set_manager(p_manager: CampManager) -> void:
    manager = p_manager
    if panel_label != null:
        panel_label.visible = false
    _ensure_dynamic()
    rebuild()

func refresh() -> void:
    rebuild()

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
    for building_id in manager.building_order:
        var entry = manager.building(building_id)
        if entry == null:
            continue
        var label: Label = Label.new()
        if manager.is_built(building_id):
            label.text = str(entry["name"]) + "：已建成 — " + str(entry["intro"])
        else:
            label.text = str(entry["name"]) + "：未建成（" + str(int(entry["cost_wood"])) + " 木材）— " + str(entry["intro"])
        label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        list_box.add_child(label)
        var button: Button = Button.new()
        if str(building_id) == "hero_management":
            button.text = "打开英雄面板"
            button.pressed.connect(_on_hero_button_pressed)
        elif manager.is_built(building_id):
            button.text = "已建成"
            button.disabled = true
        else:
            button.text = "建造（" + str(int(entry["cost_wood"])) + " 木材）"
            button.pressed.connect(_on_build_button_pressed.bind(building_id))
        list_box.add_child(button)

func _on_build_button_pressed(building_id: String) -> void:
    build_requested.emit(building_id)

func _on_hero_button_pressed() -> void:
    hero_panel_requested.emit()
