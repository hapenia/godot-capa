@tool
extends PanelContainer

@export var active_color: Color = Color8(127, 255, 0, 200) :
	set(v):
		active_color = v
		queue_redraw()

@export var disactive_color: Color = Color8(220, 20, 60, 200) :
	set(v):
		disactive_color = v
		queue_redraw()

@export var disabled_color: Color = Color8(127, 127, 127, 127) :
	set(v):
		disabled_color = v
		queue_redraw()

@export var mark_color: Color = Color8(255, 255, 255, 200) :
	set(v):
		mark_color = v
		queue_redraw()

@export var mark_length: int = 4 :
	set(v):
		mark_length = v
		queue_redraw()

@export var mark_width: float = -1 :
	set(v):
		mark_width = v
		queue_redraw()

@export var line_width: float = -1 :
	set(v):
		line_width = v
		queue_redraw()

@export var zoom: float = .1 :
	set(v):
		zoom = v
		queue_redraw()

@export_range(-1000000, 0) var scroll: int = 0 :
	set(v):
		scroll = v
		queue_redraw()

@export var latest_frame_idx: int :
	set(v):
		latest_frame_idx = v
		queue_redraw()

@export var data: Array[TimelineData]

func _draw() -> void:
	var bias = 0
	draw_set_transform(Vector2(size.x - scroll, size.y / 2))
	var curr_frame_idx = latest_frame_idx
	for i in range(data.size() - 1, -1, -1):
		var color = _line_color(data[i].status, data[i].enabled)
		var frame_idx = data[i].frame_idx
		var length = (curr_frame_idx - frame_idx) * zoom
		var vbias = Vector2.LEFT * bias
		var lpos = Vector2.LEFT * length
		# draw line
		draw_line(Vector2.ZERO + vbias, lpos + vbias, color, line_width)
		# draw marker
		_draw_marker(lpos + vbias)
		bias += length
		curr_frame_idx = frame_idx

func _draw_marker(pos: Vector2):
	var v = Vector2.UP * mark_length
	draw_line(pos + v, pos - v, mark_color, mark_width)

func _line_color(status: bool, enabled: bool) -> Color:
	if not enabled: return disabled_color
	return active_color if status else disactive_color

func append_data(d: TimelineData):
	data.append(d)
	queue_redraw()
