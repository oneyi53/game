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
@onready var map_name_label: Label = $MapNameLabel
@onready var exploration_label: Label = $ExplorationLabel

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
    _style_label(gold_label, 20, Color(1.0, 0.9, 0.58))
    _style_label(wood_label, 20, Color(0.88, 0.95, 0.78))
    _style_label(quest_label, 17, Color(1.0, 0.97, 0.84))
    _style_label(message_label, 17, Color(1.0, 0.94, 0.72))
    _style_label(cooldown_label, 16, Color(1.0, 0.9, 0.66))
    _style_label(map_name_label, 21, Color(1.0, 0.96, 0.78))
    _style_label(exploration_label, 15, Color(0.78, 0.92, 0.72))
    exploration_label.visible = false
    _style_button(skill_button, Color(0.66, 0.31, 0.12), 22)
    _style_button(interact_button, Color(0.2, 0.43, 0.25), 18)
    for button in [save_button, hero_button, equip_button, camp_button, backpack_button, recruit_button]:
        _style_button(button, Color(0.13, 0.25, 0.23), 16)
    _style_button(teleport_button, Color(0.25, 0.37, 0.3), 16)
    _style_button(map_button, Color(0.25, 0.37, 0.3), 16)



func set_region_name(region_name: String) -> void:
    map_name_label.text = region_name


func set_exploration_stats(applicable: bool, percent: int = 0) -> void:
    exploration_label.visible = applicable
    if applicable:
        exploration_label.text = "探索度 " + str(clampi(percent, 0, 100)) + "%"


func _style_label(label: Label, font_size: int, font_color: Color) -> void:
    label.add_theme_font_size_override("font_size", font_size)
    label.add_theme_color_override("font_color", font_color)
    label.add_theme_color_override("font_shadow_color", Color(0.03, 0.06, 0.04, 0.95))
    label.add_theme_constant_override("shadow_offset_x", 1)
    label.add_theme_constant_override("shadow_offset_y", 2)
    var plate := StyleBoxFlat.new()
    plate.bg_color = Color(0.035, 0.075, 0.055, 0.78)
    plate.border_color = Color(0.72, 0.66, 0.43, 0.48)
    plate.set_border_width_all(1)
    plate.set_corner_radius_all(12)
    plate.content_margin_left = 10.0
    plate.content_margin_right = 10.0
    plate.content_margin_top = 5.0
    plate.content_margin_bottom = 5.0
    label.add_theme_stylebox_override("normal", plate)


func _style_button(button: Button, fill: Color, font_size: int) -> void:
    var normal := StyleBoxFlat.new()
    normal.bg_color = fill
    normal.border_color = fill.lightened(0.28)
    normal.set_border_width_all(2)
    normal.set_corner_radius_all(18)
    normal.content_margin_left = 8.0
    normal.content_margin_right = 8.0
    normal.content_margin_top = 6.0
    normal.content_margin_bottom = 6.0
    var hover := normal.duplicate() as StyleBoxFlat
    hover.bg_color = fill.lightened(0.12)
    var pressed := normal.duplicate() as StyleBoxFlat
    pressed.bg_color = fill.darkened(0.16)
    button.add_theme_stylebox_override("normal", normal)
    button.add_theme_stylebox_override("hover", hover)
    button.add_theme_stylebox_override("pressed", pressed)
    button.add_theme_color_override("font_color", Color(1.0, 0.97, 0.86))
    button.add_theme_color_override("font_hover_color", Color.WHITE)
    button.add_theme_font_size_override("font_size", font_size)

func set_gold(amount: int) -> void:
    gold_label.text = "金币：" + str(amount)

func set_wood(amount: int, cap: int) -> void:
    wood_label.text = "木材：" + str(amount) + "/" + str(cap)

func set_teleport_available(available: bool) -> void:
    teleport_button.disabled = not available

func set_interact_prompt(text: String) -> void:
    interact_button.text = text

func set_quest_text(text: String) -> void:
    quest_label.text = text

func show_message(text: String) -> void:
    message_label.text = text

func set_skill_cooldown(remaining: float, ready: bool) -> void:
    # The second argument is retained for call-site compatibility; active skill now uses team rage.
    cooldown_label.text = "怒气：" + str(int(remaining)) + "/10 · 技能需3格"

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
