class_name QuestManager
extends RefCounted

# Tracks quest objectives and rewards. Configuration reloads preserve progress
# for IDs that still exist; removed IDs are pruned and new IDs start at zero.
signal quest_completed(quest_id, quest_name, complete_line, reward_gold)

var error_message: String = ""
var quests: Array = []
var counts: Dictionary = {}
var completed: Dictionary = {}

func load_quests(config_path: String = "res://data/quests.json") -> bool:
	if not FileAccess.file_exists(config_path):
		error_message = "缺少配置文件：" + config_path
		return false
	var text: String = FileAccess.get_file_as_string(config_path)
	if text == "":
		error_message = "配置文件为空：" + config_path
		return false
	var json = JSON.new()
	if json.parse(text) != OK:
		error_message = "配置文件不是合法 JSON：" + config_path
		return false
	var data = json.data
	if not (data is Array):
		error_message = "quests.json 必须是数组"
		return false

	# Validate into local snapshots. Runtime state is untouched until every
	# structural, scalar, objective and dependency check has succeeded.
	var seen: Dictionary = {}
	var quest_by_id: Dictionary = {}
	for entry in data:
		if not (entry is Dictionary):
			error_message = "quests.json 中有非对象条目"
			return false
		for field in ["id", "name", "type", "objective_type"]:
			if not entry.has(field):
				error_message = "quests.json 缺少字段：" + field
				return false
		if typeof(entry["id"]) != TYPE_STRING or str(entry["id"]).strip_edges() == "":
			error_message = "quests.json id 必须是非空字符串"
			return false
		var quest_id: String = entry["id"]
		if seen.has(quest_id):
			error_message = "quests.json 有重复 id：" + quest_id
			return false
		seen[quest_id] = true
		quest_by_id[quest_id] = entry
		if typeof(entry["reward_gold"]) != TYPE_INT or int(entry["reward_gold"]) < 0:
			error_message = "quests.json reward_gold 必须是非负整数，id：" + quest_id
			return false
		var objective_type: String = str(entry["objective_type"])
		if objective_type in ["kill", "chest", "harvest", "explore", "deliver"]:
			if not entry.has("count") or typeof(entry["count"]) != TYPE_INT or int(entry["count"]) <= 0:
				error_message = "quests.json count 必须是正整数，id：" + quest_id
				return false

	var supported_objectives: Array[String] = ["kill", "boss", "chest", "harvest", "explore", "deliver"]
	for entry in data:
		var objective_type: String = str(entry["objective_type"])
		var quest_id: String = str(entry["id"])
		if objective_type not in supported_objectives:
			error_message = "quests.json 未知 objective_type：" + objective_type
			return false
		if objective_type in ["harvest", "explore", "deliver"] and (typeof(entry.get("target_id", null)) != TYPE_STRING or str(entry.get("target_id", "")).strip_edges() == ""):
			error_message = "quests.json 新目标类型缺少有效 target_id，id：" + quest_id
			return false
		if objective_type == "deliver" and (typeof(entry.get("item_id", null)) != TYPE_STRING or str(entry.get("item_id", "")).strip_edges() == ""):
			error_message = "交付任务缺少有效 item_id，id：" + quest_id
			return false

	for entry in data:
		var quest_id: String = str(entry["id"])
		var prerequisite_value = entry.get("prerequisite", "")
		if typeof(prerequisite_value) != TYPE_STRING:
			error_message = "quests.json prerequisite 必须是字符串，id：" + quest_id
			return false
		var prerequisite: String = prerequisite_value
		if prerequisite != "" and not seen.has(prerequisite):
			error_message = "quests.json 前置任务不存在：" + prerequisite
			return false
		# Walk each prerequisite chain. A repeated node means a self-loop or
		# a multi-node cycle; no recursive call stack is needed.
		var visited: Dictionary = {}
		var cursor: String = quest_id
		while true:
			var next_value = quest_by_id[cursor].get("prerequisite", "")
			if next_value == "":
				break
			var next_id: String = str(next_value)
			if visited.has(next_id) or next_id == quest_id:
				error_message = "quests.json 前置任务存在循环依赖：" + quest_id
				return false
			visited[next_id] = true
			cursor = next_id

	var next_counts: Dictionary = {}
	var next_completed: Dictionary = {}
	for quest in data:
		var quest_id: String = str(quest["id"])
		next_counts[quest_id] = maxi(0, int(counts.get(quest_id, 0)))
		next_completed[quest_id] = bool(completed.get(quest_id, false))
	quests = data.duplicate(true)
	counts = next_counts
	completed = next_completed
	error_message = ""
	return true

func load_progress(saved) -> void:
	if not (saved is Dictionary):
		return
	var saved_counts = saved.get("counts", {})
	var saved_completed = saved.get("completed", {})
	if saved_counts is Dictionary:
		for quest_id in counts.keys():
			if saved_counts.has(quest_id):
				var value = saved_counts[quest_id]
				if typeof(value) == TYPE_INT:
					counts[quest_id] = maxi(0, value)
	if saved_completed is Dictionary:
		for quest_id in completed.keys():
			if saved_completed.has(quest_id) and typeof(saved_completed[quest_id]) == TYPE_BOOL:
				completed[quest_id] = saved_completed[quest_id]

func save_progress() -> Dictionary:
	return {"counts": counts.duplicate(), "completed": completed.duplicate()}

func is_completed(quest_id: String) -> bool:
	return bool(completed.get(quest_id, false))

func on_enemy_killed(enemy_id: String, is_boss: bool) -> void:
	for quest in quests:
		var quest_id: String = str(quest["id"])
		if completed[quest_id] or not _is_available(quest):
			continue
		var objective: String = str(quest["objective_type"])
		if objective == "boss" and is_boss and (not quest.has("target_id") or str(quest.get("target_id", "")) == "" or str(quest.get("target_id", "")) == enemy_id):
			_complete(quest)
		elif objective == "kill" and str(quest.get("target_id", "")) == enemy_id:
			counts[quest_id] = int(counts[quest_id]) + 1
			if int(counts[quest_id]) >= int(quest["count"]):
				_complete(quest)

func on_chest_opened() -> void:
	for quest in quests:
		var quest_id: String = str(quest["id"])
		if completed[quest_id] or not _is_available(quest):
			continue
		if str(quest["objective_type"]) == "chest":
			counts[quest_id] = int(counts[quest_id]) + 1
			if int(counts[quest_id]) >= int(quest["count"]):
				_complete(quest)

func on_resource_harvested(resource_id: String) -> void:
	_advance_matching_objective("harvest", resource_id)

func on_region_entered(region_id: String) -> void:
	_advance_matching_objective("explore", region_id)

func on_item_delivered(npc_id: String, item_id: String) -> void:
	for quest in quests:
		var quest_id: String = str(quest["id"])
		if completed[quest_id] or not _is_available(quest):
			continue
		if str(quest["objective_type"]) != "deliver":
			continue
		if str(quest.get("target_id", "")) != npc_id or str(quest.get("item_id", "")) != item_id:
			continue
		_increment_objective(quest)

func _advance_matching_objective(objective_type: String, target_id: String) -> void:
	for quest in quests:
		var quest_id: String = str(quest["id"])
		if completed[quest_id] or not _is_available(quest):
			continue
		if str(quest["objective_type"]) != objective_type:
			continue
		if str(quest.get("target_id", "")) != target_id:
			continue
		_increment_objective(quest)

func _increment_objective(quest: Dictionary) -> void:
	var quest_id: String = str(quest["id"])
	counts[quest_id] = int(counts[quest_id]) + 1
	if int(counts[quest_id]) >= int(quest["count"]):
		_complete(quest)

func _is_available(quest: Dictionary) -> bool:
	var prerequisite: String = str(quest.get("prerequisite", ""))
	return prerequisite == "" or bool(completed.get(prerequisite, false))

func _complete(quest: Dictionary) -> void:
	var quest_id: String = str(quest["id"])
	completed[quest_id] = true
	quest_completed.emit(quest_id, str(quest["name"]), str(quest.get("complete_line", "")), int(quest.get("reward_gold", 0)))

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
