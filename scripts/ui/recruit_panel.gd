class_name RecruitPanel
extends Control

# Recruitment panel, reusing the CampPanel dynamic-list pattern and
# the same panel background / label style: one row per hero with
# its recruit state, its unlock condition, and (for the fragment
# hero) its fragment progress. Quest-locked heroes have a disabled
# button because they unlock only by completing their quest; the
# fragment hero gets an enabled synthesize button once enough
# fragments are collected. Tapping synthesize emits
# synthesize_requested; Main checks fragments, spawns the hero and
# saves. This panel never invents a hero, a condition or a price.

signal synthesize_requested(hero_id)

@onready var panel_label: RichTextLabel = $PanelLabel

var recruitment_manager: RecruitmentManager = null
var level_manager: LevelManager = null
var hero_table: Array = []
var scroll: ScrollContainer = null
var list_box: VBoxContainer = null

func set_data(p_recruitment: RecruitmentManager, p_levels: LevelManager, p_heroes: Array) -> void:
    recruitment_manager = p_recruitment
    level_manager = p_levels
    hero_table = p_heroes
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
    if recruitment_manager == null or list_box == null:
        return
    for child in list_box.get_children():
        list_box.remove_child(child)
        child.queue_free()
    for hero_data in hero_table:
        var hero_id: String = str(hero_data["id"])
        var entry = recruitment_manager.entry(hero_id)
        if entry == null:
            continue
        var card: PanelContainer = PanelContainer.new()
        card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        var row: HBoxContainer = HBoxContainer.new()
        row.add_theme_constant_override("separation", 12)
        card.add_child(row)

        var portrait: TextureRect = TextureRect.new()
        portrait.custom_minimum_size = Vector2(72.0, 72.0)
        portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
        portrait.texture = load("res://assets/art-v1/sprites/heroes/" + hero_id + ".png")
        row.add_child(portrait)

        var details: VBoxContainer = VBoxContainer.new()
        details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        row.add_child(details)
        var label: Label = Label.new()
        var name_text: String = str(hero_data["name"]) + "（" + str(hero_data["role"]) + "）"
        if recruitment_manager.is_recruited(hero_id):
            var level_value: int = 1
            if level_manager != null:
                level_value = level_manager.level(hero_id)
            label.text = name_text + " · 等级 " + str(level_value) + " · 已加入"
        elif str(entry["unlock_type"]) == "fragments":
            label.text = name_text + " · 未招募 · 碎片 " + str(recruitment_manager.fragments) + "/" + str(recruitment_manager.fragments_required(hero_id))
        else:
            label.text = name_text + " · 未招募"
        label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        details.add_child(label)

        var condition: Label = Label.new()
        condition.text = str(entry["condition_text"])
        condition.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        condition.add_theme_font_size_override("font_size", 12)
        condition.add_theme_color_override("font_color", Color(0.78, 0.82, 0.76))
        details.add_child(condition)

        var button: Button = Button.new()
        if recruitment_manager.is_recruited(hero_id):
            button.text = "已加入"
            button.disabled = true
        elif str(entry["unlock_type"]) == "fragments" and recruitment_manager.fragments >= recruitment_manager.fragments_required(hero_id):
            button.text = "合成解锁"
            button.pressed.connect(_on_synthesize_button_pressed.bind(hero_id))
        elif str(entry["unlock_type"]) == "fragments":
            button.text = "碎片不足（" + str(recruitment_manager.fragments) + "/" + str(recruitment_manager.fragments_required(hero_id)) + "）"
            button.disabled = true
        else:
            button.text = "完成任务解锁"
            button.disabled = true
        details.add_child(button)
        list_box.add_child(card)

func _on_synthesize_button_pressed(hero_id: String) -> void:
    synthesize_requested.emit(hero_id)
