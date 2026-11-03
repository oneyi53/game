class_name HeroPanel
extends Control

# Shows only attributes that exist in data and are actually used:
# name, role, current/max health, attack, defense, move speed and range.
# No unimplemented attribute is shown.

@onready var panel_label: RichTextLabel = $PanelLabel

var heroes: Array = []

func set_heroes(p_heroes: Array) -> void:
    heroes = p_heroes
    refresh()

func refresh() -> void:
    if panel_label == null:
        return
    var lines: Array = []
    for hero in heroes:
        if hero == null:
            continue
        lines.append(
            str(hero.hero_name) + "（" + str(hero.data.get("role", "")) + "）"
            + " 等级 " + str(hero.level)
            + " 生命 " + str(hero.hp) + "/" + str(hero.max_hp)
            + " 攻击 " + str(hero.attack)
            + " 防御 " + str(hero.defense)
            + " 移速 " + str(int(hero.move_speed))
            + " 范围 " + str(int(hero.attack_range))
        )
    var text: String = ""
    for line in lines:
        text += str(line) + "\n"
    panel_label.text = text.strip_edges()
