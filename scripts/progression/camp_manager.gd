class_name CampManager
extends RefCounted

# Camp buildings (data/camp.json) and campfire unlock framework
# (data/campfires.json). Text is the reviewed system-draft wording,
# not a new invention: building intros / built messages and the
# campfire fog / insufficient / dispel / teleport lines come from
# system_draft/system-draft-reviewed.md verbatim.
# Built and unlocked state lives in the save under "camp":
# {"built": [...], "campfires_unlocked": [...]}. An old save
# without "camp" defaults to hero_management built, the other two
# buildings unbuilt, and no campfire unlocked. Unknown ids in a
# save are ignored, never a crash. This manager changes no stats:
# building only records state and shows the reviewed message;
# equipment upgrade and hero levelling belong to later blocks.

var error_message: String = ""
var buildings: Dictionary = {}
var building_order: Array = []
var campfires: Dictionary = {}
var campfire_order: Array = []
var built: Dictionary = {}
var campfires_unlocked: Dictionary = {}

func load_all() -> bool:
    if not _load_camp():
        return false
    if not _load_campfires():
        return false
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

func _load_camp() -> bool:
    var data = _load_json("res://data/camp.json")
    if data == null:
        return false
    if not (data is Dictionary) or not data.has("buildings") or not (data["buildings"] is Array):
        error_message = "camp.json 必须是含 buildings 数组的对象"
        return false
    for entry in data["buildings"]:
        if not (entry is Dictionary):
            error_message = "camp.json 中有非对象条目"
            return false
        for field in ["id", "name", "cost_wood", "intro", "built_message", "default_built"]:
            if not entry.has(field):
                error_message = "camp.json 缺少字段：" + field
                return false
        if buildings.has(str(entry["id"])):
            error_message = "camp.json 有重复 id：" + str(entry["id"])
            return false
        if int(entry["cost_wood"]) < 0:
            error_message = "camp.json 建造木材成本不能为负，id：" + str(entry["id"])
            return false
        buildings[str(entry["id"])] = entry
        building_order.append(str(entry["id"]))
        built[str(entry["id"])] = bool(entry["default_built"])
    if not buildings.has("hero_management") or not built["hero_management"]:
        error_message = "camp.json 必须含默认已建成的英雄管理"
        return false
    return true

func _load_campfires() -> bool:
    var data = _load_json("res://data/campfires.json")
    if data == null:
        return false
    if not (data is Array):
        error_message = "campfires.json 必须是数组"
        return false
    for entry in data:
        if not (entry is Dictionary):
            error_message = "campfires.json 中有非对象条目"
            return false
        for field in ["id", "area", "target_area", "cost_wood", "position", "intro", "fog_prompt", "insufficient_prompt", "dispel_prompt", "teleport_intro"]:
            if not entry.has(field):
                error_message = "campfires.json 缺少字段：" + field
                return false
        if campfires.has(str(entry["id"])):
            error_message = "campfires.json 有重复 id：" + str(entry["id"])
            return false
        if int(entry["cost_wood"]) <= 0:
            error_message = "campfires.json 火堆木材成本必须为正整数，id：" + str(entry["id"])
            return false
        var pos = entry["position"]
        if not (pos is Dictionary) or not pos.has("x") or not pos.has("y"):
            error_message = "campfires.json 火堆缺少 position.x/y，id：" + str(entry["id"])
            return false
        campfires[str(entry["id"])] = entry
        campfire_order.append(str(entry["id"]))
        campfires_unlocked[str(entry["id"])] = false
    return true

func building(building_id: String):
    return buildings.get(building_id, null)

func is_built(building_id: String) -> bool:
    return bool(built.get(building_id, false))

func build(building_id: String) -> bool:
    if not buildings.has(building_id) or is_built(building_id):
        return false
    built[building_id] = true
    return true

func campfire(campfire_id: String):
    return campfires.get(campfire_id, null)

func is_campfire_unlocked(campfire_id: String) -> bool:
    return bool(campfires_unlocked.get(campfire_id, false))

func unlock_campfire(campfire_id: String) -> bool:
    if not campfires.has(campfire_id) or is_campfire_unlocked(campfire_id):
        return false
    campfires_unlocked[campfire_id] = true
    return true

func load_camp(saved) -> void:
    if not (saved is Dictionary):
        return
    var saved_built = saved.get("built", [])
    if saved_built is Array:
        for building_id in saved_built:
            if buildings.has(str(building_id)):
                built[str(building_id)] = true
    var saved_unlocked = saved.get("campfires_unlocked", [])
    if saved_unlocked is Array:
        for campfire_id in saved_unlocked:
            if campfires.has(str(campfire_id)):
                campfires_unlocked[str(campfire_id)] = true

func save_camp() -> Dictionary:
    var built_list: Array = []
    for building_id in building_order:
        if built[building_id]:
            built_list.append(building_id)
    var unlocked_list: Array = []
    for campfire_id in campfire_order:
        if campfires_unlocked[campfire_id]:
            unlocked_list.append(campfire_id)
    return {"built": built_list, "campfires_unlocked": unlocked_list}
