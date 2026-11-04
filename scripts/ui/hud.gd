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
signal map_pressed

@onready var gold_label: Label = $GoldLabel
@onready var wood_label: Label = $WoodLabel
@onready var message_label: Label = $MessageLabel
@onready var quest_label: RichTextLabel = $QuestLabel
@onready var quest_toggle_button: Button = $QuestToggleButton
var quest_text_full: String = ""
var quest_expanded: bool = true
@onready var skill_button: Button = $SkillButton
@onready var interact_button: Button = $InteractButton
@onready var save_button: Button = $SaveButton
@onready var hero_button: Button = $HeroButton
@onready var equip_button: Button = $EquipButton
@onready var camp_button: Button = $CampButton
@onready var backpack_button: Button = $BackpackButton
@onready var recruit_button: Button = $RecruitButton
@onready var map_button: Button = $MapButton
@onready var cooldown_label: Label = $CooldownLabel

func _ready() -> void:
    skill_button.pressed.connect(_on_skill_button_pressed)
    interact_button.pressed.connect(_on_interact_button_pressed)
    save_button.pressed.connect(_on_save_button_pressed)
    hero_button.pressed.connect(_on_hero_button_pressed)
    equip_button.pressed.connect(_on_equip_button_pressed)
    camp_button.pressed.connect(_on_camp_button_pressed)
    backpack_button.pressed.connect(_on_backpack_button_pressed)
    recruit_button.pressed.connect(_on_recruit_button_pressed)
    map_button.pressed.connect(func(): map_pressed.emit())
    quest_toggle_button.pressed.connect(_on_quest_toggle_pressed)
    _apply_quest_display()

func set_gold(amount: int) -> void:
    gold_label.text = "金币：" + str(amount)

func set_wood(amount: int, cap: int) -> void:
    wood_label.text = "木材：" + str(amount) + "/" + str(cap)

func set_quest_text(text: String) -> void:
    quest_text_full = text
    _apply_quest_display()

func _apply_quest_display() -> void:
    if quest_label == null or quest_toggle_button == null:
        return
    quest_label.clear()
    if not quest_expanded:
        quest_label.append_text("[b]任务追踪[/b]")
        quest_toggle_button.text = "展开"
        return
    var active_lines: Array[String] = []
    var completed_lines: Array[String] = []
    for line in quest_text_full.split("\n", false):
        if str(line).contains("：已完成"):
            completed_lines.append(str(line))
        elif str(line) != "":
            active_lines.append(str(line))
    quest_label.append_text("[b]任务追踪[/b]\n")
    for line in active_lines:
        quest_label.append_text("• " + line + "\n")
    for line in completed_lines:
        quest_label.append_text("[color=#aab2a0]✓ " + line + "[/color]\n")
    quest_toggle_button.text = "收起"

func _on_quest_toggle_pressed() -> void:
    quest_expanded = not quest_expanded
    _apply_quest_display()

func show_message(text: String) -> void:
    message_label.text = text

func set_skill_cooldown(remaining: float, ready: bool) -> void:
    if ready:
        cooldown_label.text = "技能就绪"
    else:
        cooldown_label.text = "技能冷却：" + ("%.1f" % remaining) + " 秒"

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
