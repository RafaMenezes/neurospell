extends Node

signal global_stats_updated(global_accuracy, happy_customers, sad_customers, total_chars_typed, total_errors)

@onready var global_accuracy: float
@onready var happy_customers: int
@onready var sad_customers: int
@onready var total_chars_typed: int
@onready var total_errors: int


func update_global_stats(total_chars, errors):
	total_chars_typed += total_chars
	total_errors += errors
	
	var correct_chars := total_chars_typed - total_errors
	
	global_accuracy = correct_chars * 100.0 / total_chars_typed
	
	global_stats_updated.emit(global_accuracy, happy_customers, sad_customers, total_chars_typed, total_errors)
	
