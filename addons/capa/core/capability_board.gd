@icon("./capability_board.svg")
class_name CapabilityBoard
extends Node

## Enable tracking
@export var enable_tracking: bool = true
## Auto track in debugger
@export var auto_track_in_debugger: bool = false

var _locks: Dictionary[StringName, Array] = { }
var _capabilities: Array[Capability] = []


# Lock a specified tag.
func block(tag: StringName, cap: Capability) -> void:
	if tag in _locks:
		if _locks[tag].has(cap):
			return
		_locks[tag].append(cap)
	else:
		_locks[tag] = [cap]


# Unlock a specified tag.
func unblock(tag: StringName, cap: Capability) -> void:
	if tag in _locks:
		_locks[tag].erase(cap)
		if not _locks[tag].is_empty():
			return
		_locks.erase(tag)


# Check if a specified tag is locked.
func has_blocked(tag: StringName) -> bool:
	return !_locks.get(tag, []).is_empty()


func _ready() -> void:
	_set_capabilities_board_recursive(self)
	if auto_track_in_debugger:
		Capa.send_capabilityboard_data(self)
	# Register this board with the Capa singleton
	Capa.register_capability_board(self)


func _exit_tree() -> void:
	# Unregister this board from the Capa singleton
	Capa.unregister_capability_board(self)


func _set_capabilities_board_recursive(node: Node) -> void:
	for i in node.get_children():
		if i is Capability:
			i._board = self
			_capabilities.append(i)
		_set_capabilities_board_recursive(i)
