class_name TypableText
extends Control

@export var max_errors_allowed: int = 3
@export var auto_focus: bool = true
@export var sound: AudioStream

@onready var target: Label = get_parent() as Label
@onready var _input := LineEdit.new()
@onready var _text_root := VBoxContainer.new()
@onready var llm : LLM = get_tree().get_first_node_in_group("llm")

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
	
	llm.generate_text_finished.connect(_on_gdllama_finished)
	
func _on_gdllama_finished(text: String):
	_setup_input()
	_reset_state()
	_setup_text_labels(text)

func _setup_input() -> void:
	_input.max_length = 1
	_input.text = ""
	# making it invisible makes input handling stop working, so push it to some place out of sight
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

func _make_line() -> HBoxContainer:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 0)
	h.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	h.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_text_root.add_child(h)
	_line_containers.append(h)
	return h
		
func _setup_text_labels(text: String) -> void:
	_char_labels.clear()
	_line_containers.clear()
	_text_root.queue_free()

	_text_root = VBoxContainer.new()
	_text_root.name = "TextRoot"
	_text_root.add_theme_constant_override("separation", 0)
	add_child(_text_root)
	target.visible_characters = 0

	# helper function to spawn a clean line container


	var current_line := _make_line()

	for ch in text:
		if ch == "\n":
			# placeholder to keep char index aligned
			var placeholder := Label.new()
			placeholder.text = ""
			placeholder.visible = false
			current_line.add_child(placeholder)
			_char_labels.append(placeholder)

			current_line = _make_line()
			continue

		var lbl := Label.new()
		lbl.text = ch
		lbl.custom_minimum_size = Vector2.ZERO
		lbl.clip_text = false
		lbl.add_theme_constant_override("line_spacing", 0)
		lbl.add_theme_constant_override("outline_size", 0)
		lbl.add_theme_font_override("font", target.get_theme_font("font"))
		lbl.add_theme_font_size_override("font_size", target.get_theme_font_size("font_size"))
		lbl.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		lbl.size_flags_vertical = Control.SIZE_SHRINK_CENTER

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
	
	if expected == "\n":
		_index += 1
		expected = text_to_type[_index]
		
	var correct := ch == expected

	char_typed.emit(correct, expected, ch)
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

	typing_finished.emit(success, elapsed, _errors, accuracy)
	_input.release_focus()
