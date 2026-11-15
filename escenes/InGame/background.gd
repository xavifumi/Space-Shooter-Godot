extends ColorRect

@export var drift := Vector2(0, 60)   # movimiento base de las estrellas (px/s), p.ej. hacia abajo
var player_velocity := Vector2.ZERO   # actualízala desde tu nave
var scroll := Vector2.ZERO

func _process(delta: float) -> void:
	# Las estrellas se mueven en dirección contraria al jugador + el drift base.
	# El shader ya aplica un factor distinto por capa (parallax).
	scroll += (player_velocity - drift) * delta
	(material as ShaderMaterial).set_shader_parameter("scroll", scroll)
