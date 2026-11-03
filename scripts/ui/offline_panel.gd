class_name OfflinePanel
extends Control

# Offline settlement panel, reusing the CampPanel dynamic-list
# pattern and the same panel background / label style: a few
# label lines plus one confirm button. The earnings are already
# credited by Main before this panel is shown, so confirming only
# closes the panel; it never credits twice.

signal confirmed

@onready var panel_label: RichTextLabel = $PanelLabel

var scroll: ScrollContainer = null
var list_box: VBoxContainer = null

func show_settlement(lines: Array) -> void:
    if panel_label != null:
        panel_label.visible = false
    _ensure_dynamic()
    for child in list_box.get_children():
        list_box.remove_child(child)
        child.queue_free()
    for line in lines:
        var label: Label = Label.new()
        label.text = str(line)
        label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        list_box.add_child(label)
    var button: Button = Button.new()
    button.text = "确认"
    button.pressed.connect(_on_confirm_pressed)
    list_box.add_child(button)
    visible = true

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

func _on_confirm_pressed() -> void:
    visible = false
    confirmed.emit()
