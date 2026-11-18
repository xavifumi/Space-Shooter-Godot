extends Control

@export var jugador : Node2D                 # arrastra aquí la Nau
@export var mostrar_mon_complet := false     # true = mapa de todo el mundo
@export var radi_visio := 800.0              # px del mundo que cubre medio recuadro (modo centrado)
@export var color_fons := Color(0, 0, 0, 0.5)
@export var color_vora := Color(1, 1, 1, 0.8)
@export var color_enemic := Color(1, 0.15, 0.15)
@export var color_jugador := Color(0.3, 0.9, 1.0)

var _angle := 0.0

func _process(_delta: float) -> void:
	if jugador and jugador.velocity.length() > 5.0:
		_angle = jugador.velocity.angle()
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), color_fons)
	if jugador == null:
		return

	var mon := Vector2(Game.WORLD_WIDTH, Game.WORLD_HEIGHT)
	var punt_jugador : Vector2

	if mostrar_mon_complet:
		var escala := size / mon
		for e in get_tree().get_nodes_in_group("enemics"):
			var p := Vector2(wrapf(e.global_position.x, 0.0, mon.x),
							 wrapf(e.global_position.y, 0.0, mon.y))
			draw_circle(p * escala, 2.0, color_enemic)
		punt_jugador = Vector2(wrapf(jugador.global_position.x, 0.0, mon.x),
							   wrapf(jugador.global_position.y, 0.0, mon.y)) * escala
	else:
		var centre := size * 0.5
		var escala := centre.x / radi_visio
		for e in get_tree().get_nodes_in_group("enemics"):
			var off : Vector2 = Game.wrapped_delta(jugador.global_position, e.global_position) * escala
			if absf(off.x) <= centre.x and absf(off.y) <= centre.y:
				draw_circle(centre + off, 2.0, color_enemic)
		punt_jugador = centre

	# Indicador del jugador: triángulo orientado según la velocidad
	var tri := PackedVector2Array([Vector2(4, 0), Vector2(-3, -2), Vector2(-3, 2)])
	for i in tri.size():
		tri[i] = punt_jugador + tri[i].rotated(_angle)
	draw_colored_polygon(tri, color_jugador)

	draw_rect(Rect2(Vector2.ZERO, size), color_vora, false, 2.0)
