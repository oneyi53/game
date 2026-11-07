class_name OfflineManager
extends RefCounted

# Simplified offline earnings (data/offline.json). Only gold and
# wood are ever granted: no loose items, no experience, no quest
# progress. The learning outline gives no hourly rates and no
# 8/12-hour distinction, so the table's rates, the 10-minute
# threshold and the unified 8-hour cap are draft assumptions
# recorded in offline.json's note, not outline quotations.
# Settlement is pure: settle() computes from (now, last saved,
# current gold/wood, wood cap) and never mutates state; Main
# applies the result, shows the panel, then saves at once so the
# same offline span cannot be claimed twice. An old save without
# last_saved_unix gets no retroactive earnings: the first load
# only stamps the timestamp on the next save.

var error_message: String = ""
var gold_per_hour: int = 0
var wood_per_hour: int = 0
var cap_hours: int = 0
var min_minutes: int = 0

func load_all() -> bool:
    if not FileAccess.file_exists("res://data/offline.json"):
        error_message = "缺少配置文件：res://data/offline.json"
        return false
    var text: String = FileAccess.get_file_as_string("res://data/offline.json")
    if text == "":
        error_message = "配置文件为空：res://data/offline.json"
        return false
    var json = JSON.new()
    if json.parse(text) != OK:
        error_message = "配置文件不是合法 JSON：res://data/offline.json"
        return false
    var data = json.data
    if not (data is Dictionary):
        error_message = "offline.json 必须为对象"
        return false
    for field in ["gold_per_hour", "wood_per_hour", "cap_hours", "min_minutes"]:
        if not data.has(field):
            error_message = "offline.json 缺少字段：" + field
            return false
    gold_per_hour = int(data["gold_per_hour"])
    wood_per_hour = int(data["wood_per_hour"])
    cap_hours = int(data["cap_hours"])
    min_minutes = int(data["min_minutes"])
    if gold_per_hour < 0 or wood_per_hour < 0 or cap_hours <= 0 or min_minutes < 0:
        error_message = "offline.json 数值非法：每小时收益不能为负，封顶小时必须为正，阈值分钟不能为负"
        return false
    return true

func settle(now_unix: int, last_saved_unix, current_wood: int, wood_cap: int) -> Dictionary:
    # Returns {eligible, reason, elapsed_seconds, billed_seconds,
    # gold, wood, wood_capped, cap_hours}. last_saved_unix may be absent (old save) or
    # non-numeric (hand-edited save): both mean "no earnings",
    # never a crash and never a retroactive payout.
    if not (last_saved_unix is int or last_saved_unix is float):
        return {"eligible": false, "reason": "no_timestamp", "elapsed_seconds": 0, "billed_seconds": 0, "gold": 0, "wood": 0, "wood_capped": false, "cap_hours": cap_hours}
    var last: int = int(last_saved_unix)
    if last <= 0 or now_unix < last:
        return {"eligible": false, "reason": "no_timestamp", "elapsed_seconds": 0, "billed_seconds": 0, "gold": 0, "wood": 0, "wood_capped": false, "cap_hours": cap_hours}
    var elapsed: int = now_unix - last
    if elapsed < min_minutes * 60:
        return {"eligible": false, "reason": "below_threshold", "elapsed_seconds": elapsed, "billed_seconds": 0, "gold": 0, "wood": 0, "wood_capped": false, "cap_hours": cap_hours}
    var billed: int = mini(elapsed, cap_hours * 3600)
    var gold: int = int(float(billed) / 3600.0 * float(gold_per_hour))
    var raw_wood: int = int(float(billed) / 3600.0 * float(wood_per_hour))
    var wood_room: int = maxi(0, wood_cap - current_wood)
    var wood_capped: bool = raw_wood > wood_room
    var wood: int = mini(raw_wood, wood_room)
    return {"eligible": true, "reason": "ok", "elapsed_seconds": elapsed, "billed_seconds": billed, "gold": gold, "wood": wood, "wood_capped": wood_capped, "cap_hours": cap_hours}
