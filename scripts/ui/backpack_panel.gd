class_name BackpackPanel
extends Control

# Backpack panel: loose equipment now uses its original item PNG icon.
# Decompose confirmation and mailbox claim behavior are unchanged.
signal decompose_requested(index)
signal claim_requested(index)
signal equip_requested(index, hero_id)

@onready var panel_label: RichTextLabel = $PanelLabel

const ITEM_TEXTURES := {
    "worn_iron_sword": preload("res://assets/art-v1/sprites/equipment/worn_iron_sword.png"),
    "rough_cloth_armor": preload("res://assets/art-v1/sprites/equipment/rough_cloth_armor.png"),
    "cracked_wooden_shield": preload("res://assets/art-v1/sprites/equipment/cracked_wooden_shield.png"),
    "worn_leather_boots": preload("res://assets/art-v1/sprites/equipment/worn_leather_boots.png"),
    "rusty_dagger": preload("res://assets/art-v1/sprites/equipment/rusty_dagger.png"),
    "vine_bracer": preload("res://assets/art-v1/sprites/equipment/vine_bracer.png")
}

var manager: BackpackManager = null
var heroes: Array = []
var scroll: ScrollContainer = null
var list_box: VBoxContainer = null
var pending_decompose: int = -1

func set_manager(p_manager: BackpackManager, p_heroes: Array = []) -> void:
    manager = p_manager
    heroes = p_heroes
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

func _make_item_row(item_id: String, item_name: String, stats: String) -> HBoxContainer:
    var row := HBoxContainer.new()
    row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    row.add_theme_constant_override("separation", 8)
    var icon := TextureRect.new()
    icon.texture = ITEM_TEXTURES.get(item_id)
    icon.custom_minimum_size = Vector2(48.0, 48.0)
    icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    row.add_child(icon)
    var label := Label.new()
    label.text = item_name + "（" + stats + "）"
    label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    row.add_child(label)
    return row

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
        list_box.add_child(_make_item_row(item_id, str(entry["name"]), manager.stats_text(item_id)))
        var action_row := HBoxContainer.new()
        action_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        var target := OptionButton.new()
        target.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        for hero in heroes:
            if hero != null:
                target.add_item(str(hero.hero_name))
                target.set_item_metadata(target.item_count - 1, str(hero.hero_id))
        if target.item_count > 0:
            target.select(0)
        action_row.add_child(target)
        var wear_button := Button.new()
        wear_button.text = "穿戴"
        wear_button.disabled = target.item_count == 0
        wear_button.pressed.connect(_on_equip_button_pressed.bind(i, target))
        action_row.add_child(wear_button)
        list_box.add_child(action_row)
        var button: Button = Button.new()
        button.text = "确认分解？" if i == pending_decompose else "分解（+" + str(manager.decompose_gold) + " 金币）"
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
            list_box.add_child(_make_item_row(item_id, str(entry["name"]), manager.stats_text(item_id)))
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

func _on_equip_button_pressed(index: int, target: OptionButton) -> void:
    if target == null or target.item_count == 0:
        return
    equip_requested.emit(index, str(target.get_item_metadata(target.selected)) )
