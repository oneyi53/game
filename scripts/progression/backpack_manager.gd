class_name BackpackManager
extends RefCounted

# Backpack + loose items (data/loose_items.json) + mailbox overflow.
# Rules from the study outline, section 4, verbatim: backpack cap
# 250 items, decompose is about 1 gold, a full backpack overflows
# to the mailbox. What the outline does NOT specify is the mailbox
# claim flow, so this block uses the smallest possible design for
# it: overflow items sit in the mailbox list in the save, and the
# backpack panel offers one claim button per mailbox item; claiming
# moves the item into the backpack only when there is a free slot,
# otherwise it stays in the mailbox with a HUD prompt. That claim
# flow is this block's assumption, not an outline quote.
# Loose items are single pieces: they never count toward any set,
# never trigger set bonuses, and are never worn, upgraded or
# combined in this block. They are only collected, viewed and
# decomposed. Save field "backpack": {"items": [...], "mailbox": [...]}.
# An old save without that field defaults to both lists empty.
# Unknown ids in a save are ignored, never a crash.

var error_message: String = ""
var backpack_cap: int = 250
var decompose_gold: int = 1
var drop_chance: float = 0.2
var drop_min: int = 1
var drop_max: int = 1
var items: Dictionary = {}
var item_order: Array = []
var backpack: Array = []
var mailbox: Array = []

const ALLOWED_STATS: Array = ["attack", "hp", "defense"]

func load_all() -> bool:
    var data = _load_json("res://data/loose_items.json")
    if data == null:
        return false
    if not (data is Dictionary):
        error_message = "loose_items.json 必须为对象"
        return false
    if not data.has("backpack_cap") or int(data["backpack_cap"]) <= 0:
        error_message = "loose_items.json 缺少正整数 backpack_cap"
        return false
    backpack_cap = int(data["backpack_cap"])
    if not data.has("decompose_gold") or int(data["decompose_gold"]) < 0:
        error_message = "loose_items.json 缺少非负整数 decompose_gold"
        return false
    decompose_gold = int(data["decompose_gold"])
    if not data.has("drop") or not (data["drop"] is Dictionary):
        error_message = "loose_items.json 缺少 drop 对象"
        return false
    var drop = data["drop"]
    if not drop.has("chance") or not drop.has("min") or not drop.has("max"):
        error_message = "loose_items.json 的 drop 缺少 chance/min/max"
        return false
    if float(drop["chance"]) < 0.0 or float(drop["chance"]) > 1.0 or int(drop["min"]) < 1 or int(drop["max"]) < int(drop["min"]):
        error_message = "loose_items.json 的 drop 数值非法"
        return false
    drop_chance = float(drop["chance"])
    drop_min = int(drop["min"])
    drop_max = int(drop["max"])
    if not data.has("items") or not (data["items"] is Array) or data["items"].is_empty():
        error_message = "loose_items.json 的 items 必须为非空数组"
        return false
    for entry in data["items"]:
        if not (entry is Dictionary):
            error_message = "loose_items.json 中有非对象条目"
            return false
        for field in ["id", "name", "stats"]:
            if not entry.has(field):
                error_message = "loose_items.json 缺少字段：" + field
                return false
        if items.has(str(entry["id"])):
            error_message = "loose_items.json 有重复 id：" + str(entry["id"])
            return false
        var stats = entry["stats"]
        if not (stats is Dictionary) or stats.is_empty() or stats.size() > 2:
            error_message = "loose_items.json 的散件属性必须为 1-2 项，id：" + str(entry["id"])
            return false
        for stat in stats.keys():
            if not ALLOWED_STATS.has(str(stat)) or int(stats[stat]) <= 0:
                error_message = "loose_items.json 的散件属性非法，id：" + str(entry["id"])
                return false
        items[str(entry["id"])] = entry
        item_order.append(str(entry["id"]))
    return true

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

func item(item_id: String):
    return items.get(item_id, null)

func is_full() -> bool:
    return backpack.size() >= backpack_cap

func add(item_id: String) -> String:
    # Returns "backpack", "mailbox" (overflow, per the outline), or
    # "" for an unknown id. Never drops the item on the floor.
    if not items.has(item_id):
        return ""
    if is_full():
        mailbox.append(item_id)
        return "mailbox"
    backpack.append(item_id)
    return "backpack"

func remove_at(index: int) -> bool:
    if index < 0 or index >= backpack.size():
        return false
    backpack.remove_at(index)
    return true

func claim_at(index: int) -> bool:
    if index < 0 or index >= mailbox.size():
        return false
    if is_full():
        return false
    backpack.append(mailbox[index])
    mailbox.remove_at(index)
    return true

func stats_text(item_id: String) -> String:
    var entry = item(item_id)
    if entry == null:
        return ""
    var stats = entry["stats"]
    var parts: Array = []
    if stats.has("attack"):
        parts.append("攻击 +" + str(int(stats["attack"])))
    if stats.has("hp"):
        parts.append("生命 +" + str(int(stats["hp"])))
    if stats.has("defense"):
        parts.append("防御 +" + str(int(stats["defense"])))
    var text: String = ""
    for part in parts:
        if text != "":
            text += "、"
        text += str(part)
    return text

func load_saved(saved) -> void:
    if not (saved is Dictionary):
        return
    var saved_items = saved.get("items", [])
    if saved_items is Array:
        for item_id in saved_items:
            if items.has(str(item_id)):
                backpack.append(str(item_id))
    var saved_mailbox = saved.get("mailbox", [])
    if saved_mailbox is Array:
        for item_id in saved_mailbox:
            if items.has(str(item_id)):
                mailbox.append(str(item_id))

func save_data() -> Dictionary:
    return {"items": backpack.duplicate(), "mailbox": mailbox.duplicate()}
