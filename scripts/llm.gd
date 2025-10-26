#class_name LLM
extends Node

var gdllama: GDLlama
var text_buffer := ""

signal generate_text_finished(text: String)

func _ready() -> void:
	gdllama = GDLlama.new()
	gdllama.model_path = "./models/Meta-Llama-3-8B-Instruct-Q5_K_M.gguf"
	gdllama.n_predict = 256
	gdllama.interactive = false
	gdllama.should_output_prompt = false
	gdllama.generate_text_updated.connect(_on_gdllama_updated.bind(250,50))
	
func run_generate_text(prompt: String) -> void:
	gdllama.run_generate_text(prompt, "", "")

func _on_gdllama_updated(new_text: String, max_len, line_break) -> void:
	text_buffer += new_text
	print(text_buffer.strip_edges())
	if text_buffer.contains("<|eot_id|>") or text_buffer.length() > max_len:
		gdllama.stop_generate_text()
		text_buffer = _post_process_text(text_buffer, max_len, line_break)
		generate_text_finished.emit(text_buffer.strip_edges())
		
func _post_process_text(text: String, max_len: int, line_break: int) -> String:
	var words := text.split(" ", false)
	var result := ""
	var line := ""
	var total_chars := 0

	for word in words:
		var next_len := line.length() + word.length() + 1  # +1 for space
		if total_chars + next_len > max_len:
			# truncate without cutting in the middle of a word
			if line.strip_edges() != "":
				result += line.strip_edges() + " \n"
			var truncated := result.substr(0, max_len)
			
			# find the last space before max_len to avoid cutting a word
			var last_space := truncated.rfind(" ")
			if last_space != -1:
				truncated = truncated.substr(0, last_space)
			
			truncated = truncated.strip_edges() + "..."
			return truncated

		if next_len > line_break:
			result += line.strip_edges() + " \n"
			total_chars += line.length()
			line = word + " "
		else:
			line += word + " "

	if line.strip_edges() != "":
		result += line.strip_edges()

	return result
