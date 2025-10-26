extends Control


@onready var accuracy: Label = %Accuracy
@onready var chars_typed: Label = %CharsTyped


func _ready() -> void:
	Stats.global_stats_updated.connect(_on_global_stats_updated)
	
	
func _on_global_stats_updated(global_accuracy, happy_customers, sad_customers, total_chars_typed, total_errors):
	accuracy.text = "Accuracy: " + str(round(global_accuracy)) + "%"
	chars_typed.text = "Total letters typed: " + str(total_chars_typed)
