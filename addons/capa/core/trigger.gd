@tool
@icon("./trigger.svg")
class_name Trigger
extends Node

@export var target: Node:
	set(v):
		target = v
		update_configuration_warnings()
@export var signal_name: StringName = &"":
	set(v):
		signal_name = v
		update_configuration_warnings()
var trigger: bool = false

# Internal flag to track if trigger was activated in the current frame
var _triggered_this_frame: bool = false
# Flag to preserve the trigger state after processing
var _processed_trigger_state: bool = false


func _get_configuration_warnings() -> PackedStringArray:
	var warnings = []
	if not target:
		warnings.append("Target cannot be empty")
		return PackedStringArray(warnings)
	if not target.has_signal(signal_name):
		warnings.append("Target does not have the required signal %s" % signal_name)
	return PackedStringArray(warnings)


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	if not target:
		return
	target.connect(signal_name, _trigger)
	# Register this trigger with the Capa singleton
	Capa.register_trigger(self)


func _exit_tree() -> void:
	if Engine.is_editor_hint():
		return
	# Unregister this trigger from the Capa singleton
	Capa.unregister_trigger(self)


func _trigger():
	if Engine.is_editor_hint():
		return
	# Set the triggered flag for this frame, will be processed in the next physics process
	_triggered_this_frame = true


# Process the triggered state - called by Capa in the correct order
func process_triggered_state():
	# Apply the triggered state from the previous frame to the current trigger state
	_processed_trigger_state = _triggered_this_frame

	# Actually update the public trigger property
	trigger = _processed_trigger_state


# Reset the trigger state for the next frame
func reset_trigger_state():
	# This is called after all processing is done in the frame
	_triggered_this_frame = false
