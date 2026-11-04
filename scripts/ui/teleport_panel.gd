class_name TeleportPanel
extends Control

signal destination_requested(destination_id: String)
signal close_requested

@onready var close_button: Button = $CloseButton
@onready var list_box: VBoxContainer = $Scroll/List

var destinations: Array[Dictionary] = []

func _ready() -> void:
    close_button.pressed.connect(func() -> void: close_requested.emit())
    rebuild()

func set_destinations(entries: Array[Dictionary]) -> void:
    destinations.clear()
    for entry in entries:
        destinations.append(entry.duplicate(true))
    rebuild()

func rebuild() -> void:
    if list_box == null:
        return
    for child in list_box.get_children():
        list_box.remove_child(child)
        child.queue_free()
    for entry in destinations:
        var button := Button.new()
        var label: String = str(entry.get("name", "未知区域"))
        if bool(entry.get("unlocked", false)):
            button.text = label + "  ·  " + str(entry.get("hint", "已开放"))
        else:
            button.text = label + "  ·  未开放（" + str(entry.get("hint", "完成前置条件")) + "）"
            button.disabled = true
        button.custom_minimum_size = Vector2(0.0, 64.0)
        button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        button.pressed.connect(_on_destination_button_pressed.bind(str(entry.get("id", ""))))
        list_box.add_child(button)

func _on_destination_button_pressed(destination_id: String) -> void:
    destination_requested.emit(destination_id)
