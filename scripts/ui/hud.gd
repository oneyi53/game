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

func set_gold(amount: int) -> void:
    gold_label.text = "金币：" + str(amount)

func set_wood(amount: int, cap: int) -> void:
    wood_label.text = "木材：" + str(amount) + "/" + str(cap)

func set_teleport_available(available: bool) -> void:
    teleport_button.disabled = not available

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
