class_name LLM
extends Node

var gdllama: GDLlama
var text_buffer := ""

signal generate_text_finished(text: String)

func _ready():
	gdllama = GDLlama.new()
	gdllama.model_path = "./models/Meta-Llama-3-8B-Instruct-Q5_K_M.gguf"
	gdllama.n_predict = 150
	gdllama.interactive = false
	gdllama.should_output_prompt = false
	gdllama.generate_text_updated.connect(_on_gdllama_updated)
	
func run_generate_text(prompt: String):
	gdllama.run_generate_text(prompt, "", "")

func _on_gdllama_updated(new_text: String):
	text_buffer += new_text
	print(text_buffer.strip_edges())
	if text_buffer.contains("<|eot_id|>"):
		gdllama.stop_generate_text()
		generate_text_finished.emit(text_buffer.strip_edges())
