extends Node

@onready var llm: Node = $LLM
@onready var recipe_ui: Control = $RecipeUI
@onready var recipe_text: Label = $RecipeUI/RecipeText
@onready var customer: Customer

var prompt_template := """You are a recipe in a cookbook. 
Output ONLY STANDARD COOKING RECIPE in text format, step-by-step concisely.
Add a stop token `</s>` when finishes all the recipe instructions.

Base yourself on the following example describing the Yakiniku recipe.

Slice beef (ribeye or short ribs) into thin 1/4 inch pieces against the grain.
Prepare marinade: Mix 3 tbsp soy sauce, 2 tbsp mirin, 1 tbsp sesame oil, 1 tsp sugar, and minced garlic.
Marinate beef slices for 30 minutes at room temperature.
Heat grill or griddle pan to high heat until smoking.
Brush grill with oil to prevent sticking.
Grill meat slices for 30-60 seconds per side until caramelized.
Remove from heat immediately to avoid overcooking.
Serve with dipping sauce: combine soy sauce, lemon juice, and sesame seeds.
Accompany with lettuce leaves, sliced garlic, and steamed rice.
Wrap grilled meat in lettuce with rice and garlic if desired.

{recipe}
"""

func _ready() -> void:
	customer = Customer.new("Cheesecake", "Jun")
	var prompt = prompt_template.format({"recipe": customer.recipe})
	llm.run_generate_text(prompt)
	print("generating text...")
