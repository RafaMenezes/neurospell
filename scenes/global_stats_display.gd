extends Control


@onready var accuracy: Label = %Accuracy


func _ready() -> void:
	Stats.global_stats_updated.connect(_on_global_stats_updated)
	
	
func _on_global_stats_updated(global_accuracy, happy_customers, sad_customers, total_chars_typed, total_errors):
	accuracy.text = str(round(global_accuracy)) + "%"
