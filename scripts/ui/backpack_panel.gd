class_name BackpackPanel
extends Control

# Backpack panel with original item sprites. Loose items remain
# collectable/decomposable only; this visual pass does not make them
# equippable and does not change inventory or save semantics.

signal decompose_requested(index)
signal claim_requested(index)

const ITEM_TEXTURES: Dictionary = {
    "worn_iron_sword": "res://assets/art-v1/sprites/equipment/worn_iron_sword.png",
    "rough_cloth_armor": "res://assets/art-v1/sprites/equipment/rough_cloth_armor.png",
    "cracked_wooden_shield": "res://assets/art-v1/sprites/equipment/cracked_wooden_shield.png",
    "worn_leather_boots": "res://assets/art-v1/sprites/equipment/worn_leather_boots.png",
    "rusty_dagger": "res://assets/art-v1/sprites/equipment/rusty_dagger.png",
    "vine_bracer": "res://assets/art-v1/sprites/equipment/vine_bracer.png"
}

@onready var panel_label: RichTextLabel = $PanelLabel

var manager: BackpackManager = null
var scroll: ScrollContainer = null
var list_box: VBoxContainer = null
var pending_decompose: int = -1
var texture_cache: Dictionary = {}

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

func _item_texture(item_id: String) -> Texture2D:
    if texture_cache.has(item_id):
        return texture_cache[item_id] as Texture2D
    var path: String = str(ITEM_TEXTURES.get(item_id, ""))
    if path == "":
        return null
    var texture := load(path) as Texture2D
    if texture != null:
        texture_cache[item_id] = texture
    return texture

func _add_item_row(item_id: String, item_name: String, stats: String) -> void:
    var row := HBoxContainer.new()
    row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    row.add_theme_constant_override("separation", 8)
    list_box.add_child(row)
    var icon := TextureRect.new()
    icon.custom_minimum_size = Vector2(52.0, 52.0)
    icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    icon.texture = _item_texture(item_id)
    row.add_child(icon)
    var label := Label.new()
    label.text = item_name + "（" + stats + "）"
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    row.add_child(label)

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
        _add_item_row(item_id, str(entry["name"]), manager.stats_text(item_id))
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
            _add_item_row(item_id, str(entry["name"]), manager.stats_text(item_id))
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
