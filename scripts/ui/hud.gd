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
signal quest_pressed
signal offline_pressed

@onready var gold_label: Label = $GoldLabel
@onready var wood_label: Label = $WoodLabel
@onready var message_label: Label = $MessageLabel
@onready var power_label: Label = $PowerLabel
@onready var avatar_level_label: Label = $AvatarLevelLabel
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
@onready var quest_button: Button = $QuestButton
@onready var offline_button: Button = $OfflineButton
@onready var boss_banner: ColorRect = $BossBanner
@onready var boss_banner_label: Label = $BossBanner/BossBannerLabel
@onready var quest_panel: Control = $"../QuestPanel"
@onready var quest_label: Label = $"../QuestPanel/QuestLabel"
@onready var quest_close_button: Button = $"../QuestPanel/QuestCloseButton"

# Start true so the first set_combat_mode(false) in _ready actually hides
# the skill controls (their .tscn default is visible).
var _combat_mode: bool = true

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
    quest_button.pressed.connect(_on_quest_button_pressed)
    offline_button.pressed.connect(_on_offline_button_pressed)
    quest_close_button.pressed.connect(_on_quest_close_button_pressed)
    teleport_button.disabled = true
    quest_panel.visible = false
    set_combat_mode(false)

func set_gold(amount: int) -> void:
    gold_label.text = "金币：" + str(amount)

func set_wood(amount: int, cap: int) -> void:
    wood_label.text = "木材：" + str(amount) + "/" + str(cap)

func set_power(total: int) -> void:
    power_label.text = "战力 " + str(total)

func set_avatar_level(level: int) -> void:
    avatar_level_label.text = "Lv." + str(level)

func set_teleport_available(available: bool) -> void:
    teleport_button.disabled = not available

func set_quest_text(text: String) -> void:
    quest_label.text = text

func set_boss_banner(show: bool, boss_name: String = "") -> void:
    boss_banner.visible = show
    if show:
        boss_banner_label.text = "击杀BOSS " + boss_name

func toggle_quest_panel() -> void:
    quest_panel.visible = not quest_panel.visible

func show_message(text: String) -> void:
    message_label.text = text

# Skill / interact only exist in combat. In town the main screen has
# no skill buttons, matching the reference layout.
func set_combat_mode(in_combat: bool) -> void:
    if in_combat == _combat_mode:
        return
    _combat_mode = in_combat
    skill_button.visible = in_combat
    interact_button.visible = in_combat
    cooldown_label.visible = in_combat

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

func _on_teleport_button_pressed() -> void:
    teleport_pressed.emit()

func _on_map_button_pressed() -> void:
    map_pressed.emit()

func _on_quest_button_pressed() -> void:
    quest_pressed.emit()

func _on_offline_button_pressed() -> void:
    offline_pressed.emit()

func _on_quest_close_button_pressed() -> void:
    quest_panel.visible = false
