class_name HeroPanel
extends Control

# Displays recruited heroes with their existing combat attributes.
# Portraits are presentation-only and do not affect gameplay.

@onready var panel_label: RichTextLabel = $PanelLabel

var heroes: Array = []
var scroll: ScrollContainer = null
var list_box: VBoxContainer = null

func set_heroes(p_heroes: Array) -> void:
    heroes = p_heroes
    if panel_label != null:
        panel_label.visible = false
    _ensure_dynamic()
    refresh()

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

func refresh() -> void:
    if list_box == null:
        return
    for child in list_box.get_children():
        list_box.remove_child(child)
        child.queue_free()
    for hero in heroes:
        if hero == null:
            continue
        var hero_id: String = str(hero.hero_id)
        var card: PanelContainer = PanelContainer.new()
        card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        var row: HBoxContainer = HBoxContainer.new()
        row.add_theme_constant_override("separation", 12)
        card.add_child(row)

        var portrait: TextureRect = TextureRect.new()
        portrait.custom_minimum_size = Vector2(64.0, 64.0)
        portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
        portrait.texture = load("res://assets/art-v1/sprites/heroes/" + hero_id + ".png")
        row.add_child(portrait)

        var details: VBoxContainer = VBoxContainer.new()
        details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        row.add_child(details)
        var title: Label = Label.new()
        title.text = str(hero.hero_name) + "（" + str(hero.data.get("role", "")) + "） · 等级 " + str(hero.level)
        details.add_child(title)
        var stats: Label = Label.new()
        stats.text = "生命 %d/%d  攻击 %d  防御 %d" % [hero.hp, hero.max_hp, hero.attack, hero.defense]
        stats.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        details.add_child(stats)
        var movement: Label = Label.new()
        movement.text = "移速 %d  攻击范围 %d" % [int(hero.move_speed), int(hero.attack_range)]
        movement.add_theme_font_size_override("font_size", 12)
        movement.add_theme_color_override("font_color", Color(0.78, 0.82, 0.76))
        details.add_child(movement)
        list_box.add_child(card)
