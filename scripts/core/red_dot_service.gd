class_name RedDotService
extends RefCounted

## Derives parent red-dot visibility from caller-owned business source states.
## This service does not own business rules, rewards, persistence, or UI nodes.

signal state_changed(snapshot: Dictionary)

var error_message: String = ""
var _source_states: Dictionary = {}
var _hierarchy: Dictionary = {}

## Configure parent -> child target relationships. A parent is visible when
## its own source is visible or any descendant source is visible.
## Invalid input is rejected without replacing the existing hierarchy.
func set_hierarchy(hierarchy: Dictionary) -> bool:
	error_message = ""
	var normalized: Dictionary = {}
	for parent_value in hierarchy.keys():
		var parent_id: String = str(parent_value).strip_edges()
		var children_value: Variant = hierarchy[parent_value]
		if parent_id == "" or not (children_value is Array):
			error_message = "Hierarchy keys must be non-empty IDs and values must be Arrays."
			return false
		if normalized.has(parent_id):
			error_message = "Duplicate parent target: " + parent_id
			return false
		var children: Array = []
		for child_value in children_value:
			var child_id: String = str(child_value).strip_edges()
			if child_id == "" or child_id == parent_id or children.has(child_id):
				error_message = "Invalid or duplicate child target under: " + parent_id
				return false
			children.append(child_id)
		normalized[parent_id] = children

	if _graph_has_cycle(normalized):
		error_message = "Target hierarchy cannot contain cycles."
		return false

	if _hierarchy == normalized:
		return true
	_hierarchy = normalized
	_emit_changed()
	return true

## Replace all caller-owned source states atomically.
func replace_source_states(states: Dictionary) -> bool:
	error_message = ""
	var normalized: Dictionary = {}
	for target_value in states.keys():
		var target_id: String = str(target_value).strip_edges()
		var active: Variant = states[target_value]
		if target_id == "" or typeof(active) != TYPE_BOOL:
			error_message = "Source states require non-empty target IDs and Boolean values."
			return false
		if normalized.has(target_id):
			error_message = "Duplicate source target: " + target_id
			return false
		normalized[target_id] = active
	if _source_states == normalized:
		return true
	_source_states = normalized
	_emit_changed()
	return true

## Set one authoritative source state. Parent aggregation remains derived.
func set_source_state(target_id: String, active: bool) -> bool:
	var normalized_id: String = target_id.strip_edges()
	if normalized_id == "":
		error_message = "Target ID cannot be empty."
		return false
	error_message = ""
	if bool(_source_states.get(normalized_id, false)) == active and _source_states.has(normalized_id):
		return true
	_source_states[normalized_id] = active
	_emit_changed()
	return true

func clear_source_state(target_id: String) -> bool:
	var normalized_id: String = target_id.strip_edges()
	if normalized_id == "" or not _source_states.has(normalized_id):
		return false
	_source_states.erase(normalized_id)
	_emit_changed()
	return true

func is_visible(target_id: String) -> bool:
	var normalized_id: String = target_id.strip_edges()
	if normalized_id == "":
		return false
	return _is_visible_recursive(normalized_id, {})

func _is_visible_recursive(target_id: String, visited: Dictionary) -> bool:
	if visited.has(target_id):
		return false
	visited[target_id] = true
	if bool(_source_states.get(target_id, false)):
		visited.erase(target_id)
		return true
	for child_value in _hierarchy.get(target_id, []):
		if _is_visible_recursive(str(child_value), visited):
			visited.erase(target_id)
			return true
	visited.erase(target_id)
	return false

func get_snapshot() -> Dictionary:
	var target_ids: Array = []
	for source_id in _source_states.keys():
		if not target_ids.has(source_id):
			target_ids.append(source_id)
	for parent_id in _hierarchy.keys():
		if not target_ids.has(parent_id):
			target_ids.append(parent_id)
		for child_id in _hierarchy[parent_id]:
			if not target_ids.has(child_id):
				target_ids.append(child_id)
	target_ids.sort()

	var snapshot: Dictionary = {}
	for target_id_value in target_ids:
		var target_id: String = str(target_id_value)
		snapshot[target_id] = is_visible(target_id)
	return snapshot

func _graph_has_cycle(graph: Dictionary) -> bool:
	var visited: Dictionary = {}
	var visiting: Dictionary = {}
	for node_value in graph.keys():
		if _visit_graph_node(str(node_value), graph, visiting, visited):
			return true
	return false

func _visit_graph_node(node_id: String, graph: Dictionary, visiting: Dictionary, visited: Dictionary) -> bool:
	if visiting.has(node_id):
		return true
	if visited.has(node_id):
		return false
	visiting[node_id] = true
	for child_value in graph.get(node_id, []):
		var child_id: String = str(child_value)
		if graph.has(child_id) and _visit_graph_node(child_id, graph, visiting, visited):
			return true
	visiting.erase(node_id)
	visited[node_id] = true
	return false

func _emit_changed() -> void:
	state_changed.emit(get_snapshot())
