## Backend debugger class that is necessary for debugger plugins
## Handles the engine's debugger callbacks for receiving and sending data
## to the project that is playing
## Sets up the editor panel inside the debugger tab
class_name CapaDebugger 
extends EditorDebuggerPlugin

## Emitted on debugging session started
## Can happen on engine open or on play
signal started

## Emitted when CapabilityBoard data is received from autoload in remote scene
signal received_capability_board_data_from_remote(data)

## Emitted when capability data is received from autoload in remote scene
signal received_capability_data_from_remote(data)

## Emitted when editor panel requests inspection for [param node_path]
signal requested_node_data_from_remote(node_path: NodePath)

##
signal sync_view(data)

## Emitted on a breakpoint activated
## Not used yet, can be useful in the future
signal breaked

## Emitted on continued after breakpoint
## Not used yet, can be useful in the future
signal continued

## Emitted on debugging session stopped
## Can happen on editor quit or on stopped playing
signal stopped

## Identifier for debugger session
## Acquired on session started and cached 
var current_session_id: int = 0

const Schema = preload("./schema.gd")

## Sends data request message to remote scene with [param node_path]
func request_capability_board_data_from_remote(node_path: NodePath):
	get_session(current_session_id).send_message(Schema.MSG_CAPABILITY_BOARD_DATA_REQUESTED, [node_path])
	requested_node_data_from_remote.emit(node_path)

func request_inspect_node_from_remote(node_path: NodePath):
	get_session(current_session_id).send_message(Schema.MSG_INSPECT_OBJECT, [node_path])

## Appends editor panel control to Godot's debugger bottom panel
func setup_editor_panel(editor_panel: CapaEditorPanel):
	get_session(current_session_id).add_session_tab(editor_panel)

## This override is necessary so you can send and receive
## messages from the project that is playing
func _has_capture(prefix) -> bool:
	return prefix == Schema.DEBUGGER_MESSAGE_PREFIX

## On data from autoload received, send it to the editor panel
func _capture(message, data, session_id) -> bool:
	if message == Schema.MSG_CAPABILITY_BOARD_DATA:
		received_capability_board_data_from_remote.emit(data)
		return true
	elif message == Schema.MSG_CAPABILITY_DATA:
		received_capability_data_from_remote.emit(data)
		return true
	elif message == Schema.MSG_PHYSICS_FRAME_IDX:
		sync_view.emit(data)
		return true
	return false

## Engine callback override where we set up signals
func _setup_session(session_id):
	current_session_id = session_id
	var session = get_session(current_session_id)
	session.started.connect(_on_session_started)
	session.stopped.connect(_on_session_stopped)
	session.breaked.connect(_on_session_breaked)
	session.continued.connect(_on_session_continued)
	

func _on_session_started(): started.emit()
func _on_session_stopped(): stopped.emit()
func _on_session_breaked(can_debug: bool): breaked.emit(can_debug)
func _on_session_continued(): continued.emit()
