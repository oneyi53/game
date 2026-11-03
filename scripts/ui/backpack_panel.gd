class_name BackpackPanel
extends Control

# Backpack panel, reusing the EquipPanel / CampPanel dynamic-list
# pattern and the same panel background / label style. One row per
# backpack item (name, stats, decompose button); a mailbox section
# below it, one claim button per overflow item. Loose items are
# never worn here: there is no equip button in this block.
# Decompose asks for confirmation in place: the first tap turns
# that row's button into "确认分解？", the second tap emits
# decompose_requested. Main checks the index, removes the item,
# grants decompose_gold and saves.

signal decompose_requested(index)
signal claim_requested(index)

@onready var panel_label: RichTextLabel = $PanelLabel

var manager: BackpackManager = null
var scroll: ScrollContainer = null
var list_box: VBoxContainer = null
var pending_decompose: int = -1

func set_manager(p_manager: BackpackManager) -> void:
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
    var header: Label = Label.new()
    header.text = "背包：" + str(manager.backpack.size()) + "/" + str(manager.backpack_cap) + "（邮箱：" + str(manager.mailbox.size()) + "）"
    list_box.add_child(header)
    if manager.backpack.is_empty():
        var empty_label: Label = Label.new()
        empty_label.text = "背包是空的，击败小怪有概率掉落散件。"
        empty_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        list_box.add_child(empty_label)
    for i in range(manager.backpack.size()):
        var item_id: String = str(manager.backpack[i])
        var entry = manager.item(item_id)
        if entry == null:
            continue
        var label: Label = Label.new()
        label.text = str(entry["name"]) + "（" + manager.stats_text(item_id) + "）"
        label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        list_box.add_child(label)
        var button: Button = Button.new()
        if i == pending_decompose:
            button.text = "确认分解？"
        else:
            button.text = "分解（+" + str(manager.decompose_gold) + " 金币）"
        button.pressed.connect(_on_decompose_button_pressed.bind(i))
        list_box.add_child(button)
    if not manager.mailbox.is_empty():
        var mailbox_header: Label = Label.new()
        mailbox_header.text = "邮箱（背包满时溢出到这里，背包有空位时可领取）："
        mailbox_header.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        list_box.add_child(mailbox_header)
        for i in range(manager.mailbox.size()):
            var item_id: String = str(manager.mailbox[i])
            var entry = manager.item(item_id)
            if entry == null:
                continue
            var label: Label = Label.new()
            label.text = str(entry["name"]) + "（" + manager.stats_text(item_id) + "）"
            label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
            list_box.add_child(label)
            var button: Button = Button.new()
            button.text = "领取到背包"
            button.pressed.connect(_on_claim_button_pressed.bind(i))
            list_box.add_child(button)

func _on_decompose_button_pressed(index: int) -> void:
    if index != pending_decompose:
        pending_decompose = index
        rebuild()
        return
    pending_decompose = -1
    decompose_requested.emit(index)

func _on_claim_button_pressed(index: int) -> void:
    claim_requested.emit(index)
