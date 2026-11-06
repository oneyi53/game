class_name QuestManager
extends RefCounted

# Tracks the main quest and three side quests. Progress is plain
# counts; completing a quest flips a flag, reports a message and
# pays the reward from quests.json ("reward_gold", 0 for the main
# quest because the boss already pays 100 gold). Rewards live in
# the config, not in the save, so an old save without any reward
# field still completes cleanly and is never paid twice: a quest
# already marked completed in the save does not fire again.
# Old saves without a "quests" field load as all-zero progress.

signal quest_completed(quest_id, quest_name, complete_line, reward_gold)

var error_message: String = ""
var quests: Array = []
var counts: Dictionary = {}
var completed: Dictionary = {}

func load_quests() -> bool:
    var path: String = "res://data/quests.json"
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
        error_message = "quests.json 必须是数组"
        return false
    var seen: Dictionary = {}
    for entry in data:
        if not (entry is Dictionary):
            error_message = "quests.json 中有非对象条目"
            return false
        for field in ["id", "name", "type", "objective_type"]:
            if not entry.has(field):
                error_message = "quests.json 缺少字段：" + field
                return false
        if seen.has(entry["id"]):
            error_message = "quests.json 有重复 id：" + str(entry["id"])
            return false
        seen[entry["id"]] = true
        if not entry.has("reward_gold") or int(entry["reward_gold"]) < 0:
            error_message = "quests.json 缺少非负整数 reward_gold，id：" + str(entry["id"])
            return false
        if str(entry["objective_type"]) in ["kill", "chest"] and (not entry.has("count") or int(entry["count"]) <= 0):
            error_message = "quests.json 计数任务缺少正整数 count，id：" + str(entry["id"])
            return false
    quests = data
    for quest in quests:
        counts[str(quest["id"])] = 0
        completed[str(quest["id"])] = false
    return true

func load_progress(saved) -> void:
    if not (saved is Dictionary):
        return
    var saved_counts = saved.get("counts", {})
    var saved_completed = saved.get("completed", {})
    if saved_counts is Dictionary:
        for quest_id in counts.keys():
            if saved_counts.has(quest_id):
                counts[quest_id] = maxi(0, int(saved_counts[quest_id]))
    if saved_completed is Dictionary:
        for quest_id in completed.keys():
            if saved_completed.has(quest_id):
                completed[quest_id] = bool(saved_completed[quest_id])

func save_progress() -> Dictionary:
    return {"counts": counts.duplicate(), "completed": completed.duplicate()}

func is_completed(quest_id: String) -> bool:
    return bool(completed.get(quest_id, false))

func on_enemy_killed(enemy_id: String, is_boss: bool) -> void:
    for quest in quests:
        var quest_id: String = str(quest["id"])
        if completed[quest_id]:
            continue
        var objective: String = str(quest["objective_type"])
        # A boss quest with a target_id only completes on that boss,
        # so the elite quest cannot complete on the main boss kill.
        # A boss quest without target_id keeps the old any-boss rule.
        if objective == "boss" and is_boss and (not quest.has("target_id") or str(quest.get("target_id", "")) == "" or str(quest.get("target_id", "")) == enemy_id):
            _complete(quest)
        elif objective == "kill" and str(quest.get("target_id", "")) == enemy_id:
            counts[quest_id] = int(counts[quest_id]) + 1
            if int(counts[quest_id]) >= int(quest["count"]):
                _complete(quest)

func on_chest_opened() -> void:
    for quest in quests:
        var quest_id: String = str(quest["id"])
        if completed[quest_id]:
            continue
        if str(quest["objective_type"]) == "chest":
            counts[quest_id] = int(counts[quest_id]) + 1
            if int(counts[quest_id]) >= int(quest["count"]):
                _complete(quest)

func _complete(quest: Dictionary) -> void:
    var quest_id: String = str(quest["id"])
    completed[quest_id] = true
    quest_completed.emit(quest_id, str(quest["name"]), str(quest.get("complete_line", "")), int(quest.get("reward_gold", 0)))

func progress_rows() -> Array:
    var rows: Array = []
    for quest in quests:
        var quest_id: String = str(quest["id"])
        var done: bool = bool(completed.get(quest_id, false))
        var current: int = int(counts.get(quest_id, 0))
        var target: int = int(quest.get("count", 1))
        if str(quest.get("objective_type", "")) == "boss":
            current = 1 if done else 0
            target = 1
        rows.append({"id": quest_id, "name": str(quest["name"]), "current": current, "target": target, "done": done, "reward_gold": int(quest.get("reward_gold", 0))})
    return rows

func progress_lines() -> Array:
    var lines: Array = []
    for quest in quests:
        var quest_id: String = str(quest["id"])
        if completed[quest_id]:
            lines.append(str(quest["name"]) + "：已完成")
        elif str(quest["objective_type"]) == "boss":
            lines.append(str(quest["name"]) + "：击败" + str(quest.get("target", "古树守卫")))
        else:
            lines.append(str(quest["name"]) + "：" + str(int(counts[quest_id])) + "/" + str(int(quest["count"])))
    return lines
