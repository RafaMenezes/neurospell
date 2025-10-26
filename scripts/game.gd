extends Node

@onready var llm: LLM = $LLM
@onready var recipe_ui: Control = $RecipeUI
@onready var recipe_text: Label = $RecipeUI/RecipeText
@onready var customer: Customer

@export var round_timer: RoundTimer

var prompt_template = """<|begin_of_text|><|start_header_id|>system<|end_header_id|>
You are a concise recipe generator. Always respond in plain prose, never in numbered steps or bullet points. Write only the essential cooking process, no introductions, no conclusions, no list of ingredients. Keep it under 100 tokens.
<|eot_id|><|start_header_id|>user<|end_header_id|>
Write a short and direct cooking recipe for {recipe}. Use two brief natural-language paragraphs, without any bullet points or numbers.
<|eot_id|><|start_header_id|>assistant<|end_header_id|>
"""

func _ready() -> void:
	var typable_text: TypableText = recipe_ui.get_child(1).get_child(0) #temporario, meio merda
	typable_text.typing_started.connect(_on_typing_started)
	typable_text.typing_finished.connect(_on_typing_finished)
	llm.generate_text_finished.connect(_on_gdllama_finished)
	
	round_timer.visible = false
	round_timer.stop()
	round_timer.time_up.connect(_on_time_up)
	
	customer = Customer.new("Tomato soup", "Jun", 70)
	
	var prompt = prompt_template.format({"recipe": customer.recipe})
	llm.run_generate_text(prompt)
	print("generating text...")


func _on_typing_started(text: String) -> void:
	var word_count = text.split(" ", false).size()
	# compute seconds: characters -> reading speed in words-per-minute; keep your formula
	var max_time = word_count * 60.0 / customer.wpm
	round_timer.visible = true
	round_timer.start(max_time)
	
func _on_time_up() -> void:
	print("You didn't make it in time! The customer leaves very angry...")
	round_timer.stop()

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
	Events.text_configured.emit(text, true)
