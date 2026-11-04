class_name DailyActivityManager
extends RefCounted

signal state_changed(snapshot: Dictionary)

const STATE_VERSION: int = 1

var error_message: String = ""
var day_key: String = ""
var _task_definitions: Dictionary = {}
var _stage_definitions: Dictionary = {}
var _task_states: Dictionary = {}
var _claimed_stages: Dictionary = {}
var _processed_occurrences: Dictionary = {}

func initialize(task_definitions: Array, stage_definitions: Array, current_day_key: String, saved_state: Variant = null) -> bool:
    error_message = ""
    if not _is_valid_day_key(current_day_key):
        error_message = "Invalid day key; expected YYYY-MM-DD."
        return false
    if not _load_definitions(task_definitions, stage_definitions):
        return false

    day_key = current_day_key
    _reset_daily_state()
    if not (saved_state is Dictionary):
        return true

    var saved_day_key: String = str(saved_state.get("day_key", ""))
    if not _is_valid_day_key(saved_day_key):
        return true
    if saved_day_key > current_day_key:
        # A local clock rollback must not recreate an earlier reward cycle.
        day_key = saved_day_key
        error_message = "Clock rollback detected; retained the latest saved day."
        _restore_progress(saved_state)
        return true
    if saved_day_key == current_day_key:
        _restore_progress(saved_state)
    # An older save starts a clean state for the current day.
    return true

func _load_definitions(task_definitions: Array, stage_definitions: Array) -> bool:
    # Build candidate definitions separately so a rejected reconfiguration
    # cannot leave the live manager with a partially replaced configuration.
    var next_task_definitions: Dictionary = {}
    var next_stage_definitions: Dictionary = {}
    for value in task_definitions:
        if not (value is Dictionary):
            error_message = "Every daily task definition must be a Dictionary."
            return false
        var task: Dictionary = value.duplicate(true)
        var task_id: String = str(task.get("id", "")).strip_edges()
        var event_type: String = str(task.get("event_type", "")).strip_edges()
        var target_count: int = int(task.get("target_count", 0))
        var points: int = int(task.get("points", 0))
        var filters: Variant = task.get("filters", {})
        if task_id == "" or event_type == "" or target_count <= 0 or points < 0 or not (filters is Dictionary):
            error_message = "Invalid daily task definition: " + task_id
            return false
        if next_task_definitions.has(task_id):
            error_message = "Duplicate daily task id: " + task_id
            return false
        task["id"] = task_id
        task["event_type"] = event_type
        task["target_count"] = target_count
        task["points"] = points
        task["filters"] = filters.duplicate(true)
        next_task_definitions[task_id] = task

    for value in stage_definitions:
        if not (value is Dictionary):
            error_message = "Every activity stage definition must be a Dictionary."
            return false
        var stage: Dictionary = value.duplicate(true)
        var stage_id: String = str(stage.get("id", "")).strip_edges()
        var threshold: int = int(stage.get("threshold", 0))
        var reward_id: String = str(stage.get("reward_id", "")).strip_edges()
        if stage_id == "" or threshold <= 0 or reward_id == "":
            error_message = "Invalid activity stage definition: " + stage_id
            return false
        if next_stage_definitions.has(stage_id):
            error_message = "Duplicate activity stage id: " + stage_id
            return false
        stage["id"] = stage_id
        stage["threshold"] = threshold
        stage["reward_id"] = reward_id
        next_stage_definitions[stage_id] = stage

    _task_definitions = next_task_definitions
    _stage_definitions = next_stage_definitions
    return true

func _is_valid_day_key(value: String) -> bool:
    if value.length() != 10 or value.substr(4, 1) != "-" or value.substr(7, 1) != "-":
        return false
    var year_text: String = value.substr(0, 4)
    var month_text: String = value.substr(5, 2)
    var day_text: String = value.substr(8, 2)
    if not year_text.is_valid_int() or not month_text.is_valid_int() or not day_text.is_valid_int():
        return false
    var year: int = int(year_text)
    var month: int = int(month_text)
    var day: int = int(day_text)
    if year <= 0 or month < 1 or month > 12 or day < 1:
        return false
    var days_in_month: Array = [31, 29 if _is_leap_year(year) else 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    return day <= int(days_in_month[month - 1])

func _is_leap_year(year: int) -> bool:
    return year % 400 == 0 or (year % 4 == 0 and year % 100 != 0)

func _reset_daily_state() -> void:
    _task_states.clear()
    _claimed_stages.clear()
    _processed_occurrences.clear()
    for task_id in _task_definitions.keys():
        _task_states[str(task_id)] = {"progress": 0, "completed": false}

func _restore_progress(saved_state: Dictionary) -> void:
    _reset_daily_state()
    var saved_progress: Variant = saved_state.get("task_progress", {})
    if saved_progress is Dictionary:
        for task_id_value in saved_progress.keys():
            var task_id: String = str(task_id_value)
            if not _task_definitions.has(task_id):
                continue
            var task: Dictionary = _task_definitions[task_id]
            var progress: int = clampi(int(saved_progress[task_id_value]), 0, int(task["target_count"]))
            _task_states[task_id] = {"progress": progress, "completed": progress >= int(task["target_count"])}

    var saved_claims: Variant = saved_state.get("claimed_stages", [])
    if saved_claims is Array:
        for stage_id_value in saved_claims:
            var stage_id: String = str(stage_id_value)
            if next_stage_definitions.has(stage_id):
                _claimed_stages[stage_id] = true

    var saved_occurrences: Variant = saved_state.get("processed_occurrences", [])
    if saved_occurrences is Array:
        for occurrence_value in saved_occurrences:
            var occurrence_id: String = str(occurrence_value).strip_edges()
            if occurrence_id != "":
                _processed_occurrences[occurrence_id] = true

func advance_day(new_day_key: String) -> bool:
    if not _is_valid_day_key(new_day_key):
        error_message = "Invalid day key; expected YYYY-MM-DD."
        return false
    if day_key == "":
        day_key = new_day_key
        _reset_daily_state()
        _emit_changed()
        return true
    if new_day_key < day_key:
        error_message = "Clock rollback rejected; daily state was not changed."
        return false
    if new_day_key == day_key:
        return true
    day_key = new_day_key
    _reset_daily_state()
    _emit_changed()
    return true

func record_event(event_type: String, occurrence_id: String, payload: Dictionary = {}, amount: int = 1) -> Dictionary:
    var result := {
        "accepted": false,
        "duplicate": false,
        "changed": false,
        "completed_task_ids": [],
        "points_added": 0
    }
    var normalized_occurrence_id: String = occurrence_id.strip_edges()
    if event_type.strip_edges() == "" or normalized_occurrence_id == "" or amount <= 0 or day_key == "":
        error_message = "Event type, occurrence id, initialized day and positive amount are required."
        return result
    if _processed_occurrences.has(normalized_occurrence_id):
        result["duplicate"] = true
        return result

    _processed_occurrences[normalized_occurrence_id] = true
    result["accepted"] = true
    var points_before: int = get_activity_points()
    for task_id_value in _task_definitions.keys():
        var task_id: String = str(task_id_value)
        var definition: Dictionary = _task_definitions[task_id]
        if str(definition["event_type"]) != event_type:
            continue
        if not _payload_matches(payload, definition["filters"]):
            continue
        var state: Dictionary = _task_states[task_id]
        if bool(state["completed"]):
            continue
        var target_count: int = int(definition["target_count"])
        var next_progress: int = mini(target_count, int(state["progress"]) + amount)
        if next_progress == int(state["progress"]):
            continue
        state["progress"] = next_progress
        state["completed"] = next_progress >= target_count
        _task_states[task_id] = state
        result["changed"] = true
        if bool(state["completed"]):
            result["completed_task_ids"].append(task_id)

    result["points_added"] = get_activity_points() - points_before
    if bool(result["changed"]):
        _emit_changed()
    return result

func _payload_matches(payload: Dictionary, filters: Dictionary) -> bool:
    for key in filters.keys():
        if not payload.has(key) or payload[key] != filters[key]:
            return false
    return true

func get_activity_points() -> int:
    var total: int = 0
    for task_id_value in _task_definitions.keys():
        var task_id: String = str(task_id_value)
        if bool(_task_states.get(task_id, {}).get("completed", false)):
            total += int(_task_definitions[task_id]["points"])
    return total

func claim_stage(stage_id: String, reward_grant: Callable) -> Dictionary:
    if not _stage_definitions.has(stage_id):
        return {"ok": false, "reason": "unknown_stage"}
    if _claimed_stages.has(stage_id):
        return {"ok": false, "reason": "already_claimed"}
    var stage: Dictionary = _stage_definitions[stage_id]
    if get_activity_points() < int(stage["threshold"]):
        return {"ok": false, "reason": "locked"}
    if not reward_grant.is_valid():
        return {"ok": false, "reason": "invalid_reward_handler"}
    # The caller owns reward persistence. Only mark claimed after it confirms success.
    if not bool(reward_grant.call(str(stage["reward_id"]))):
        return {"ok": false, "reason": "reward_failed"}
    _claimed_stages[stage_id] = true
    _emit_changed()
    return {"ok": true, "reason": "claimed", "stage_id": stage_id, "reward_id": str(stage["reward_id"])}

func get_snapshot() -> Dictionary:
    var tasks: Dictionary = {}
    for task_id_value in _task_definitions.keys():
        var task_id: String = str(task_id_value)
        var definition: Dictionary = _task_definitions[task_id]
        var state: Dictionary = _task_states.get(task_id, {"progress": 0, "completed": false})
        tasks[task_id] = {
            "name": str(definition.get("name", task_id)),
            "description": str(definition.get("description", "")),
            "event_type": str(definition["event_type"]),
            "progress": int(state["progress"]),
            "target_count": int(definition["target_count"]),
            "completed": bool(state["completed"]),
            "points": int(definition["points"])
        }

    var stages: Dictionary = {}
    var points: int = get_activity_points()
    for stage_id_value in _stage_definitions.keys():
        var stage_id: String = str(stage_id_value)
        var definition: Dictionary = _stage_definitions[stage_id]
        var claimed: bool = _claimed_stages.has(stage_id)
        var unlocked: bool = points >= int(definition["threshold"])
        stages[stage_id] = {
            "name": str(definition.get("name", stage_id)),
            "threshold": int(definition["threshold"]),
            "reward_id": str(definition["reward_id"]),
            "unlocked": unlocked,
            "claimed": claimed,
            "claimable": unlocked and not claimed,
            "status": "claimed" if claimed else ("claimable" if unlocked else "locked")
        }
    return {
        "day_key": day_key,
        "activity_points": points,
        "tasks": tasks,
        "stages": stages
    }

func save_state() -> Dictionary:
    var task_progress: Dictionary = {}
    for task_id_value in _task_states.keys():
        var task_id: String = str(task_id_value)
        task_progress[task_id] = int(_task_states[task_id]["progress"])
    var claimed_stages: Array = []
    for stage_id_value in _claimed_stages.keys():
        claimed_stages.append(str(stage_id_value))
    claimed_stages.sort()
    var processed_occurrences: Array = []
    for occurrence_id_value in _processed_occurrences.keys():
        processed_occurrences.append(str(occurrence_id_value))
    processed_occurrences.sort()
    return {
        "version": STATE_VERSION,
        "day_key": day_key,
        "task_progress": task_progress,
        "claimed_stages": claimed_stages,
        "processed_occurrences": processed_occurrences
    }

func _emit_changed() -> void:
    state_changed.emit(get_snapshot())
