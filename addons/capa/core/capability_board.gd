@icon("./capability_board.svg")
class_name CapabilityBoard extends Node

## 启用跟踪
@export var enable_tracking: bool = true
## 在调试器中自动跟踪
@export var auto_track_in_debugger: bool = false

var _locks: Dictionary[StringName, Array] = {}
var _capabilities: Array[Capability] = []

# 对指定的标签进行加锁。
func block(tag: StringName, cap: Capability) -> void:
	if tag in _locks:
		if _locks[tag].has(cap): return
		_locks[tag].append(cap)
	else:
		_locks[tag] = [cap]

# 对指定的标签进行解锁。
func unblock(tag: StringName, cap: Capability) -> void:
	if tag in _locks:
		_locks[tag].erase(cap)
		if not _locks[tag].is_empty(): return
		_locks.erase(tag)

# 判断指定的标签是否加锁。
func has_blocked(tag: StringName) -> bool:
	return !_locks.get(tag, []).is_empty()

func _ready() -> void:
	_set_capabilities_board_recursive(self)
	if auto_track_in_debugger:
		Capa.send_capabilityboard_data(self)

func _set_capabilities_board_recursive(node: Node) -> void:
	for i in node.get_children():
		if i is Capability:
			i._board = self
			_capabilities.append(i)
		_set_capabilities_board_recursive(i)
