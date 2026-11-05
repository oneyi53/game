class_name DataLoader
extends RefCounted

# Loads data/heroes.json, data/enemies.json and data/items.json.
# Any missing file, broken JSON or invalid field is a startup error:
# error_message is set and load_all() returns false. No default data
# is ever substituted, so a bad table cannot silently change gameplay.

var error_message: String = ""
var heroes: Array = []
var enemies: Dictionary = {}
var boss_id: String = ""
var elite_boss_id: String = ""
var items: Dictionary = {}

const HERO_FIELDS: Array = ["id", "name", "role", "hp", "attack", "defense", "move_speed", "attack_range", "attack_cooldown", "color"]
const ENEMY_FIELDS: Array = ["id", "name", "hp", "attack", "defense", "move_speed", "attack_range", "attack_cooldown", "aggro_range", "is_boss", "color"]

func load_all() -> bool:
    # Stage every table locally. A failed load must never publish a partial
    # mixture of old and new configuration to the rest of the game.
    var heroes_data = _load_json("res://data/heroes.json")
    if heroes_data == null:
        return false
    if not _validate_heroes(heroes_data):
        return false

    var enemies_data = _load_json("res://data/enemies.json")
    if enemies_data == null:
        return false
    var enemy_result = _validate_enemies(enemies_data)
    if enemy_result == null:
        return false

    var items_data = _load_json("res://data/items.json")
    if items_data == null:
        return false
    if not _validate_items(items_data):
        return false

    # Commit the new snapshot only after all three files pass validation.
    heroes = heroes_data
    enemies = enemy_result["enemies"]
    boss_id = enemy_result["boss_id"]
    elite_boss_id = enemy_result["elite_boss_id"]
    items = items_data
    error_message = ""
    return true

func _is_number(value) -> bool:
    return typeof(value) == TYPE_INT or typeof(value) == TYPE_FLOAT

func _is_non_empty_string(value) -> bool:
    return typeof(value) == TYPE_STRING and not str(value).strip_edges().is_empty()

func _load_json(path: String):
    if not FileAccess.file_exists(path):
        error_message = "缺少配置文件：" + path
        return null
    var text: String = FileAccess.get_file_as_string(path)
    if text == "":
        error_message = "配置文件为空：" + path
        return null
    var json = JSON.new()
    if json.parse(text) != OK:
        error_message = "配置文件不是合法 JSON：" + path
        return null
    return json.data

func _validate_heroes(data) -> bool:
    if not (data is Array):
        error_message = "heroes.json 必须是数组"
        return false
    if data.size() == 0:
        error_message = "heroes.json 不能为空"
        return false
    var seen: Dictionary = {}
    for entry in data:
        if not (entry is Dictionary):
            error_message = "heroes.json 中有非对象条目"
            return false
        for field in HERO_FIELDS:
            if not entry.has(field):
                error_message = "heroes.json 缺少字段：" + field
                return false
        if not _is_non_empty_string(entry["id"]):
            error_message = "heroes.json 的 id 必须是非空字符串，实际：" + str(entry["id"])
            return false
        if seen.has(entry["id"]):
            error_message = "heroes.json 有重复 id：" + str(entry["id"])
            return false
        var numeric_fields: Array = ["hp", "move_speed", "attack_range", "attack_cooldown"]
        for field in numeric_fields:
            if not _is_number(entry[field]):
                error_message = "heroes.json 数值字段类型非法，id：" + str(entry["id"]) + "，字段：" + field
                return false
        seen[entry["id"]] = true
        if int(entry["hp"]) <= 0 or float(entry["move_speed"]) <= 0.0 or float(entry["attack_range"]) <= 0.0 or float(entry["attack_cooldown"]) <= 0.0:
            error_message = "heroes.json 数值非法，id：" + str(entry["id"])
            return false
    return true

# Returns a validated snapshot, or null on failure. Does not mutate the
# currently published enemy/Boss state while validation is in progress.
func _validate_enemies(data):
    if not (data is Array):
        error_message = "enemies.json 必须是数组"
        return null
    var validated_enemies: Dictionary = {}
    var validated_boss_id: String = ""
    var validated_elite_boss_id: String = ""
    var boss_count: int = 0
    for entry in data:
        if not (entry is Dictionary):
            error_message = "enemies.json 中有非对象条目"
            return null
        for field in ENEMY_FIELDS:
            if not entry.has(field):
                error_message = "enemies.json 缺少字段：" + field
                return null
        if not _is_non_empty_string(entry["id"]):
            error_message = "enemies.json 的 id 必须是非空字符串，实际：" + str(entry["id"])
            return null
        if validated_enemies.has(entry["id"]):
            error_message = "enemies.json 有重复 id：" + str(entry["id"])
            return null
        var numeric_fields: Array = ["hp", "move_speed", "attack_range", "attack_cooldown", "aggro_range"]
        for field in numeric_fields:
            if not _is_number(entry[field]):
                error_message = "enemies.json 数值字段类型非法，id：" + str(entry["id"]) + "，字段：" + field
                return null
        if typeof(entry["is_boss"]) != TYPE_BOOL:
            error_message = "enemies.json 的 is_boss 必须是布尔值，id：" + str(entry["id"])
            return null
        if int(entry["hp"]) <= 0 or float(entry["move_speed"]) <= 0.0 or float(entry["attack_range"]) <= 0.0 or float(entry["attack_cooldown"]) <= 0.0 or float(entry["aggro_range"]) <= 0.0:
            error_message = "enemies.json 数值非法，id：" + str(entry["id"])
            return null
        if entry["is_boss"]:
            boss_count += 1
            var role = entry.get("boss_role", "main")
            if typeof(role) != TYPE_STRING or (role != "main" and role != "elite"):
                error_message = "enemies.json 的 boss_role 只能是 main 或 elite，id：" + str(entry["id"])
                return null
            if role == "elite":
                if validated_elite_boss_id != "":
                    error_message = "enemies.json 只能有一个精英 BOSS"
                    return null
                validated_elite_boss_id = entry["id"]
            else:
                if validated_boss_id != "":
                    error_message = "enemies.json 只能有一个主线 BOSS"
                    return null
                validated_boss_id = entry["id"]
            if not entry.has("leash_range") or not entry.has("reward_gold"):
                error_message = "BOSS 条目缺少 leash_range 或 reward_gold，id：" + str(entry["id"])
                return null
            if not _is_number(entry["leash_range"]) or float(entry["leash_range"]) <= 0.0 or not _is_number(entry["reward_gold"]) or int(entry["reward_gold"]) < 0:
                error_message = "BOSS 条目 leash_range/reward_gold 数值非法，id：" + str(entry["id"])
                return null
        validated_enemies[entry["id"]] = entry

    if boss_count < 1 or boss_count > 2 or validated_boss_id == "" or (boss_count == 2 and validated_elite_boss_id == ""):
        error_message = "enemies.json 必须有 1 个主线 BOSS 和至多 1 个精英 BOSS，实际 BOSS 数为 " + str(boss_count)
        return null
    return {
        "enemies": validated_enemies,
        "boss_id": validated_boss_id,
        "elite_boss_id": validated_elite_boss_id
    }

func _validate_items(data) -> bool:
    if not (data is Dictionary):
        error_message = "items.json 必须为对象"
        return false
    if not data.has("chest_loot"):
        error_message = "items.json 缺少 chest_loot"
        return false
    var loot = data["chest_loot"]
    if not (loot is Dictionary) or not loot.has("gold"):
        error_message = "items.json 的 chest_loot.gold 必须为正整数"
        return false
    if not _is_number(loot["gold"]):
        error_message = "items.json 的 chest_loot.gold 必须是数字"
        return false
    if int(loot["gold"]) <= 0:
        error_message = "items.json 的 chest_loot.gold 必须为正整数"
        return false
    if not data.has("wood_cap"):
        error_message = "items.json 缺少正整数 wood_cap"
        return false
    if not _is_number(data["wood_cap"]):
        error_message = "items.json 的 wood_cap 必须是数字"
        return false
    if int(data["wood_cap"]) <= 0:
        error_message = "items.json 缺少正整数 wood_cap"
        return false
    if not data.has("wood_drop") or not (data["wood_drop"] is Dictionary):
        error_message = "items.json 缺少 wood_drop 对象"
        return false
    var wood_drop = data["wood_drop"]
    if not wood_drop.has("chance") or not wood_drop.has("min") or not wood_drop.has("max"):
        error_message = "items.json 的 wood_drop 缺少 chance/min/max"
        return false
    if not _is_number(wood_drop["chance"]) or not _is_number(wood_drop["min"]) or not _is_number(wood_drop["max"]):
        error_message = "items.json 的 wood_drop 数值字段类型非法"
        return false
    if float(wood_drop["chance"]) < 0.0 or float(wood_drop["chance"]) > 1.0 or int(wood_drop["min"]) < 1 or int(wood_drop["max"]) < int(wood_drop["min"]):
        error_message = "items.json 的 wood_drop 数值非法"
        return false
    return true

func get_enemy(enemy_id: String):
    if not enemies.has(enemy_id):
        error_message = "找不到敌人配置：" + enemy_id
        return null
    return enemies[enemy_id]
