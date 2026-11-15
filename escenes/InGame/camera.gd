extends Camera2D

@export var decay := 0.8 # How quickly shaking stops [0, 1]
@export var max_offset := Vector2(10, 7) # Max displacement in pixels
@export var max_roll := 0.1 # Max rotation in radians
@export var noise : FastNoiseLite # Optional: for smoother noise

var trauma := 0.0
var trauma_pwr := 3 # Trauma exponent [2, 3]
var noise_y := 0.0

func _ready():
	randomize()
	if noise:
		noise.seed = randi()

func add_trauma(amount: float):
	trauma = min(trauma + amount, 1.0)

func _process(delta: float):
	if trauma > 0:
		trauma = max(trauma - decay * delta, 0)
		shake()
	else:
		# Optional: Smoothly return to zero if trauma is 0
		offset = offset.lerp(Vector2.ZERO, 1.0)
		rotation = lerp(rotation, 0.0, 1.0)

func shake():
	var amount = pow(trauma, trauma_pwr)
	
	# Using noise for smoother shake (if FastNoiseLite is assigned)
	if noise:
		noise_y += 1
		rotation = max_roll * amount * noise.get_noise_2d(noise.seed, noise_y)
		offset.x = max_offset.x * amount * noise.get_noise_2d(noise.seed * 2, noise_y)
		offset.y = max_offset.y * amount * noise.get_noise_2d(noise.seed * 3, noise_y)
	else:
		# Basic random shake
		rotation = max_roll * amount * randf_range(-1, 1)
		offset.x = max_offset.x * amount * randf_range(-1, 1)
		offset.y = max_offset.y * amount * randf_range(-1, 1)   
