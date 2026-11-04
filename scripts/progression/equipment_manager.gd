class_name EquipmentManager
extends RefCounted

# Set-bonus counting only. Bonuses use just five attributes: attack,
# max health, defense, crit chance, attack speed. No new attributes
# are introduced here. A set bonus tier applies when a hero wears at
# least that many pieces of the set, and tiers stack (2 + 4 + 6).
# Swapping equips a whole set at once: one hero wears all six pieces
# of one set, so there is no per-piece inventory, upgrade or
# dismantle system. PRESET_EQUIPPED is only the starting state;
# the live state is "equipped", loaded from the save when present
# and saved back per hero as a single set id. A save without an
# "equipment" field (or with an unknown set id) keeps the preset
# for that hero instead of crashing.

const BONUS_KEYS: Array = ["attack_pct", "hp_pct", "defense_pct", "crit_pct", "crit_damage_pct", "attack_speed_pct"]
const SLOTS: Array = ["weapon", "helmet", "chest", "gloves", "boots", "accessory"]
const PRESET_EQUIPPED: Dictionary = {
    "captain": {"weapon": "dawn_vanguard", "helmet": "dawn_vanguard", "chest": "dawn_vanguard", "gloves": "dawn_vanguard", "boots": "dawn_vanguard", "accessory": "dawn_vanguard"},
    "guardian": {"weapon": "forest_bulwark", "helmet": "forest_bulwark", "chest": "forest_bulwark", "gloves": "forest_bulwark", "boots": "forest_bulwark", "accessory": "forest_bulwark"},
    "archer": {"weapon": "starfeather_hunt", "helmet": "starfeather_hunt", "chest": "starfeather_hunt", "gloves": "starfeather_hunt", "boots": "starfeather_hunt", "accessory": "starfeather_hunt"},
}

var error_message: String = ""
var sets: Dictionary = {}
var equipped: Dictionary = {}
var loose_equipped: Dictionary = {}
const LOOSE_SLOT_BY_ID: Dictionary = {
    "worn_iron_sword": "weapon",
    "rusty_dagger": "weapon",
    "rough_cloth_armor": "chest",
    "cracked_wooden_shield": "offhand",
    "worn_leather_boots": "boots",
    "vine_bracer": "gloves"
}

func load_sets() -> bool:
    var path: String = "res://data/equipment.json"
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
    if not (data is Array):
        error_message = "equipment.json 必须是数组"
        return false
    for entry in data:
        if not (entry is Dictionary):
            error_message = "equipment.json 中有非对象条目"
            return false
        for field in ["id", "name", "pieces", "bonus_2", "bonus_4", "bonus_6"]:
            if not entry.has(field):
                error_message = "equipment.json 缺少字段：" + field
                return false
        for tier in ["bonus_2", "bonus_4", "bonus_6"]:
            var bonus = entry[tier]
            if not (bonus is Dictionary):
                error_message = "equipment.json 套装加成必须是对象，id：" + str(entry["id"])
                return false
            for key in bonus.keys():
                if key not in BONUS_KEYS:
                    error_message = "equipment.json 出现未允许的加成属性：" + str(key)
                    return false
        sets[str(entry["id"])] = entry
    for hero_id in PRESET_EQUIPPED.keys():
        var loadout = PRESET_EQUIPPED[hero_id]
        if not (loadout is Dictionary):
            error_message = "预设穿戴必须是对象，英雄：" + str(hero_id)
            return false
        for set_id in loadout.values():
            if not sets.has(str(set_id)):
                error_message = "预设穿戴引用了不存在的套装：" + str(set_id)
                return false
    equipped = PRESET_EQUIPPED.duplicate(true)
    return true

func set_ids() -> Array:
    return sets.keys()

func set_name(set_id: String) -> String:
    if sets.has(set_id):
        return str(sets[set_id]["name"])
    return ""

func equipped_set_id_for_hero(hero_id: String) -> String:
    if not equipped.has(hero_id):
        return ""
    var loadout = equipped[hero_id]
    if not (loadout is Dictionary) or loadout.is_empty():
        return ""
    return str(loadout.values()[0])

func equip_set_for_hero(hero_id: String, set_id: String) -> bool:
    if not sets.has(set_id):
        return false
    var loadout: Dictionary = {}
    for slot in SLOTS:
        loadout[slot] = set_id
    equipped[hero_id] = loadout
    return true

func load_equipped(saved) -> void:
    if not (saved is Dictionary):
        return
    for hero_id in saved.keys():
        var set_id: String = str(saved[hero_id])
        if sets.has(set_id):
            equip_set_for_hero(str(hero_id), set_id)

func load_loose_equipped(saved, item_defs: Dictionary) -> void:
    loose_equipped.clear()
    if not (saved is Dictionary):
        return
    for hero_value in saved.keys():
        var hero_id: String = str(hero_value)
        var slots = saved[hero_value]
        if not (slots is Dictionary):
            continue
        for slot_value in slots.keys():
            var slot: String = str(slot_value)
            var item_id: String = str(slots[slot_value])
            if LOOSE_SLOT_BY_ID.get(item_id, "") != slot or not item_defs.has(item_id):
                continue
            if not loose_equipped.has(hero_id):
                loose_equipped[hero_id] = {}
            loose_equipped[hero_id][slot] = item_id

func equip_loose_item(hero_id: String, item_id: String, item_defs: Dictionary) -> Dictionary:
    var slot: String = str(LOOSE_SLOT_BY_ID.get(item_id, ""))
    if slot == "" or not item_defs.has(item_id):
        return {"ok": false, "replaced": ""}
    if not loose_equipped.has(hero_id):
        loose_equipped[hero_id] = {}
    var replaced: String = str(loose_equipped[hero_id].get(slot, ""))
    loose_equipped[hero_id][slot] = item_id
    return {"ok": true, "slot": slot, "replaced": replaced}

func unequip_loose_item(hero_id: String, slot: String) -> String:
    if not loose_equipped.has(hero_id) or not loose_equipped[hero_id].has(slot):
        return ""
    var item_id: String = str(loose_equipped[hero_id][slot])
    loose_equipped[hero_id].erase(slot)
    if loose_equipped[hero_id].is_empty():
        loose_equipped.erase(hero_id)
    return item_id

func loose_equipped_for_hero(hero_id: String) -> Dictionary:
    return loose_equipped.get(hero_id, {}).duplicate()

func save_loose_equipped() -> Dictionary:
    return loose_equipped.duplicate(true)

func loose_bonus_for_hero(hero_id: String, item_defs: Dictionary) -> Dictionary:
    var total: Dictionary = {"attack": 0, "hp": 0, "defense": 0}
    for item_id in loose_equipped_for_hero(hero_id).values():
        var entry = item_defs.get(str(item_id), null)
        if entry == null:
            continue
        for key in entry.get("stats", {}).keys():
            total[str(key)] = int(total.get(str(key), 0)) + int(entry["stats"][key])
    return total

func save_equipped() -> Dictionary:
    var out: Dictionary = {}
    for hero_id in equipped.keys():
        out[hero_id] = equipped_set_id_for_hero(hero_id)
    return out

func set_counts_for_hero(hero_id: String) -> Dictionary:
    var counts: Dictionary = {}
    if not equipped.has(hero_id):
        return counts
    var loose_slots: Dictionary = loose_equipped_for_hero(hero_id)
    for slot in equipped[hero_id].keys():
        if loose_slots.has(str(slot)):
            continue
        var key: String = str(equipped[hero_id][slot])
        counts[key] = int(counts.get(key, 0)) + 1
    return counts

func bonus_for_hero(hero_id: String) -> Dictionary:
    var total: Dictionary = {}
    for key in BONUS_KEYS:
        total[key] = 0
    var counts: Dictionary = set_counts_for_hero(hero_id)
    for set_id in counts.keys():
        var count: int = int(counts[set_id])
        var entry: Dictionary = sets[set_id]
        if count >= 2:
            _add_bonus(total, entry["bonus_2"])
        if count >= 4:
            _add_bonus(total, entry["bonus_4"])
        if count >= 6:
            _add_bonus(total, entry["bonus_6"])
    return total

func _add_bonus(total: Dictionary, bonus: Dictionary) -> void:
    for key in bonus.keys():
        total[key] = int(total[key]) + int(bonus[key])

func summary_lines(hero_name: String, hero_id: String) -> Array:
    var counts: Dictionary = set_counts_for_hero(hero_id)
    if counts.is_empty():
        return [str(hero_name) + "：未穿戴套装"]
    var lines: Array = []
    for set_id in counts.keys():
        var entry: Dictionary = sets[set_id]
        lines.append(str(hero_name) + "：" + str(entry["name"]) + " " + str(counts[set_id]) + " 件")
    return lines
