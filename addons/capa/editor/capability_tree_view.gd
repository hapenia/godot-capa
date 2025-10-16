@tool
extends Tree

signal zoom_changed()

@export var active_color: Color = Color8(127, 255, 0, 200) :
	set(v):
		active_color = v
		#queue_redraw()

@export var disactive_color: Color = Color8(220, 20, 60, 200) :
	set(v):
		disactive_color = v
		#queue_redraw()

@export var marker_active_color: Color = Color8(127, 255, 0, 200) :
	set(v):
		marker_active_color = v
		#queue_redraw()

@export var marker_disactive_color: Color = Color8(220, 20, 60, 200) :
	set(v):
		marker_disactive_color = v
		#queue_redraw()

@export var disabled_color: Color = Color8(127, 127, 127, 127) :
	set(v):
		disabled_color = v
		#queue_redraw()

@export var track_color: Color = Color8(127, 127, 127, 100) :
	set(v):
		track_color = v
		#queue_redraw()

@export var mark_length: int = 4 :
	set(v):
		mark_length = v
		#queue_redraw()

@export var mark_width: float = -1 :
	set(v):
		mark_width = v
		#queue_redraw()

@export var line_width: float = 5 :
	set(v):
		line_width = v
		#queue_redraw()


@export var track_width: float = 12 :
	set(v):
		track_width = v
		queue_redraw()

@export var zoom: float = .25 :
	set(v):
		zoom = v
		zoom_changed.emit()
		queue_redraw()

@export var scroll: int = 0 :
	set(v):
		scroll = v
		queue_redraw()

@export var latest_frame_idx: int :
	set(v):
		latest_frame_idx = v
		queue_redraw()

@export var cursor_frame_idx: int :
	set(v):
		cursor_frame_idx = v
		#region update indicator
		for item in _capability_items:
			var data = get_capability_timeline_data(item.get_meta(META_NODE_ID))
			var cursor_in_marker = false
			var current_active = false
			for i in range(data.size() - 1, -1, -1):
				var frame_idx = data[i].frame_idx
				if frame_idx < cursor_frame_idx:
					current_active = data[i].status
					break
				if cursor_frame_idx == frame_idx:
					var suffix = "[Activated]" if data[i].status else "[Deactivated]"
					var marker_color = _marker_color(data[i].status, data[i].enabled)
					var msg_str = "%s %s at frame #%s:: %s" % [suffix, item.get_meta(META_NODE_NAME), frame_idx, data[i].msg]
					var marker_color_no_alpha = marker_color
					marker_color_no_alpha.a = 1
					item.set_button_disabled(0, 0, false)
					item.set_button_color(0, 0, marker_color_no_alpha)
					item.set_button_tooltip_text(0, 0, msg_str)
					cursor_in_marker = true
			if not cursor_in_marker:
				item.set_button_disabled(0, 0, not current_active)
				item.set_button_color(0, 0, Color.WHITE)
				item.set_button_tooltip_text(0, 0, "")
		#endregion
		queue_redraw()

var _capability_items: Array[TreeItem]

const META_NODE_ID = &"node_id"
const META_NODE_NAME = &"node_name"
const META_NODE_PATH = &"node_path"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reset()
	#var root = create_item()
	#var item = create_capability_treeitem(root, "Foo", 0)

func reset() -> void:
	_capability_items.clear()
	clear()
	columns = 2
	column_titles_visible = true
	set_column_title(0, "Capability")
	set_column_title(1, "Time")
	set_column_custom_minimum_width(0, _with_scale(250))
	#set_column_clip_content(0, true)
	set_column_expand(0, false)
	set_column_expand(1, true)

const INDICATOR_ICON = preload("res://addons/capa/indicator.svg")

func create_capability_treeitem(parent: TreeItem, cap_name: String, cap_id: int, path: NodePath) -> TreeItem:
	var item = create_item(parent)
	item.set_meta(META_NODE_NAME, cap_name)
	item.set_meta(META_NODE_ID, cap_id)
	item.set_meta(META_NODE_PATH, path)
	item.set_auto_translate_mode(0, Node.AUTO_TRANSLATE_MODE_DISABLED)
	item.set_text(0, cap_name)
	item.add_button(0, INDICATOR_ICON, 0, true)
	item.set_cell_mode(1, TreeItem.CELL_MODE_CUSTOM)
	item.set_custom_draw_callback(1, _capability_timeline_draw_cb)
	_capability_items.append(item)
	return item

func create_non_capability_treeitem(parent: TreeItem, node_name: String, id: int, path: NodePath) -> TreeItem:
	var item = create_item(parent)
	item.set_text(0, node_name)
	item.set_meta(META_NODE_NAME, node_name)
	item.set_meta(META_NODE_ID, id)
	item.set_meta(META_NODE_PATH, path)
	EditorInterface.get_editor_settings().get("interface/editor/main_font_size")
	item.set_custom_bg_color(0, Color(0,0,0,0.25))
	item.set_custom_bg_color(1, Color(0,0,0,0.25))
	item.set_auto_translate_mode(0, Node.AUTO_TRANSLATE_MODE_DISABLED)
	return item


func filter_tree(root_item: TreeItem, filterstr: Array) -> bool:
	var should_visible = false
	var node_name: String = root_item.get_meta(META_NODE_NAME, "")
	var has_child_visible = false
	for child in root_item.get_children():
		if filter_tree(child, filterstr):
			has_child_visible = true
	var matched = false
	for str in filterstr:
		if node_name.to_lower().contains(str.to_lower()):
			matched = true
			break
	if filterstr.is_empty(): matched = true
	should_visible = matched or has_child_visible
	root_item.visible = should_visible
	return should_visible

#func set_visibility_recursive()

func get_capability_timeline_data(cap_id: int) -> Array:
	return owner.capabilities_timeline_data.get(cap_id, [])

func _draw_marker(pos: Vector2, color: Color):
	var v = Vector2.UP * mark_length
	draw_line(pos + v, pos - v, color, mark_width)

func _line_color(status: bool, enabled: bool) -> Color:
	if not enabled: return disabled_color
	return active_color if status else disactive_color

func _marker_color(status: bool, enabled: bool) -> Color:
	if not enabled: return disabled_color
	return marker_active_color if status else marker_disactive_color

func _with_scale(width):
	var scale = EditorInterface.get_editor_scale()
	return width * scale

func _capability_timeline_draw_cb(item: TreeItem, rect: Rect2):
	timeline_end_x = rect.end.x
	var data = get_capability_timeline_data(item.get_meta(META_NODE_ID))
	var bias = 0
	var curr_frame_idx = latest_frame_idx
	var mouse_pos = get_local_mouse_position()
	var mouse_indicator_x = mouse_pos.x
	if mouse_indicator_x < rect.position.x:
		mouse_indicator_x = rect.position.x
	# draw bg
	draw_rect(rect, Color(0, 0, 0, 0.1))
	# draw mouse_indicator
	draw_line(Vector2(mouse_indicator_x, rect.position.y), Vector2(mouse_indicator_x, rect.position.y + rect.size.y), Color(1, 1, 1, 0.5))
	# center left of the cell
	var mat = Transform2D(0, Vector2(-zoom, _with_scale(1)), 0, Vector2.UP * rect.size.y / 2 + rect.end)
	draw_set_transform_matrix(mat)
	#draw_set_transform(Vector2.UP * rect.size.y / 2 + rect.end, 0, Vector2(-1, 1))
	# draw track
	var frame0_x = latest_frame_idx - scroll
	draw_line(Vector2.ZERO, Vector2.RIGHT * clampf(frame0_x, 0, rect.size.x / zoom), track_color, track_width)
	for i in range(data.size() - 1, -1, -1):
		var color = _line_color(data[i].status, data[i].enabled)
		var frame_idx = data[i].frame_idx
		var length = curr_frame_idx - frame_idx
		var vbias = bias - scroll
		var p0_x = length + vbias
		# draw line
		draw_line(Vector2.RIGHT * clampf(vbias, 0, rect.size.x / zoom), Vector2.RIGHT * clampf(p0_x, 0, rect.size.x / zoom), color, line_width)
		bias += length
		curr_frame_idx = frame_idx
	var cursor_in_marker = false
	for i in range(data.size() - 1, -1, -1):
		var marker_color = _marker_color(data[i].status, data[i].enabled)
		var frame_idx = data[i].frame_idx
		var length = curr_frame_idx - frame_idx
		var vbias = bias - scroll
		var marker_x = length + vbias
		# draw marker
		if marker_x >= 0 and marker_x <= rect.size.x / zoom:
			_draw_marker(Vector2.RIGHT * clampf(marker_x, 0, rect.size.x / zoom), marker_color)
		bias += length
		curr_frame_idx = frame_idx
	var cursor_x = (latest_frame_idx - cursor_frame_idx) - scroll
	var cursor_length = rect.size.y / _with_scale(2)
	if cursor_x >= 0 and cursor_x < rect.size.x / zoom:
		_draw_cursor(cursor_x, cursor_length, Color.WHITE)
	# draw frame #0 indicator
	if frame0_x >= 0 and frame0_x <= rect.size.x / zoom:
		_draw_cursor(clampf(frame0_x, 0, rect.size.x / zoom), cursor_length, Color(1, 1, 0, 0.5))
	draw_set_transform(Vector2.ZERO)

var timeline_end_x = 0
#var timeline

func _draw_cursor(pos_x: float, len: float, color: Color):
	var length = len
	draw_line(Vector2(pos_x, -length), Vector2(pos_x, length), color)

const MOVE_LEFT = preload("res://addons/capa/move_timeline_left.tres")
const MOVE_RIGHT = preload("res://addons/capa/move_timeline_right.tres")
const ZOOM_IN = preload("res://addons/capa/zoom_in_shortcut.tres")
const ZOOM_OUT = preload("res://addons/capa/zoom_out_shortcut.tres")

func _gui_input(event: InputEvent) -> void:
	if ZOOM_IN.matches_event(event):
		$"../HBoxContainer/ZoomSlider".value *= 1.05
		get_viewport().set_input_as_handled()
	if MOVE_LEFT.matches_event(event):
		$"../HBoxContainer/HScrollBar".value += 20 / zoom
		get_viewport().set_input_as_handled()
	if ZOOM_OUT.matches_event(event):
		$"../HBoxContainer/ZoomSlider".value *= 0.95
		get_viewport().set_input_as_handled()
	if MOVE_RIGHT.matches_event(event):
		$"../HBoxContainer/HScrollBar".value -= 20 / zoom
		get_viewport().set_input_as_handled()
	if event.is_action("ui_left"):
		if event.is_pressed():
			$"../HBoxContainer/FrameSpinBox".value -= 1
		get_viewport().set_input_as_handled()
	if event.is_action("ui_right"):
		if event.is_pressed():
			$"../HBoxContainer/FrameSpinBox".value += 1
		get_viewport().set_input_as_handled()
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var mouse_in_timeline_x = timeline_end_x - get_local_mouse_position().x
			if mouse_in_timeline_x <= get_column_width(1):
				var mouse_frame = latest_frame_idx - mouse_in_timeline_x / zoom - scroll
				$"../HBoxContainer/FrameSpinBox".value = mouse_frame
	if event is InputEventMouseMotion:
		queue_redraw()
