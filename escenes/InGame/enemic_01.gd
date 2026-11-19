extends Enemic

var jugador : Node2D
var carrega_atac : Timer
var pupila 
var steering_factor := 6.0
var separacio_distancia := 40.0
var separacio_forca := 50.0
@export var max_speed := 100.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	jugador = get_node("../../Jugador/Nau")
	carrega_atac = get_node("AttackCooldown")
	health = 3

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	#$Grafic.rotation = get_angle_to(jugador.position) - PI/2
	
	$Grafic/Sprite2D.flip_h = false if (rad_to_deg(get_angle_to(jugador.position ) + PI/2)) > 0 and (rad_to_deg(get_angle_to(jugador.position ) + PI/2)) < 180 else true
	
	if health < 1:
		$AttackCooldown.stop()
		if $Grafic/Crack.visible == false:
			$Grafic/Crack.start()
		$Grafic/Crack.visible = true
		#$Grafic/Sprite2D.visible = false
		

func atac(delta: float)->void:
	#if carrega_atac.is_stopped():
		#carrega_atac.start()

	# --- MOVIMENT CAP AL JUGADOR ---
	#var direction := jugador.position - position
	var direction := Game.wrapped_delta(position, jugador.position)

	if direction.length() > 1.0:
		direction = direction.normalized()

	var desired_velocity := direction * max_speed


	# --- SEPARACIÓ ENTRE ENEMICS ---
	var separacio := Vector2.ZERO

	for enemic in get_tree().get_nodes_in_group("enemics"):

		# Ignora a si mateix
		if enemic == self :
			continue

		#var distancia = position.distance_to(enemic.position)
		var delta_enemic = Game.wrapped_delta(position, enemic.position)
		var distancia = delta_enemic.length()

		# Si està massa a prop
		if distancia < separacio_distancia and distancia > 0:

			# Direcció oposada
			#var fugir = (position - enemic.position).normalized()
			var fugir = -delta_enemic.normalized()
			
			# Com més a prop, més força
			separacio += fugir * (separacio_distancia - distancia)


	# Aplicar força de separació
	desired_velocity += separacio * separacio_forca


	# --- STEERING ---
	var steering := desired_velocity - velocity
	velocity += steering * steering_factor * delta

	#position += velocity * delta
	move_and_slide()
	#position = Game.wrap_position(position)

func _on_attack_cooldown_timeout() -> void:
	pass

func _on_particle_off_timeout() -> void:
	$Sang.emitting = false
