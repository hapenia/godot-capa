extends Node

const Schema = preload("./schema.gd")

## On singleton ready in scene
## subscribe to the editor panel's request
func _ready() -> void:
	EngineDebugger.register_message_capture("capa", _on_capability_board_data_requested)

# hacks! more info: https://forum.godotengine.org/t/how-to-select-a-remote-node-in-editordebuggerplugin/124916
func _inspect(node: Node) -> void:
	var arr = []
	arr.append(node.get_instance_id())
	arr.append(node.get_class())
	arr.append([])
	EngineDebugger.send_message("remote_objects_selected", [arr])

func _on_capability_board_data_requested(prefix, data) -> bool:
	var target_node = get_tree().root.get_node(data[0])
	if prefix == "inspect":
		_inspect(target_node)
		return true
	if not target_node is CapabilityBoard: return false
	if not target_node.enable_tracking: return false
	else:
		send_capabilityboard_data(target_node)
		return true

func send_capabilityboard_data(board: CapabilityBoard):
	EngineDebugger.send_message(Schema.MSG_CAPABILITY_BOARD_DATA, Schema.create_capability_board_data(board))

func _physics_process(delta: float) -> void:
	var frame_idx = Engine.get_physics_frames() - 1
	#if frame_idx % 60 == 0:
	EngineDebugger.send_message(Schema.MSG_PHYSICS_FRAME_IDX, [frame_idx])

func send_capability_status_changed(cap: Capability, msg: String):
	var frame_idx = Engine.get_physics_frames() - 1
	EngineDebugger.send_message(Schema.MSG_CAPABILITY_DATA, [{
		"id": cap.get_instance_id(),
		"name": cap.name,
		"frame_idx": frame_idx,
		"status": cap.is_active(),
		"enabled": cap.enabled,
		"msg": msg,
	}])
