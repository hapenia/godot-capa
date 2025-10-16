@tool
@icon("./trigger.svg")
class_name Trigger extends Node

@export var target: Node:
	set(v):
		target = v
		update_configuration_warnings()
@export var signal_name: StringName = &"":
	set(v):
		signal_name = v
		update_configuration_warnings()
var trigger: bool = false


func _get_configuration_warnings() -> PackedStringArray:
	var warnings = []
	if not target:
		warnings.append("Target 不能为空")
		return PackedStringArray(warnings)
	if not target.has_signal(signal_name):
		warnings.append("Target 没有所需的信号 %s" % signal_name)
	return PackedStringArray(warnings)


func _ready() -> void:
	if Engine.is_editor_hint(): return
	if not target: return
	target.connect(signal_name, _trigger)

func _trigger():
	if Engine.is_editor_hint(): return
	# since now is in a gap betweens physics frames, so we need to await twice to get next physics frame
	# ensure trigger is true in next physics frame, and false in next next physics frame
	
	# Time: now|await#0->|await#1------------->|
	# Process: --pending-> Process#1 --pending-> Process#2
	# trigger: true ------ Process#1 --------- false	
	trigger = true
	await get_tree().physics_frame
	await get_tree().physics_frame
	trigger = false
