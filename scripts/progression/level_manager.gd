class_name LevelManager
extends RefCounted

# Levels (data/levels.json). Killing monsters grants the whole party
# experience; on level-up, attack and max HP grow by a fixed percent
# per level, compounded on the base table values, and equipment
# bonuses are then applied on top (the equipment algorithm itself
# is untouched). Any missing file, broken JSON or invalid field is
# a startup error. Old saves without level data default to level 1.

var error_message: String = ""
var xp_per_kill: int = 0
var xp_per_boss: int = 0
var base_xp: int = 0
var xp_growth_per_level: int = 0
var max_level: int = 1
var attack_growth_pct_per_level: float = 0.0
var hp_growth_pct_per_level: float = 0.0
var levels: Dictionary = {}
var xp: Dictionary = {}

func load_all() -> bool:
    var path: String = "res://data/levels.json"
    if not FileAccess.file_exists(path):
        error_message = "缺少配置文件：" + path
        return false
    var text: String = FileAccess.get_file_as_string(path)
    if text == "":
        error_message = "配置文件为空：" + path
        return false
    var json = JSON.new()
    if json.parse(text) != OK:
        error_message = "配置文件不是合法 JSON：" + path
        return false
    var data = json.data
    if not (data is Dictionary):
        error_message = "levels.json 必须是对象"
        return false
    for field in ["xp_per_kill", "xp_per_boss", "base_xp", "xp_growth_per_level", "max_level", "attack_growth_pct_per_level", "hp_growth_pct_per_level"]:
        if not data.has(field):
            error_message = "levels.json 缺少字段：" + field
            return false
    xp_per_kill = int(data["xp_per_kill"])
    xp_per_boss = int(data["xp_per_boss"])
    base_xp = int(data["base_xp"])
    xp_growth_per_level = int(data["xp_growth_per_level"])
    max_level = int(data["max_level"])
    attack_growth_pct_per_level = float(data["attack_growth_pct_per_level"])
    hp_growth_pct_per_level = float(data["hp_growth_pct_per_level"])
    if xp_per_kill < 0 or xp_per_boss < 0 or base_xp <= 0 or xp_growth_per_level < 0 or max_level < 1 or attack_growth_pct_per_level < 0.0 or hp_growth_pct_per_level < 0.0:
        error_message = "levels.json 数值非法"
        return false
    return true

func load_saved(saved, hero_ids: Array) -> void:
    levels.clear()
    xp.clear()
    var saved_levels: Dictionary = {}
    var saved_xp: Dictionary = {}
    if saved is Dictionary:
        # Use get() with a default: indexing a missing key errors
        # even after a get() check, because get() does not insert.
        if saved.get("levels", {}) is Dictionary:
            saved_levels = saved.get("levels", {})
        if saved.get("xp", {}) is Dictionary:
            saved_xp = saved.get("xp", {})
    for hero_id in hero_ids:
        var hid: String = str(hero_id)
        levels[hid] = clampi(int(saved_levels.get(hid, 1)), 1, max_level)
        xp[hid] = maxi(0, int(saved_xp.get(hid, 0)))

func save_data() -> Dictionary:
    return {"levels": levels.duplicate(), "xp": xp.duplicate()}

func level(hero_id: String) -> int:
    return int(levels.get(hero_id, 1))

func xp_amount(hero_id: String) -> int:
    return int(xp.get(hero_id, 0))

func xp_needed(level_value: int) -> int:
    return base_xp + xp_growth_per_level * (level_value - 1)

func gain_xp(hero_id: String, amount: int) -> Dictionary:
    var current_level: int = level(hero_id)
    var current_xp: int = xp_amount(hero_id) + amount
    var gained: int = 0
    while current_level < max_level and current_xp >= xp_needed(current_level):
        current_xp -= xp_needed(current_level)
        current_level += 1
        gained += 1
    levels[hero_id] = current_level
    xp[hero_id] = current_xp
    return {"levels_gained": gained, "new_level": current_level}
