extends SceneTree

const ResourceNodeScript = preload("res://scripts/interactable/resource_node.gd")

func _initialize() -> void:
	var node = ResourceNodeScript.new()
	node.setup("moss_wood_01", "林木", "wood", "moss_crown", 3, 5, false)
	assert(node.resource_id == "moss_wood_01")
	assert(node.world_map_id == "moss_crown")
	assert(not node.depleted)
	var amount: int = node.harvest()
	assert(amount >= 3 and amount <= 5)
	assert(node.depleted)
	assert(node.harvest() == 0, "depleted node must not yield twice")
	node.setup("moss_wood_01", "林木", "wood", "moss_crown", 3, 5, true)
	assert(node.depleted, "saved depleted state must be restored")
	assert(node.harvest() == 0)
	print("Resource node tests: 6 passed")
	quit()
