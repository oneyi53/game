class_name FormationManager
extends RefCounted

# Pure party-formation state. RecruitmentManager remains the source
# of truth for ownership; this class only controls who is deployed.
# The first active hero is the current leader; leadership is replaceable.

const DEFAULT_MAX_PARTY_SIZE: int = 4

var max_party_size: int = DEFAULT_MAX_PARTY_SIZE
var owned_ids: Array[String] = []
var active_ids: Array[String] = []
var error_message: String = ""

func configure(p_owned_ids: Array, p_saved_data = null, p_legacy_active_ids: Array = [], p_max_party_size: int = DEFAULT_MAX_PARTY_SIZE) -> bool:
    error_message = ""
    max_party_size = maxi(1, p_max_party_size)
    owned_ids.clear()
    active_ids.clear()
    var seen_owned: Dictionary = {}
    for value in p_owned_ids:
        var hero_id: String = str(value)
        if hero_id == "" or seen_owned.has(hero_id):
            continue
        seen_owned[hero_id] = true
        owned_ids.append(hero_id)
    if owned_ids.is_empty():
        error_message = "编队初始化失败：没有已拥有的英雄"
        return false

    var requested: Array = []
    if p_saved_data is Dictionary and p_saved_data.has("active_ids"):
        var saved_ids = p_saved_data["active_ids"]
        if not (saved_ids is Array):
            error_message = "编队存档 active_ids 必须是数组"
            return false
        requested = saved_ids
    elif not p_legacy_active_ids.is_empty():
        requested = p_legacy_active_ids
    else:
        requested = owned_ids.duplicate()

    var seen_active: Dictionary = {}
    for value in requested:
        var hero_id: String = str(value)
        if not seen_owned.has(hero_id) or seen_active.has(hero_id):
            continue
        if active_ids.size() >= max_party_size:
            break
        seen_active[hero_id] = true
        active_ids.append(hero_id)
    if active_ids.is_empty():
        active_ids.append(owned_ids[0])
    return true

func add_to_party(hero_id: String) -> bool:
    if not owned_ids.has(hero_id) or active_ids.has(hero_id) or active_ids.size() >= max_party_size:
        return false
    active_ids.append(hero_id)
    return true

func remove_from_party(hero_id: String) -> bool:
    if not active_ids.has(hero_id) or active_ids.size() <= 1:
        return false
    active_ids.erase(hero_id)
    return true

# Promote an active or reserve hero. If the party is full, the previous
# leader moves to reserve automatically rather than increasing party size.
func set_leader(hero_id: String) -> bool:
    if not owned_ids.has(hero_id):
        return false
    if active_ids.has(hero_id):
        active_ids.erase(hero_id)
        active_ids.push_front(hero_id)
        return true
    if active_ids.size() >= max_party_size:
        active_ids[0] = hero_id
    else:
        active_ids.push_front(hero_id)
    return true

func swap_slots(first_index: int, second_index: int) -> bool:
    if first_index < 0 or second_index < 0 or first_index >= active_ids.size() or second_index >= active_ids.size():
        return false
    if first_index == second_index:
        return false
    var temp: String = active_ids[first_index]
    active_ids[first_index] = active_ids[second_index]
    active_ids[second_index] = temp
    return true

func is_active(hero_id: String) -> bool:
    return active_ids.has(hero_id)

func is_leader(hero_id: String) -> bool:
    return not active_ids.is_empty() and active_ids[0] == hero_id

func available_ids() -> Array[String]:
    var result: Array[String] = []
    for hero_id in owned_ids:
        if not active_ids.has(hero_id):
            result.append(hero_id)
    return result

func save_data() -> Dictionary:
    return {"active_ids": active_ids.duplicate()}

func validate() -> bool:
    if active_ids.is_empty() or active_ids.size() > max_party_size:
        return false
    var seen: Dictionary = {}
    for hero_id in active_ids:
        if not owned_ids.has(hero_id) or seen.has(hero_id):
            return false
        seen[hero_id] = true
    return true
