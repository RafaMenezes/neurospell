extends Node

var gdllama: GDLlama
var text_buffer := ""
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
""".format({"recipe": "Cheesecake Recipe"})

func _ready():
	gdllama = GDLlama.new()
	gdllama.model_path = "./models/Meta-Llama-3-8B-Instruct-Q5_K_M.gguf"
	gdllama.n_predict = 350
	gdllama.interactive = false
	gdllama.should_output_prompt = false
	gdllama.generate_text_updated.connect(_on_gdllama_updated)
	gdllama.generate_text_finished.connect(_on_gdllama_finished)
	gdllama.run_generate_text(prompt_template, "", "")
	
func _on_gdllama_updated(new_text: String):
	text_buffer += new_text
	print(text_buffer.strip_edges())

	#if new_text.strip_edges() == "</s>":
		#print(text_buffer.strip_edges())
		#gdllama.stop_generate_text()

func _on_gdllama_finished():
	text_buffer = ""
	return text_buffer
