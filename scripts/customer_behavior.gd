extends Node2D

@onready var customer_sprite: Sprite2D = $"."
@onready var round_timer: RoundTimer = $"../RoundTimer"

@export_group("Movement Settings")
@export var destination_position: Vector2 = Vector2(500, 600)
@export var slide_duration: float = 2.0
@export var spawn_offset: float = 100.0

var tween: Tween
var is_moving: bool = false
var spawn_pos: Vector2

func _ready() -> void:
	round_timer.time_up.connect(_on_time_up)
	
	# Set initial spawn position outside screen
	_set_spawn_position()
	# Start sliding to destination
	slide_to_position(destination_position)

func _on_time_up():
	customer_sprite.flip_h = true
	slide_to_position(spawn_pos)

func _set_spawn_position() -> void:
	var viewport_rect = get_viewport_rect()
	spawn_pos = Vector2(viewport_rect.size.x + spawn_offset, destination_position.y)
	position = spawn_pos

func slide_to_position(target_pos: Vector2, duration: float = -1) -> void:
	if duration <= 0:
		duration = slide_duration
	
	# Kill existing tween if any
	if tween:
		tween.kill()
	
	is_moving = true
	
	# Create new tween for linear movement
	tween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	# Animate position
	tween.tween_property(self, "position", target_pos, duration)
	
	# Connect to finished signal
	tween.finished.connect(_on_slide_complete)

func _on_slide_complete() -> void:
	is_moving = false
	# You can emit a signal or trigger other behavior here
	print("Customer arrived at destination!")

# Optional: Manual spawn and slide (call this to respawn)
func spawn_and_slide(new_destination: Vector2 = Vector2.ZERO) -> void:
	if new_destination != Vector2.ZERO:
		destination_position = new_destination
	
	_set_spawn_position()
	slide_to_position(destination_position)

# Optional: Stop movement
func stop_movement() -> void:
	if tween:
		tween.kill()
	is_moving = false

# Optional: Get current movement progress (0.0 to 1.0)
func get_movement_progress() -> float:
	if not is_moving or not tween:
		return 1.0
	return tween.get_total_elapsed_time() / slide_duration
