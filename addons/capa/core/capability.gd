@icon("./capability.svg")
class_name Capability extends Node

@export var enabled: bool = true :
	set(v):
		if enabled != v:
			enabled = v
			enabled_changed.emit()


var _board: CapabilityBoard

signal enabled_changed()

signal activated()
signal deactivated()

var _is_active: bool = false
var _binding_tags: Array[StringName] = []

## 在当前 Capability 处于 [code]_is_active == false[/code] 状态时才会调用, 判断下一帧
## 是否需要激活此 Capability. 如果返回值为任意 False Value ([code]null[/code], [code]false[/code], [code]""[/code]...) 则
## 保持当前状态不改变，否则将会激活此 Capability.
func _should_activate():
	return

## 在当前 Capability 处于 [code]_is_active == true[/code] 状态时才会调用, 判断下一帧
## 是否需要关闭此 Capability. 如果返回值为任意 False Value ([code]null[/code], [code]false[/code], [code]""[/code]...) 则
## 保持当前状态不改变，否则将会关闭此 Capability.
func _should_deactivate():
	return

func _activated() -> void:
	pass

func _deactivated() -> void:
	pass

func _activate_process(_delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	if not enabled: return
	if _is_active:
		_activate_process(delta)
	call_deferred(&"_set_active")

func _set_active():
	if _is_active:
		var sd = _should_deactivate()
		var blocked_tags = _blocked_by()
		var blocked = not blocked_tags.is_empty()
		if sd || blocked:
			_is_active = false
			_deactivated()
		emit_signal("deactivated")
		if OS.has_feature("editor") and _board.enable_tracking:
			if sd:
				Capa.send_capability_status_changed(self, "`_should_deactivate(): %s`" % sd)
			if blocked:
				Capa.send_capability_status_changed(self, "binding tags `%s` blocked" % blocked_tags)
	else:
		var sa = _should_activate()
		if sa && !_is_binding_tag_blocked():
			_is_active = true
			_activated()
			emit_signal("activated")
			if OS.has_feature("editor") and _board.enable_tracking:
				Capa.send_capability_status_changed(self, "`_should_activate(): %s`" % sa)

# 对指定的标签进行加锁。
func block(tag: StringName) -> void:
	_board.block(tag, self)


# 对指定的标签进行解锁。
func unblock(tag: StringName) -> void:
	_board.unblock(tag, self)

# 判断指定的标签是否被阻塞。
func has_blocked(tag: StringName) -> bool:
	return _board.has_blocked(tag)

# 获取 Capability 所修饰的主节点
func get_target():
	return _board.get_parent()

func _is_binding_tag_blocked() -> bool:
	for tag in _binding_tags:
		if has_blocked(tag):
			return true
	return false

func _blocked_by() -> Array:
	var result = []
	for tag in _binding_tags:
		if has_blocked(tag):
			result.append(tag)
	return result

func bind_tag(tag: StringName) -> void:
	if not _binding_tags.has(tag):
		_binding_tags.append(tag)

func is_active() -> bool:
	return _is_active
