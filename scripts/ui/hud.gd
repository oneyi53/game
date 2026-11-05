class_name Hud
extends Control

signal skill_pressed
signal interact_pressed
signal save_pressed
signal hero_panel_pressed
signal equip_panel_pressed
signal camp_panel_pressed
signal backpack_panel_pressed
signal recruit_panel_pressed
signal teleport_pressed
signal map_pressed

@onready var gold_label: Label = $GoldLabel
@onready var wood_label: Label = $WoodLabel
@onready var message_label: Label = $MessageLabel
@onready var quest_label: Label = $QuestLabel
@onready var skill_button: Button = $SkillButton
@onready var interact_button: Button = $InteractButton
@onready var save_button: Button = $SaveButton
@onready var hero_button: Button = $HeroButton
@onready var equip_button: Button = $EquipButton
@onready var camp_button: Button = $CampButton
@onready var backpack_button: Button = $BackpackButton
@onready var recruit_button: Button = $RecruitButton
@onready var cooldown_label: Label = $CooldownLabel
@onready var teleport_button: Button = $TeleportButton
@onready var map_button: Button = $MapButton

const PANEL_DARK := Color(0.10, 0.14, 0.18, 0.88)
const PANEL_GOLD := Color(0.75, 0.48, 0.18, 0.96)
const TEXT_LIGHT := Color(1.0, 0.95, 0.82, 1.0)

func _ready() -> void:
    skill_button.pressed.connect(_on_skill_button_pressed)
    interact_button.pressed.connect(_on_interact_button_pressed)
    save_button.pressed.connect(_on_save_button_pressed)
    hero_button.pressed.connect(_on_hero_button_pressed)
    equip_button.pressed.connect(_on_equip_button_pressed)
    camp_button.pressed.connect(_on_camp_button_pressed)
    backpack_button.pressed.connect(_on_backpack_button_pressed)
    recruit_button.pressed.connect(_on_recruit_button_pressed)
    teleport_button.pressed.connect(_on_teleport_button_pressed)
    map_button.pressed.connect(_on_map_button_pressed)
    teleport_button.disabled = true
    _apply_reference_layout()
    get_viewport().size_changed.connect(_apply_reference_layout)

func _apply_reference_layout() -> void:
    var viewport_size := get_viewport_rect().size
    var sx := viewport_size.x / 720.0
    var sy := viewport_size.y / 1280.0
    # Top resource strip: two compact, readable capsules.
    _place(gold_label, Vector2(14, 14), Vector2(220, 42), sx, sy)
    _place(wood_label, Vector2(242, 14), Vector2(464, 42), sx, sy)
    _place(message_label, Vector2(16, 60), Vector2(688, 32), sx, sy)
    _place(quest_label, Vector2(14, 104), Vector2(190, 150), sx, sy)
    quest_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    quest_label.add_theme_color_override("font_color", TEXT_LIGHT)
    quest_label.add_theme_font_size_override("font_size", 19)
    _style_label(gold_label, PANEL_GOLD, 22)
    _style_label(wood_label, PANEL_DARK, 20)
    _style_label(message_label, PANEL_DARK, 17)

    # Left-side character and progression shortcuts.
    _place(hero_button, Vector2(12, 300), Vector2(112, 58), sx, sy)
    _place(equip_button, Vector2(12, 370), Vector2(112, 58), sx, sy)
    _place(camp_button, Vector2(12, 440), Vector2(112, 58), sx, sy)
    _place(recruit_button, Vector2(12, 510), Vector2(112, 58), sx, sy)
    _place(backpack_button, Vector2(12, 1040), Vector2(112, 64), sx, sy)
    _place(save_button, Vector2(12, 1114), Vector2(112, 56), sx, sy)

    # Right-side world actions and menus.
    _place(teleport_button, Vector2(596, 300), Vector2(112, 58), sx, sy)
    _place(map_button, Vector2(596, 370), Vector2(112, 58), sx, sy)
    _place(interact_button, Vector2(596, 900), Vector2(112, 58), sx, sy)
    _place(skill_button, Vector2(596, 970), Vector2(112, 64), sx, sy)
    _place(cooldown_label, Vector2(560, 1040), Vector2(148, 30), sx, sy)
    cooldown_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    for button in [skill_button, interact_button, save_button, hero_button, equip_button, camp_button, backpack_button, recruit_button, teleport_button, map_button]:
        _style_button(button)

func _place(control: Control, design_pos: Vector2, design_size: Vector2, sx: float, sy: float) -> void:
    control.set_anchors_preset(Control.PRESET_TOP_LEFT)
    control.position = Vector2(design_pos.x * sx, design_pos.y * sy)
    control.size = Vector2(design_size.x * sx, design_size.y * sy)

func _style_label(label: Label, fill: Color, font_size: int) -> void:
    var style := StyleBoxFlat.new()
    style.bg_color = fill
    style.corner_radius_top_left = 12
    style.corner_radius_top_right = 12
    style.corner_radius_bottom_left = 12
    style.corner_radius_bottom_right = 12
    style.content_margin_left = 12
    style.content_margin_right = 12
    label.add_theme_stylebox_override("normal", style)
    label.add_theme_color_override("font_color", TEXT_LIGHT)
    label.add_theme_font_size_override("font_size", font_size)

func _style_button(button: Button) -> void:
    button.add_theme_font_size_override("font_size", 19)
    button.add_theme_color_override("font_color", TEXT_LIGHT)
    button.add_theme_color_override("font_hover_color", Color.WHITE)
    button.add_theme_color_override("font_pressed_color", Color.WHITE)
    var normal := StyleBoxFlat.new()
    normal.bg_color = Color(0.17, 0.23, 0.27, 0.92)
    normal.border_color = Color(0.78, 0.62, 0.36, 0.95)
    normal.set_border_width_all(2)
    normal.set_corner_radius_all(13)
    normal.content_margin_left = 5
    normal.content_margin_right = 5
    var hover := normal.duplicate() as StyleBoxFlat
    hover.bg_color = Color(0.25, 0.34, 0.38, 0.98)
    var pressed := normal.duplicate() as StyleBoxFlat
    pressed.bg_color = Color(0.09, 0.13, 0.16, 0.98)
    button.add_theme_stylebox_override("normal", normal)
    button.add_theme_stylebox_override("hover", hover)
    button.add_theme_stylebox_override("pressed", pressed)
    button.add_theme_stylebox_override("disabled", normal)

func set_gold(amount: int) -> void:
    gold_label.text = "金币  " + str(amount)

func set_wood(amount: int, cap: int) -> void:
    wood_label.text = "木材  " + str(amount) + "/" + str(cap)

func set_teleport_available(available: bool) -> void:
    teleport_button.disabled = not available

func set_quest_text(text: String) -> void:
    quest_label.text = text

func show_message(text: String) -> void:
    message_label.text = text

func set_skill_cooldown(remaining: float, ready: bool) -> void:
    cooldown_label.text = "技能就绪" if ready else "冷却 %.1f 秒" % remaining

func _on_skill_button_pressed() -> void:
    skill_pressed.emit()

func _on_interact_button_pressed() -> void:
    interact_pressed.emit()

func _on_save_button_pressed() -> void:
    save_pressed.emit()

func _on_hero_button_pressed() -> void:
    hero_panel_pressed.emit()

func _on_equip_button_pressed() -> void:
    equip_panel_pressed.emit()

func _on_camp_button_pressed() -> void:
    camp_panel_pressed.emit()

func _on_backpack_button_pressed() -> void:
    backpack_panel_pressed.emit()

func _on_recruit_button_pressed() -> void:
    recruit_panel_pressed.emit()

func _on_teleport_button_pressed() -> void:
    teleport_pressed.emit()

func _on_map_button_pressed() -> void:
    map_pressed.emit()
