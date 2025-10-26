extends Control

@onready var game_scene = preload("res://scenes/main.tscn")
@onready var play: Label = $Play
@onready var play_typable_text: TypableText = $Play/TypableText
@onready var quit: Label = $Quit
@onready var quit_typable_text: TypableText = $Quit/TypableText
var active_typable_text: TypableText = null


func _ready() -> void:
	Events.text_configured.emit(play.text, false)
	Events.text_configured.emit(quit.text, false)
	play_typable_text.typing_finished.connect(_on_play_typing_finished)
	quit_typable_text.typing_finished.connect(_on_quit_typing_finished)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var ch := event.as_text()
		if not active_typable_text:
			match ch.to_lower():
				"p":
					active_typable_text = play_typable_text
				"q":
					active_typable_text = quit_typable_text
			if active_typable_text:
				# ensure TypableText has labels ready
				if active_typable_text._char_labels.size() == 0:
					return  # skip first key until initialized
				active_typable_text._input.grab_focus()
				active_typable_text._process_char(ch.to_lower())
				return
		else:
			active_typable_text._process_char(ch) # consume this key, do not fall through

		# Subsequent input goes to active TypableText
		if active_typable_text:
			active_typable_text._process_char(ch)


func _on_play_typing_finished(success: bool, time_taken: float, errors: int, accuracy: float) -> void:
	if errors > 0:
		_reset_menu_typable(play_typable_text, play.text)
		return
	Stats.happy_customers = 0
	Stats.sad_customers = 0
	Stats.global_accuracy = 0.0
	get_tree().change_scene_to_packed(game_scene)


func _on_quit_typing_finished(success: bool, time_taken: float, errors: int, accuracy: float) -> void:
	if errors > 0:
		_reset_menu_typable(quit_typable_text, quit.text)
		return
	get_tree().quit()


func _reset_menu_typable(tt: TypableText, text: String) -> void:
	tt._reset_state()
	tt._setup_text_labels(text)
	active_typable_text = null
