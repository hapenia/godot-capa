extends Node

const Schema = preload("./schema.gd")

# Store all CapabilityBoard instances
var _capability_boards: Array[CapabilityBoard] = []

# Store all Trigger instances
var _triggers: Array[Trigger] = []


## On singleton ready in scene
## subscribe to the editor panel's request
func _ready() -> void:
	EngineDebugger.register_message_capture("capa", _on_capability_board_data_requested)


# Register a CapabilityBoard instance
func register_capability_board(board: CapabilityBoard) -> void:
	if not _capability_boards.has(board):
		_capability_boards.append(board)


# Unregister a CapabilityBoard instance
func unregister_capability_board(board: CapabilityBoard) -> void:
	_capability_boards.erase(board)


# Register a Trigger instance
func register_trigger(trigger: Trigger) -> void:
	if not _triggers.has(trigger):
		_triggers.append(trigger)


# Unregister a Trigger instance
func unregister_trigger(trigger: Trigger) -> void:
	_triggers.erase(trigger)


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
	if not target_node is CapabilityBoard:
		return false
	if not target_node.enable_tracking:
		return false
	else:
		send_capabilityboard_data(target_node)
		return true


func send_capabilityboard_data(board: CapabilityBoard):
	EngineDebugger.send_message(Schema.MSG_CAPABILITY_BOARD_DATA, Schema.create_capability_board_data(board))


func _physics_process(delta: float) -> void:
	var frame_idx = Engine.get_physics_frames() - 1
	#if frame_idx % 60 == 0:
	EngineDebugger.send_message(Schema.MSG_PHYSICS_FRAME_IDX, [frame_idx])

	# Process in the specified order:
	# 1. All Triggers detect if triggered
	for trigger in _triggers:
		if is_instance_valid(trigger):
			trigger.process_triggered_state()

	# 2. All CapabilityBoards process
	for board in _capability_boards:
		if is_instance_valid(board) and board.enable_tracking:
			_process_capabilities_recursive(board, delta)

	# 3. All Triggers reset
	for trigger in _triggers:
		if is_instance_valid(trigger):
			trigger.reset_trigger_state()


# Process capabilities recursively in depth-first order
func _process_capabilities_recursive(node: Node, delta: float) -> void:
	# Process children first (depth-first)
	for child in node.get_children():
		_process_capabilities_recursive(child, delta)

	# Process any capability-specific logic if this node is a Capability
	if node is Capability:
		node._process_capability(delta)


func send_capability_status_changed(cap: Capability, msg: String):
	var frame_idx = Engine.get_physics_frames() - 1
	EngineDebugger.send_message(
		Schema.MSG_CAPABILITY_DATA,
		[
			{
				"id": cap.get_instance_id(),
				"name": cap.name,
				"frame_idx": frame_idx,
				"status": cap.is_active(),
				"enabled": cap.enabled,
				"msg": msg,
			},
		],
	)
