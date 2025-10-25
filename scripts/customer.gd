extends Resource
class_name Customer

@export var recipe := ""
@export var name := ""
@export var order_id := 0
@export var preferences: Array[String] = []

#Usage: var customer = Customer.new("Cheesecake", "Jun")

func _init(p_recipe := "", p_name := ""):
	recipe = p_recipe
	name = p_name
