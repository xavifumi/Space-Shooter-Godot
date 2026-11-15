extends Node

const WORLD_WIDTH := 1280.0 * 3.0
const WORLD_HEIGHT := 720.0 * 3.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func wrapped_delta(from_pos: Vector2, to_pos: Vector2) -> Vector2:
	var delta = to_pos - from_pos

	if abs(delta.x) > WORLD_WIDTH * 0.5:
		delta.x -= sign(delta.x) * WORLD_WIDTH

	if abs(delta.y) > WORLD_HEIGHT * 0.5:
		delta.y -= sign(delta.y) * WORLD_HEIGHT

	return delta


func wrap_position(pos: Vector2) -> Vector2:
	pos.x = wrapf(pos.x, 0.0, WORLD_WIDTH)
	pos.y = wrapf(pos.y, 0.0, WORLD_HEIGHT)
	return pos
