@tool
@icon("./capability_tag.svg")
class_name CapabilityTag extends Node


func _notification(what: int) -> void:
	if what == NOTIFICATION_PARENTED:
		update_configuration_warnings()

func _get_configuration_warnings() -> PackedStringArray:
	if not get_parent() is Capability:
		return PackedStringArray(["CapabilityTag 的父节点必须是 Capability"])
	return PackedStringArray([])

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.is_editor_hint(): return
	get_parent().bind_tag(name.to_snake_case())
