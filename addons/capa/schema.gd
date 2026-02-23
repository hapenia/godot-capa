## Designates debugger messages containing this prefix
## as being specific to the plugin
const DEBUGGER_MESSAGE_PREFIX := "capa"


static func capamsg(str: String):
	return DEBUGGER_MESSAGE_PREFIX + ":" + str


const MSG_CAPABILITY_BOARD_DATA_REQUESTED = "capa:capability_board_data_requested"
const MSG_CAPABILITY_BOARD_DATA = "capa:capability_board_data"
const MSG_CAPABILITY_DATA = "capa:capability_data"
const MSG_PHYSICS_FRAME_IDX = "capa:physics_frame_idx"
const MSG_INSPECT_OBJECT = "capa:inspect"


static func _create_capability_tree_node(board: CapabilityBoard, n: Node) -> Dictionary:
	var children = []
	var is_capability = n is Capability
	for c in n.get_children():
		children.append(_create_capability_tree_node(board, c))
	return {
		"name": n.name,
		"path": n.get_path(),
		"id": n.get_instance_id(),
		"is_capability": is_capability,
		"children": children,
	}


static func create_capability_board_data(board: CapabilityBoard) -> Array:
	# Recursively build dictionary tree, storing child nodes in the children key
	var tree = _create_capability_tree_node(board, board)

	# # collect children capabilities
	# var caps = board._capabilities
	# var data = []
	# for c in caps:
	# 	data.append({
	# 		"name": c.name,
	# 		"path": c.get_path_to(board, true),
	# 		"id": c.get_instance_id(),
	# 	})
	# return [{
	# 	"name": board.name,
	# 	"path": board.get_path(),
	# 	"id": board.get_instance_id(),
	# }, data]
	return [tree]
