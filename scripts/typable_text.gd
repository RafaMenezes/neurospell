class_name TypableText
extends Control

@export var max_errors_allowed: int = 3
@export var auto_focus: bool = true

@onready var target: Label = get_parent() as Label
@onready var _input := LineEdit.new()
@onready var _text_root := VBoxContainer.new()

var _line_containers: Array = []
var _char_labels: Array = []

var _index: int = 0
var _errors: int = 0
var _started: bool = false
var _start_time: float = 0.0
var _end_time: float = 0.0

signal typing_started
signal char_typed(correct: bool, expected: String, typed: String)
signal typing_finished(success: bool, time_taken: float, errors: int, accuracy: float)

func _ready() -> void:
	if not target:
		push_warning("TypableText: No attached Label found. This script must be a sibling or child of a Label node.")
		return

	_setup_input()
	_reset_state()
	_setup_text_labels(target.text)

func _setup_input() -> void:
	_input.max_length = 1
	_input.text = ""
	_input.position.x = -99999
	add_child(_input)
	_input.text_changed.connect(_on_input_changed)

	if auto_focus:
		_input.grab_focus()

func _reset_state() -> void:
	_index = 0
	_errors = 0
	_started = false
	_start_time = 0.0
	_end_time = 0.0

func _setup_text_labels(text: String) -> void:
	_char_labels.clear()
	_line_containers.clear()
	_text_root.queue_free()  # Remove old one if re-initializing
	_text_root = VBoxContainer.new()
	_text_root.name = "TextRoot"
	_text_root.add_theme_constant_override("separation", 4)
	add_child(_text_root)
	target.visible_characters = 0


	var current_line := HBoxContainer.new()
	_text_root.add_child(current_line)
	_line_containers.append(current_line)

	for ch in text:
		if ch == "\n":
			current_line = HBoxContainer.new()
			_text_root.add_child(current_line)
			_line_containers.append(current_line)
			continue
		var lbl := Label.new()
		lbl.text = ch
		lbl.modulate = Color(0.85, 0.85, 0.85)
		current_line.add_child(lbl)
		_char_labels.append(lbl)

func _on_input_changed(new_text: String) -> void:
	if new_text.is_empty():
		return

	var ch := new_text[0]
	_input.text = ""
	_process_char(ch)

func _process_char(ch: String) -> void:
	if not _started:
		_started = true
		_start_time = Time.get_ticks_msec() / 1000.0
		emit_signal("typing_started")

	var text_to_type: String = target.text
	if _index >= text_to_type.length():
		return

	var expected := text_to_type[_index]
	var correct := ch == expected
	emit_signal("char_typed", correct, expected, ch)
	if correct:
		_char_labels[_index].modulate = Color(0.0, 0.7, 0.0)  # green if correct
		_index += 1
	else:
		_char_labels[_index].modulate = Color(0.7, 0.0, 0.0)  # red if incorrect
		_errors += 1

	if _errors > max_errors_allowed:
		_finish(false)
		return

	if _index >= text_to_type.length():
		_finish(true)
		return

func _finish(success: bool) -> void:
	_end_time = Time.get_ticks_msec() / 1000.0
	var elapsed := _end_time - _start_time
	print(elapsed)
	var total_chars := target.text.length()
	var correct_chars := total_chars - _errors
	var accuracy := 0.0
	if total_chars > 0:
		accuracy = correct_chars * 100.0 / total_chars

	emit_signal("typing_finished", success, elapsed, _errors, accuracy)
	_input.release_focus()
