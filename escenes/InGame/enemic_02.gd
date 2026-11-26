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

var dir_retirada := Vector2.ZERO
var t_anterior := 0.0
var carrega_restant := 0.0

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
		dropejar()
		if $Grafic/Crack.visible == false:
			$Grafic/Crack.start($Grafic/Sprite2D.flip_h)
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
	t_anterior = 0.0
	# del jugador hacia mí, con wrap
	dir_retirada = -Game.wrapped_delta(global_position, jugador.global_position).normalized()

func update_retirada(delta):
	temps_actual += delta
	var t = ease(clamp(temps_actual / temps_retirada, 0.0, 1.0), -2.0)
	global_position += dir_retirada * distancia_retirada * (t - t_anterior)
	t_anterior = t
	rotation += 8.0 * delta

	if temps_actual >= temps_retirada:
		var v = Game.wrapped_delta(global_position, jugador.global_position)
		direccio_carrega = v.normalized()
		carrega_restant = v.length()
		estatAtac = EstatsAtac.CARREGA

func update_carrega(delta):
	var pas = velocitat_carrega * delta
	global_position += direccio_carrega * pas
	carrega_restant -= pas
	rotation -= 20.0 * delta

	if carrega_restant <= distancia_arribada:
		estatAtac = EstatsAtac.COOLDOWN
		carrega_atac.start()


func _on_particle_off_timeout() -> void:
	$Sang.emitting = false


func _on_attack_cooldown_timeout() -> void:
	comencar_retirada()
