class_name OfflineManager
extends RefCounted

# Offline earnings are deliberately local and conservative. The client
# cannot prove wall-clock integrity without a trusted external source;
# this manager classifies detectable timestamp anomalies and enforces
# the configured payout cap, but does not claim to prevent save editing
# or repeated forward-clock manipulation.
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
    error_message = ""
    return true

func _empty_settlement(reason: String, elapsed: int = 0) -> Dictionary:
    return {
        "eligible": false,
        "reason": reason,
        "elapsed_seconds": maxi(0, elapsed),
        "billed_seconds": 0,
        "gold": 0,
        "wood": 0
    }

func settle(now_unix: int, last_saved_unix, current_wood: int, wood_cap: int) -> Dictionary:
    # A missing legacy timestamp is not an anomaly: it simply has no
    # historical interval to settle. Malformed and future timestamps
    # are distinguished so callers/tests can observe clock rollback.
    if not (last_saved_unix is int or last_saved_unix is float):
        return _empty_settlement("no_timestamp")
    var last_value: float = float(last_saved_unix)
    if not is_finite(last_value) or last_value <= 0.0:
        return _empty_settlement("invalid_timestamp")
    if now_unix <= 0:
        return _empty_settlement("invalid_now")
    var last: int = int(last_value)
    if now_unix < last:
        return _empty_settlement("clock_rollback")
    var elapsed: int = now_unix - last
    if elapsed < min_minutes * 60:
        return _empty_settlement("below_threshold", elapsed)
    var billed: int = mini(elapsed, cap_hours * 3600)
    var gold: int = int(float(billed) / 3600.0 * float(gold_per_hour))
    var wood: int = int(float(billed) / 3600.0 * float(wood_per_hour))
    wood = mini(wood, maxi(0, wood_cap - current_wood))
    return {
        "eligible": true,
        "reason": "ok" if elapsed <= cap_hours * 3600 else "capped",
        "elapsed_seconds": elapsed,
        "billed_seconds": billed,
        "gold": gold,
        "wood": wood
    }
