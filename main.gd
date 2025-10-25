# typing_game_fixed_gd4.gd
extends Control

@export var text_to_type: String = "Type this sample text!"
@export var max_errors_allowed: int = 3
@export var char_font_size: int = 28
@export var spacing: int = 6

# UI nodes
@onready var _text_container := $UI/TextContainer as HBoxContainer
@onready var _input := $UI/Input as LineEdit
@onready var _errors_label := $UI/StatsRow/ErrorsLabel as Label
@onready var _timer_label := $UI/StatsRow/TimerLabel as Label
@onready var _streak_label := $UI/StatsRow/StreakLabel as Label
@onready var _restart_button := $UI/Buttons/RestartButton as Button

# runtime state
var _labels: Array = []
var _index: int = 0
var _errors: int = 0
var _started: bool = false
var _start_time: float = 0.0
var _end_time: float = 0.0
var _current_streak: int = 0
var _longest_streak: int = 0

func _ready() -> void:
	_input.max_length = 1
	_input.text = ""
	_input.grab_focus()
	_input.placeholder_text = "Type..."
	_input.connect("text_changed", Callable(self, "_on_Input_text_changed"))
	_restart_button.connect("pressed", Callable(self, "_on_RestartButton_pressed"))
	_setup_text_display(text_to_type)
	_update_stats_labels()

func _setup_text_display(text: String) -> void:
	# Clear previous state and nodes
	for child in _text_container.get_children():
		child.queue_free()
	_labels.clear()
	_index = 0
	_errors = 0
	_started = false
	_current_streak = 0
	_longest_streak = 0
	_start_time = 0.0
	_end_time = 0.0

	# spacing for HBoxContainer (Godot 4 uses theme constants)
	_text_container.add_theme_constant_override("separation", spacing)

	# Build a Label node per character (iterate characters directly)
	var idx := 0
	for ch in text:
		var lbl := Label.new()
		lbl.text = String(ch)
		lbl.name = str(idx)
		# give a minimum size so characters don't bunch
		lbl.custom_minimum_size = Vector2(char_font_size * 0.6, char_font_size * 1.2)
		# neutral color
		lbl.modulate = Color(0.85, 0.85, 0.85)
		_text_container.add_child(lbl)
		_labels.append(lbl)
		idx += 1

	_highlight_current()

func _highlight_current() -> void:
	# iterate indÍices correctly
	for i in range(_labels.size()):
		var l = _labels[i]
		if i == _index:
			# slightly brighter / scaled to indicate the next character
			if l.modulate == Color(0.85, 0.85, 0.85):
				l.modulate = Color(1.0, 1.0, 1.0)
			# scale Controls via rect_scale (Control still exposes rect_scale in 4.x)
			l.scale = Vector2(1.05, 1.05)
		else:
			# keep already-colored (green/red). If untyped, neutral
			if l.modulate == Color(1.0, 1.0, 1.0):
				l.modulate = Color(0.85, 0.85, 0.85)
			l.scale = Vector2(1, 1)

func _on_Input_text_changed(new_text: String) -> void:
	if new_text.length() == 0:
		return
	var ch := new_text[0]
	_input.text = ""
	_process_char(ch)

func _process_char(ch: String) -> void:
	if not _started:
		_started = true
		_start_time = Time.get_ticks_msec() / 1000.0

	if _index >= _labels.size():
		return

	var expected = _labels[_index].text
	var correct = ch == expected

	if correct:
		_labels[_index].modulate = Color(0.0, 0.6, 0.0) # green
		_current_streak += 1
		if _current_streak > _longest_streak:
			_longest_streak = _current_streak
	else:
		_labels[_index].modulate = Color(0.7, 0.0, 0.0) # red
		_errors += 1
		_current_streak = 0

	_index += 1
	_highlight_current()
	_update_stats_labels()

	if _errors > max_errors_allowed:
		_lose()
		return

	if _index >= _labels.size():
		_win()
		return

func _update_stats_labels() -> void:
	_errors_label.text = "Errors: %d / %d" % [_errors, max_errors_allowed]
	if _started and _end_time == 0.0:
		var elapsed := Time.get_ticks_msec() / 1000.0 - _start_time
		_timer_label.text = "Time: %s" % _format_seconds(elapsed)
	elif _end_time > 0.0:
		_timer_label.text = "Time: %s" % _format_seconds(_end_time - _start_time)
	else:
		_timer_label.text = "Time: 0.00 s"
	_streak_label.text = "Longest streak: %d" % _longest_streak

func _format_seconds(sec: float) -> String:
	return String("%.2f s" % sec)

func _win() -> void:
	_end_time = Time.get_ticks_msec() / 1000.0
	_update_stats_labels()
	var total_time := _end_time - _start_time
	var correct_chars := _labels.size() - _errors
	var accuracy := 0.0
	if _labels.size() > 0:
		accuracy = correct_chars * 100.0 / _labels.size()
	_show_result_popup("You win!\nTime: %s\nErrors: %d\nLongest streak: %d\nAccuracy: %.1f%%"
		% [_format_seconds(total_time), _errors, _longest_streak, accuracy])

func _lose() -> void:
	_end_time = Time.get_ticks_msec() / 1000.0
	_update_stats_labels()
	_show_result_popup("You lost — too many errors (%d).\nRestart to try again." % _errors)
	_input.editable = false

func _show_result_popup(text: String) -> void:
	var p := AcceptDialog.new()
	# AcceptDialog supports dialog text in 4.x; if you see an error here,
	# replace the next line with `p.add_child(Label.new())` style popup creation.
	p.dialog_text = text
	add_child(p)
	p.popup_centered_minsize(Vector2(300, 120))

func _on_RestartButton_pressed() -> void:
	_input.editable = true
	_input.text = ""
	_setup_text_display(text_to_type)
	_update_stats_labels()
	_input.grab_focus()
