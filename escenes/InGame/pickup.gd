class_name Pickup
extends Area2D

@export var vida_util := 12.0
@export var radi_iman := 150.0
@export var vel_iman := 350.0

var powerup: Powerup
var jugador: Node2D

func configurar(p: Powerup) -> void:
	powerup = p
	$Sprite2D.texture = p.icona
	$Sprite2D.modulate = p.color

func _ready() -> void:
	add_to_group("wrappable")                       # el jugador lo recoloca como a los enemigos
	jugador = get_node("../../Jugador/Nau")         # mismo path que usan tus enemigos
	body_entered.connect(_on_body_entered)

	# Parpadeo final y desaparición
	var tw := create_tween()
	tw.tween_interval(vida_util - 3.0)
	tw.tween_property($Sprite2D, "modulate:a", 0.2, 0.25).set_trans(Tween.TRANS_SINE)
	tw.set_loops(6)  # parpadea ~3 s; ajusta a gusto
	get_tree().create_timer(vida_util).timeout.connect(queue_free)

func _process(delta: float) -> void:
	# Imán hacia el jugador, teniendo en cuenta el mundo en bucle
	var v := Game.wrapped_delta(global_position, jugador.global_position)
	if v.length() < radi_iman:
		var fuerza := remap(v.length(), radi_iman, 0.0, 0.2, 1.0)
		global_position += v.normalized() * vel_iman * fuerza * delta

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("aplicar_powerup"):
		body.aplicar_powerup(powerup)
		queue_free()
