class_name RoundTimer
extends Node2D
signal time_up

@export var radius: float = 48.0
@export var inner_radius: float = 30.0
@export var segments: int = 64
@export var fill_color: Color = Color(1, 0.5, 0)
@export var bg_color: Color = Color(0.15, 0.15, 0.15, 0.7)
@export var show_bg_ring: bool = true

@export_group("Text Display")
@export var show_time_text: bool = true
@export var text_color: Color = Color.WHITE
@export var text_font: Font
@export var font_size: int = 24
@export var decimal_places: int = 1

var total_time: float = 1.0
var elapsed: float = 0.0
var running: bool = false

func start(sec: float) -> void:
	total_time = max(0.0001, sec)
	elapsed = 0.0
	running = true
	queue_redraw()

func stop() -> void:
	running = false
	queue_redraw()

func reset() -> void:
	elapsed = 0.0
	running = false
	queue_redraw()

func is_running() -> bool:
	return running

func time_left() -> float:
	return max(0.0, total_time - elapsed)

func _process(delta: float) -> void:
	if not running:
		return
	elapsed += delta
	if elapsed >= total_time:
		elapsed = total_time
		running = false
		emit_signal("time_up")
	queue_redraw()

func _format_time(seconds: float) -> String:
	if seconds >= 60:
		# Format as MM:SS
		var minutes = int(seconds / 60)
		var secs = int(seconds) % 60
		return "%d:%02d" % [minutes, secs]
	else:
		# Format as seconds with decimals
		if decimal_places == 0:
			return "%d" % int(seconds)
		else:
			var format_str = "%." + str(decimal_places) + "f"
			return format_str % seconds

func _draw() -> void:
	if radius <= inner_radius:
		return

	var frac = clamp(1.0 - elapsed / total_time, 0.0, 1.0)

	# Draw background ring
	if show_bg_ring:
		var mid_rad_bg = (radius + inner_radius) * 0.5
		var width_bg = radius - inner_radius
		draw_arc(Vector2.ZERO, mid_rad_bg, -PI/2, -PI/2 + TAU, max(12, segments), bg_color, width_bg)

	# Draw progress arc
	if frac > 0.0:
		var mid_rad = (radius + inner_radius) * 0.5
		var width = radius - inner_radius
		var sweep = - TAU * frac
		var segs = max(4, int(segments * frac))
		draw_arc(Vector2.ZERO, mid_rad, -PI/2, -PI/2 + sweep, segs, fill_color, width)
	
	# Draw time text in the center
	if show_time_text:
		var time_str = _format_time(time_left())
		var font_to_use = text_font if text_font else ThemeDB.fallback_font
		if font_to_use:
			var text_size = font_to_use.get_string_size(time_str, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
			var text_pos = Vector2(-text_size.x * 0.5, text_size.y * 0.25)
			draw_string(font_to_use, text_pos, time_str, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, text_color)
