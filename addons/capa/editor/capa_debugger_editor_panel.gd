@tool
class_name CapaEditorPanel extends Control

signal inspect_item_request(nodepath)

var capability_boards: Dictionary = {}
var capabilities_timeline_data: Dictionary

func show_capability_board(data):
	var board_info = data[0]
	var capability_board_id = board_info["id"]
	capability_boards[capability_board_id] = board_info
	var view = $PanelContainer/VBoxContainer/CapabilityTreeView
	view.reset()
	var root = view.create_item()
	for board in capability_boards:
		_create_capability_board_treeitems(root, capability_boards[board])

func _create_capability_board_treeitems(root: TreeItem, board_info: Dictionary):
	var view = $PanelContainer/VBoxContainer/CapabilityTreeView
	var board = view.create_non_capability_treeitem(root, board_info["path"].slice(-2), board_info["id"], board_info["path"])
	board.collapsed = true
	_create_children_treeitems(board, board_info["children"])

func _create_children_treeitems(parent: TreeItem, children: Array):
	var view = $PanelContainer/VBoxContainer/CapabilityTreeView
	for node in children:
		var child
		if node["is_capability"]:
			child = view.create_capability_treeitem(parent, node["name"], node["id"], node["path"])
		else:
			if node["children"].is_empty(): continue
			child = view.create_non_capability_treeitem(parent, node["name"], node["id"], node["path"])
		_create_children_treeitems(child, node["children"])

func start_session():
	$PanelContainer/VBoxContainer/HBoxContainer/Filter.editable = true
	$PanelContainer/VBoxContainer/CapabilityTreeView.reset()
	$PanelContainer/VBoxContainer/HBoxContainer/FrameSpinBox.editable = true
	capability_boards.clear()
	capabilities_timeline_data.clear()

func stop_session():
	$PanelContainer/VBoxContainer/HBoxContainer/Filter.editable = false
	$PanelContainer/VBoxContainer/HBoxContainer/Filter.clear()
	$PanelContainer/VBoxContainer/CapabilityTreeView.reset()
	$PanelContainer/VBoxContainer/HBoxContainer/FrameSpinBox.value = 0
	$PanelContainer/VBoxContainer/HBoxContainer/FrameSpinBox.editable = false

func sync_view(data):
	var latest_frame_idx = data[0]
	$PanelContainer/VBoxContainer/HBoxContainer/HScrollBar.max_value = latest_frame_idx
	$PanelContainer/VBoxContainer/HBoxContainer/HScrollBar.value = latest_frame_idx
	$PanelContainer/VBoxContainer/HBoxContainer/FrameSpinBox.max_value = latest_frame_idx
	$PanelContainer/VBoxContainer/HBoxContainer/FrameSpinBox.value = latest_frame_idx
	$PanelContainer/VBoxContainer/CapabilityTreeView.cursor_frame_idx = latest_frame_idx
	$PanelContainer/VBoxContainer/CapabilityTreeView.latest_frame_idx = latest_frame_idx
	_set_scroller_page()

func update_timeline_data(data: Array):
	var cap_data = data[0]
	var cap_id = cap_data["id"]
	var cap_name = cap_data["name"]
	var frame_idx = cap_data["frame_idx"]
	var status = cap_data["status"]
	var enabled = cap_data["enabled"]
	var msg = cap_data["msg"]
	var timeline_data_arr: Array = capabilities_timeline_data.get_or_add(cap_id, [])
	var timeline_data = TimelineData.new()
	timeline_data.frame_idx = frame_idx
	timeline_data.status = status
	timeline_data.enabled = enabled
	timeline_data.msg = msg
	timeline_data_arr.append(timeline_data)

func _on_zoom_slider_value_changed(value: float) -> void:
	$PanelContainer/VBoxContainer/CapabilityTreeView.zoom = value
	$PanelContainer/VBoxContainer/HBoxContainer/HScrollBar.value = $PanelContainer/VBoxContainer/HBoxContainer/HScrollBar.max_value


func _on_clear_button_pressed() -> void:
	capability_boards.clear()
	capabilities_timeline_data.clear()
	$PanelContainer/VBoxContainer/CapabilityTreeView.reset()
	$PanelContainer/VBoxContainer/HBoxContainer/FrameSpinBox.value = 0
	$PanelContainer/VBoxContainer/HBoxContainer/FrameSpinBox.editable = false


func _set_scroller_page():
	var page = $PanelContainer/VBoxContainer/CapabilityTreeView.get_column_width(1) / ($PanelContainer/VBoxContainer/CapabilityTreeView.zoom)
	$PanelContainer/VBoxContainer/HBoxContainer/HScrollBar.page = page

func _on_frame_spin_box_value_changed(value: float) -> void:
	$PanelContainer/VBoxContainer/CapabilityTreeView.cursor_frame_idx = roundi(value)

func _on_h_scroll_bar_value_changed(value: float) -> void:
	var max_val = $PanelContainer/VBoxContainer/HBoxContainer/HScrollBar.max_value
	var zoom = $PanelContainer/VBoxContainer/CapabilityTreeView.zoom
	var page = $PanelContainer/VBoxContainer/HBoxContainer/HScrollBar.page
	$PanelContainer/VBoxContainer/CapabilityTreeView.scroll = max_val - value - page

func _on_capability_tree_view_zoom_changed() -> void:
	#$PanelContainer/VBoxContainer/HBoxContainer/HScrollBar.
	_set_scroller_page()

func _on_filter_text_changed(new_text: String) -> void:
	var view = $PanelContainer/VBoxContainer/CapabilityTreeView
	var filters = new_text.split(",")
	var filters_remove_empty_str: Array = []
	for i in filters:
		if i != "":
			filters_remove_empty_str.append(i)
	view.filter_tree(view.get_root(), filters_remove_empty_str)
	view.get_root().set_collapsed_recursive(false)


func _on_capability_tree_view_item_selected() -> void:
	print("selected")
	var view = $PanelContainer/VBoxContainer/CapabilityTreeView
	var selected = view.get_selected()
	var node_path = selected.get_meta(view.META_NODE_PATH)
	print(node_path)
	inspect_item_request.emit(node_path)
