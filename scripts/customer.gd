extends Resource
class_name Customer

@export var recipe := ""
@export var name := ""
@export var order_id := 0
@export var preferences: Array[String] = []
@export var wpm: int

#Usage: var customer = Customer.new("Cheesecake", "Jun")

func _init(p_recipe: String, p_name: String, p_wpm: int):
	recipe = p_recipe
	name = p_name
	wpm = p_wpm
