class_name CampManager
extends RefCounted

# Camp buildings (data/camp.json) and campfire unlock framework.
# Save shape remains {"built": [...], "campfires_unlocked": [...]}.

var error_message: String = ""
var buildings: Dictionary = {}
var building_order: Array = []
var campfires: Dictionary = {}
var campfire_order: Array = []
var built: Dictionary = {}
var campfires_unlocked: Dictionary = {}

func load_all(camp_path: String = "res://data/camp.json", campfires_path: String = "res://data/campfires.json") -> bool:
    var camp_data = _load_json(camp_path)
    if camp_data == null:
        return false
    var campfire_data = _load_json(campfires_path)
    if campfire_data == null:
        return false

    var next_buildings: Dictionary = {}
    var next_building_order: Array = []
    var next_built: Dictionary = {}
    if not _parse_camp(camp_data, next_buildings, next_building_order, next_built):
        return false

    var next_campfires: Dictionary = {}
    var next_campfire_order: Array = []
    var next_unlocked: Dictionary = {}
    if not _parse_campfires(campfire_data, next_campfires, next_campfire_order, next_unlocked):
        return false

    # Publish a complete validated snapshot only after both files pass.
    buildings = next_buildings
    building_order = next_building_order
    built = next_built
    campfires = next_campfires
    campfire_order = next_campfire_order
    campfires_unlocked = next_unlocked
    error_message = ""
    return true

func _load_json(path: String):
    if not FileAccess.file_exists(path):
        error_message = "缺少配置文件：" + path
        return null
    var source: String = FileAccess.get_file_as_string(path)
    if source.strip_edges() == "":
        error_message = "配置文件为空：" + path
        return null
    var json := JSON.new()
    if json.parse(source) != OK:
        error_message = "配置文件不是合法 JSON：" + path
        return null
    return json.data

func _is_non_blank_string(value) -> bool:
    return typeof(value) == TYPE_STRING and not str(value).strip_edges().is_empty()

func _is_integer_number(value) -> bool:
    if typeof(value) == TYPE_INT:
        return true
    if typeof(value) != TYPE_FLOAT:
        return false
    var number: float = float(value)
    return is_finite(number) and is_equal_approx(number, floor(number))

func _parse_camp(data, out_buildings: Dictionary, out_order: Array, out_built: Dictionary) -> bool:
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
        for field in ["id", "name", "intro", "built_message"]:
            if not _is_non_blank_string(entry[field]):
                error_message = "camp.json 字段必须是非空字符串：" + field
                return false
        if typeof(entry["default_built"]) != TYPE_BOOL:
            error_message = "camp.json default_built 必须是 bool，id：" + str(entry["id"])
            return false
        if not _is_integer_number(entry["cost_wood"]) or int(entry["cost_wood"]) < 0:
            error_message = "camp.json cost_wood 必须是非负整数，id：" + str(entry["id"])
            return false
        var building_id: String = str(entry["id"])
        if out_buildings.has(building_id):
            error_message = "camp.json 有重复 id：" + building_id
            return false
        out_buildings[building_id] = entry.duplicate(true)
        out_order.append(building_id)
        out_built[building_id] = entry["default_built"]
    if not out_buildings.has("hero_management") or not out_built["hero_management"]:
        error_message = "camp.json 必须含默认已建成的英雄管理"
        return false
    return true

func _parse_campfires(data, out_campfires: Dictionary, out_order: Array, out_unlocked: Dictionary) -> bool:
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
        for field in ["id", "area", "target_area", "intro", "fog_prompt", "insufficient_prompt", "dispel_prompt", "teleport_intro"]:
            if not _is_non_blank_string(entry[field]):
                error_message = "campfires.json 字段必须是非空字符串：" + field
                return false
        if not _is_integer_number(entry["cost_wood"]) or int(entry["cost_wood"]) <= 0:
            error_message = "campfires.json cost_wood 必须是正整数，id：" + str(entry["id"])
            return false
        # map_id is the world containing this fire; target_area remains the
        # area unlocked by activating it. Legacy entries default to target_area,
        # keeping future-area framework fires out of current world maps.
        if entry.has("map_id") and not _is_non_blank_string(entry["map_id"]):
            error_message = "campfires.json map_id 必须是非空字符串"
            return false
        var campfire_id: String = str(entry["id"])
        if out_campfires.has(campfire_id):
            error_message = "campfires.json 有重复 id：" + campfire_id
            return false
        var pos = entry["position"]
        if not (pos is Dictionary) or not pos.has("x") or not pos.has("y"):
            error_message = "campfires.json 火堆缺少 position.x/y，id：" + campfire_id
            return false
        if not _is_finite_number(pos["x"]) or not _is_finite_number(pos["y"]):
            error_message = "campfires.json position.x/y 必须是有限数值，id：" + campfire_id
            return false
        out_campfires[campfire_id] = entry.duplicate(true)
        out_order.append(campfire_id)
        out_unlocked[campfire_id] = false
    return true

func _is_finite_number(value) -> bool:
    return (typeof(value) == TYPE_INT or typeof(value) == TYPE_FLOAT) and is_finite(float(value))

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

func campfires_for_map(map_id: String) -> Array:
    var result: Array = []
    for campfire_id in campfire_order:
        var entry: Dictionary = campfires[campfire_id]
        var owner_map: String = str(entry.get("map_id", entry.get("target_area", "")))
        if owner_map == map_id:
            result.append(entry.duplicate(true))
    return result

func unlocked_campfires_for_map(map_id: String) -> Array:
    var result: Array = []
    for entry in campfires_for_map(map_id):
        if is_campfire_unlocked(str(entry["id"])):
            result.append(entry)
    return result

func has_unlocked_campfire_on_map(map_id: String) -> bool:
    return not unlocked_campfires_for_map(map_id).is_empty()

func campfire_map_id(campfire_id: String) -> String:
    var entry = campfire(campfire_id)
    if entry == null:
        return ""
    return str(entry.get("map_id", entry.get("target_area", "")))

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
