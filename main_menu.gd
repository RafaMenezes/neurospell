extends Control

@onready var typable_text: TypableText = $Play/TypableText
@onready var label: Label = $Play
@onready var game_scene = preload("res://scenes/main.tscn")

func _ready() -> void:
	Events.text_configured.emit(label.text)
	typable_text.typing_finished.connect(_on_typing_finished)
	
	
func _on_typing_finished(success: bool, time_taken: float, errors: int, accuracy: float) -> void:
	print("here")
	get_tree().change_scene_to_packed(game_scene)
