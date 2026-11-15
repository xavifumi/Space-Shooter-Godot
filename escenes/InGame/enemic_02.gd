extends Enemic

var jugador : Node2D
var carrega_atac : Timer
var pupila 
var steering_factor := 6.0
var separacio_distancia := 40.0
var separacio_forca := 50.0

@export var distancia_retirada := 120.0
@export var temps_retirada := 2.0
@export var velocitat_carrega := 300.0
@export var distancia_arribada := 10.0
@export var max_speed := 100.0

enum EstatsAtac {
	RETIRADA,
	CARREGA,
	COOLDOWN
	}
	
var estatAtac = EstatsAtac.RETIRADA

# Retirada
var temps_actual := 0.0
var posicio_inicial := Vector2.ZERO
var posicio_retirada := Vector2.ZERO

# Càrrega
var target_pos := Vector2.ZERO
var direccio_carrega := Vector2.ZERO


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	jugador = get_node("../../Jugador/Nau")
	carrega_atac = get_node("AttackCooldown")
	health = 3
	estat = Estats.ATAC
	comencar_retirada()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	#$Grafic.rotation = get_angle_to(jugador.position) - PI/2
	#$Grafic/Sprite2D.flip_h = false if (rad_to_deg(get_angle_to(jugador.position ) + PI/2)) > 0 and (rad_to_deg(get_angle_to(jugador.position ) + PI/2)) < 180 else true
	
	if health < 1:
		$AttackCooldown.stop()
		if $Grafic/Crack.visible == false:
			$Grafic/Crack.start()
		$Grafic/Crack.visible = true
		#$Grafic/Sprite2D.visible = false
		

func atac(delta: float)->void:
	match estatAtac:
		EstatsAtac.RETIRADA:
			update_retirada(delta)

		EstatsAtac.CARREGA:
			update_carrega(delta)
		
		EstatsAtac.COOLDOWN:
			pass

func comencar_retirada():
	estatAtac = EstatsAtac.RETIRADA
	temps_actual = 0.0
	posicio_inicial = global_position
	var dir_fugida = (global_position - jugador.global_position).normalized()
	posicio_retirada = global_position + dir_fugida * distancia_retirada



func update_retirada(delta):
	temps_actual += delta
	var t = clamp(temps_actual / temps_retirada, 0.0, 1.0)
	# Ease out
	t = ease(t, -2.0)
	global_position = posicio_inicial.lerp(posicio_retirada, t)
	rotation += 8.0 * delta

	if temps_actual >= temps_retirada:
		target_pos = jugador.global_position
		direccio_carrega = (target_pos - global_position).normalized()
		estatAtac = EstatsAtac.CARREGA


func update_carrega(delta):
	global_position += direccio_carrega * velocitat_carrega * delta
	rotation -= 20.0 * delta


	# Quan arriba al destí
	if global_position.distance_to(target_pos) < distancia_arribada:
		estatAtac = EstatsAtac.COOLDOWN
		carrega_atac.start()


func _on_particle_off_timeout() -> void:
	$Sang.emitting = false


func _on_attack_cooldown_timeout() -> void:
	comencar_retirada()
