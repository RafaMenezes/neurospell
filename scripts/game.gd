extends Node

@onready var llm: Node = $LLM
@onready var recipe_ui: Control = $RecipeUI
@onready var recipe_text: Label = $RecipeUI/RecipeText
@onready var customer: Customer

var prompt_template = """<|begin_of_text|><|start_header_id|>system<|end_header_id|>
You are a concise recipe generator. Always respond in plain prose, never in numbered steps or bullet points. Write only the essential cooking process, no introductions, no conclusions, no list of ingredients. Keep it under 100 tokens.
<|eot_id|><|start_header_id|>user<|end_header_id|>
Write a short and direct cooking recipe for {recipe}. Use two brief natural-language paragraphs, without any bullet points or numbers.
<|eot_id|><|start_header_id|>assistant<|end_header_id|>
"""

func _ready() -> void:
	customer = Customer.new("Cheesecake", "Jun")
	var prompt = prompt_template.format({"recipe": customer.recipe})
	llm.run_generate_text(prompt)
	print("generating text...")
