@tool
extends EditorPlugin

const EDITOR_PANEL = preload("./editor/capa_debugger_editor_panel.tscn")

## Debugger object that listens to Godot's callbacks
var debugger: CapaDebugger = null

## Inspector plugin that allows selecting remote scene nodes
var remote_node_inspector: CapaInspectorPlugin = null

## Editor panel that draws data received from remote scene
var editor_panel: CapaEditorPanel = null

func _enable_plugin() -> void:
	# Add autoloads here.
	add_autoload_singleton("Capa", "./capa.gd")

func _disable_plugin() -> void:
	# Remove autoloads here.
	remove_autoload_singleton("Capa")

func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	debugger = CapaDebugger.new()
	remote_node_inspector = CapaInspectorPlugin.new()
	editor_panel = EDITOR_PANEL.instantiate()
	
	add_debugger_plugin(debugger)
	add_inspector_plugin(remote_node_inspector)
	
	debugger.setup_editor_panel(editor_panel)
	
	editor_panel.inspect_item_request.connect(debugger.request_inspect_node_from_remote)
	remote_node_inspector.node_selected.connect(debugger.request_capability_board_data_from_remote)
	debugger.received_capability_board_data_from_remote.connect(editor_panel.show_capability_board)
	debugger.received_capability_data_from_remote.connect(editor_panel.update_timeline_data)
	debugger.sync_view.connect(editor_panel.sync_view)
	# Connect start and stop debugging signals for editor panel setup/cleanup
	debugger.started.connect(editor_panel.start_session)
	debugger.stopped.connect(editor_panel.stop_session)

func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	# De-register plugins from engine
	remove_debugger_plugin(debugger)
	remove_inspector_plugin(remote_node_inspector)
	
	# Remove references to initialized components
	remote_node_inspector = null
	debugger = null
	editor_panel = null
