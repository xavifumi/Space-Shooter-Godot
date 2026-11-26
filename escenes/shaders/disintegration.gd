extends GPUParticles2D
var _tween: Tween

func _ready() -> void:
	one_shot = true
	process_material = process_material.duplicate()


func start(flip: bool = false) -> void:
	process_material.set_shader_parameter("flip_h", flip)
	restart()
	emitting = true
	set_progress(0.0)

	var frac: float = process_material.get_shader_parameter("particle_lifetime_fraction")
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_method(set_progress, 0.0, 1.0, lifetime * (1.0 - frac))
	_tween.tween_interval(lifetime * frac)    # deja que mueran las últimas partículas
	_tween.tween_callback(finished_effect)

func finished_effect() -> void:
	get_parent().get_parent().queue_free()    # o emite una señal y que el enemigo se elimine a sí mismo

func set_progress(value: float):
	process_material.set_shader_parameter("progress", value)
