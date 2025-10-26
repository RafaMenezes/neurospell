extends Node

@onready var llm: LLM = $LLM
@onready var recipe_ui_scene := preload("res://scenes/recipe_ui.tscn")
@onready var recipe_text_displayed: bool = false
@onready var customer_scene := preload("res://scenes/customer.tscn")
var customer: Customer
@export var round_timer: RoundTimer

var prompt_template = """<|begin_of_text|><|start_header_id|>system<|end_header_id|>
You are a concise recipe generator. Always respond in plain prose, never in numbered steps or bullet points. Write only the essential cooking process, no introductions, no conclusions, no list of ingredients. Keep it under 100 tokens.
<|eot_id|><|start_header_id|>user<|end_header_id|>
Write a short and direct cooking recipe for {recipe}. Use two brief natural-language paragraphs, without any bullet points or numbers.
<|eot_id|><|start_header_id|>assistant<|end_header_id|>
"""

func spawn_customer():
	customer = customer_scene.instantiate()
	add_child(customer)

func _ready() -> void:
	llm.generate_text_finished.connect(_on_gdllama_finished)
	
	round_timer.visible = false
	round_timer.stop()
	round_timer.time_up.connect(_on_time_up)

	spawn_customer()
	
	var prompt = prompt_template.format({"recipe": customer.data.recipe})
	llm.run_generate_text(prompt)
	print("generating text...")


func _on_typing_started(text: String) -> void:
	var word_count = text.split(" ", false).size()
	# compute seconds: characters -> reading speed in words-per-minute; keep your formula
	var max_time = word_count * 60.0 / customer.data.wpm
	round_timer.visible = true
	round_timer.start(max_time)
	
func _on_time_up() -> void:
	print("You didn't make it in time! The customer leaves very angry...")
	round_timer.stop()
	
	var recipe_ui = get_tree().get_first_node_in_group("recipeui")
	recipe_ui.queue_free()
	
	recipe_text_displayed = false

func _on_typing_finished(success: bool, time_taken: float, errors: int, accuracy: float) -> void:
	if success:
		print("You made it! The customer is happy!")
	else:
		print("The food turned out CRAP! The customer leaves very angry...")
		
	print("Total errors: ", errors)
	print("Accuracy: ", accuracy)
	round_timer.stop()
	round_timer.visible = false
	
func _on_gdllama_finished(text: String) -> void:
	if recipe_text_displayed:
		return
	var recipe_ui_instance := recipe_ui_scene.instantiate() as Control
	add_child(recipe_ui_instance)
	recipe_text_displayed = true
	
	var ninepatch: NinePatchRect = recipe_ui_instance.get_node("NinePatchRect")
	var typable_text := recipe_ui_instance.get_node("NinePatchRect/MarginContainer/RecipeText/TypableText") as TypableText
	
	typable_text.typing_started.connect(_on_typing_started)
	typable_text.typing_finished.connect(_on_typing_finished)
	
	recipe_ui_instance.position = Vector2(200, 150)
	typable_text.text_ready.connect(
		func(tt: TypableText) -> void:
			ninepatch.custom_minimum_size = _calculate_ninepatch_min_size(tt)
	)
	Events.text_configured.emit(text, true)

func _calculate_ninepatch_min_size(tt: TypableText) -> Vector2:
	var padding := Vector2(16, 16) # customize
	var max_width := 0.0
	var total_height := 0.0

	for line in tt._text_root.get_children(): # HBoxContainer per line
		var line_width := 0.0
		var line_height := 0.0
		for ch_lbl in line.get_children():
			line_width += ch_lbl.get_size().x
			line_height = max(line_height, ch_lbl.get_size().y)
		max_width = max(max_width, line_width)
		total_height += line_height

	return Vector2(max_width, total_height) + padding
