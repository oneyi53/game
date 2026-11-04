class_name RecruitmentManager
extends RefCounted

# Recruitment (data/recruitment.json). No paid gacha: heroes unlock
# by completing an existing quest, by collecting fragments dropped
# by ordinary monsters, or start already recruited (the captain).
# Any missing file, broken JSON or invalid field is a startup error.
# Save migration: an old save file without a "recruitment" field
# migrates to all heroes recruited (the old prototype started with
# the full roster), while a genuinely fresh game (no save file at
# all) starts with only the start-type heroes recruited.

var error_message: String = ""
var entries: Dictionary = {}
var entry_order: Array = []
var fragment_drop_chance: float = 0.0
var recruited: Dictionary = {}
var fragments: int = 0

func load_all(hero_ids: Array) -> bool:
    var path: String = "res://data/recruitment.json"
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
    if not (data is Dictionary) or not data.has("heroes") or not (data["heroes"] is Array):
        error_message = "recruitment.json 必须为对象且含 heroes 数组"
        return false
    if not data.has("fragment_drop_chance") or float(data["fragment_drop_chance"]) < 0.0 or float(data["fragment_drop_chance"]) > 1.0:
        error_message = "recruitment.json 缺少合法 fragment_drop_chance（0-1）"
        return false
    fragment_drop_chance = float(data["fragment_drop_chance"])
    for entry in data["heroes"]:
        if not (entry is Dictionary):
            error_message = "recruitment.json 中有非对象条目"
            return false
        for field in ["id", "unlock_type", "condition_text"]:
            if not entry.has(field):
                error_message = "recruitment.json 缺少字段：" + field
                return false
        var hero_id: String = str(entry["id"])
        if entries.has(hero_id):
            error_message = "recruitment.json 有重复 id：" + hero_id
            return false
        var unlock_type: String = str(entry["unlock_type"])
        if unlock_type == "quest" and (not entry.has("quest_id") or str(entry["quest_id"]) == ""):
            error_message = "recruitment.json 任务解锁缺少 quest_id，id：" + hero_id
            return false
        if unlock_type == "fragments" and (not entry.has("fragments_required") or int(entry["fragments_required"]) <= 0):
            error_message = "recruitment.json 碎片解锁缺少正整数 fragments_required，id：" + hero_id
            return false
        if unlock_type not in ["start", "quest", "fragments"]:
            error_message = "recruitment.json 未知 unlock_type，id：" + hero_id
            return false
        entries[hero_id] = entry
        entry_order.append(hero_id)
    for hero_id in hero_ids:
        if not entries.has(str(hero_id)):
            error_message = "recruitment.json 缺少英雄条目，id：" + str(hero_id)
            return false
    return true

func load_saved(saved, had_save: bool, hero_ids: Array) -> void:
    recruited.clear()
    fragments = 0
    var has_field: bool = saved is Dictionary and saved.has("recruited")
    if had_save and not has_field:
        # Old save from the full-roster prototype: keep everything.
        for hero_id in hero_ids:
            recruited[str(hero_id)] = true
        return
    if saved is Dictionary:
        if saved.has("fragments"):
            fragments = maxi(0, int(saved["fragments"]))
        var saved_recruited = saved.get("recruited", {})
        if saved_recruited is Dictionary:
            for hero_id in hero_ids:
                var hid: String = str(hero_id)
                if saved_recruited.has(hid):
                    recruited[hid] = bool(saved_recruited[hid])
                else:
                    recruited[hid] = _is_start_type(hid)
            return
    for hero_id in hero_ids:
        recruited[str(hero_id)] = _is_start_type(str(hero_id))

func _is_start_type(hero_id: String) -> bool:
    var entry = entries.get(hero_id, null)
    return entry != null and str(entry["unlock_type"]) == "start"

func save_data() -> Dictionary:
    return {"recruited": recruited.duplicate(), "fragments": fragments}

func entry(hero_id: String):
    return entries.get(hero_id, null)

func is_recruited(hero_id: String) -> bool:
    return bool(recruited.get(hero_id, false))

func recruited_count() -> int:
    var count: int = 0
    for hero_id in recruited.keys():
        if bool(recruited[hero_id]):
            count += 1
    return count

func recruit(hero_id: String) -> bool:
    if not entries.has(hero_id) or bool(recruited.get(hero_id, false)):
        return false
    recruited[hero_id] = true
    return true

func add_fragment() -> int:
    fragments += 1
    return fragments

func synthesize_with_fragments(hero_id: String) -> bool:
    if not entries.has(hero_id) or is_recruited(hero_id):
        return false
    var entry_data: Dictionary = entries[hero_id]
    if str(entry_data.get("unlock_type", "")) != "fragments":
        return false
    var cost: int = fragments_required(hero_id)
    if cost <= 0 or fragments < cost:
        return false
    # Commit both state changes together so a successful synthesis
    # cannot recruit the hero while leaving the fragment balance intact.
    recruited[hero_id] = true
    fragments -= cost
    return true

func fragments_required(hero_id: String) -> int:
    var entry = entries.get(hero_id, null)
    if entry == null:
        return 0
    return int(entry.get("fragments_required", 0))

func hero_id_for_quest(quest_id: String) -> String:
    for hero_id in entry_order:
        var entry = entries[hero_id]
        if str(entry["unlock_type"]) == "quest" and str(entry.get("quest_id", "")) == quest_id:
            return hero_id
    return ""
