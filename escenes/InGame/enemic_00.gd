extends Enemic

var jugador : Node2D
var carrega_atac : Timer
var pupila 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	jugador = get_node("../Jugador/Nau")
	carrega_atac = get_node("AttackCooldown")
	pupila = get_node("Grafic/Sprite2D/Pupila")
	health = 3

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	$Grafic.rotation = get_angle_to(jugador.position) - PI/2
	if estat == Estats.ATAC :
		var alfa_pupila = remap(carrega_atac.get_time_left(), 3.0, 0.0, 0, 1)
		pupila.modulate = Color(1,1,1,alfa_pupila)
	
	if health < 1:
		$AttackCooldown.stop()
		if $Grafic/Crack.visible == false:
			$Grafic/Crack.start()
		$Grafic/Crack.visible = true
		#$Grafic/Sprite2D.visible = false
		estat = Estats.MORT

func atac()->void:
	if carrega_atac.is_stopped():
		carrega_atac.start()
	

func shoot():
	const BULLET = preload("res://escenes/InGame/bala.tscn")
	var new_bullet = BULLET.instantiate()
	new_bullet.DAMAGE = 1
	new_bullet.position = pupila.global_position
	new_bullet.rotation = $Grafic.rotation -PI
	new_bullet.change_color(Color(0.853, 0.235, 0.0, 1.0))
	new_bullet.set_collision_mask_value(1, true)
	add_sibling(new_bullet)
	$Audio.stream = load("res://fx/laser2.wav")
	$Audio.set_volume_db(-16)
	$Audio.play()
	carrega_atac.start()

func _on_attack_cooldown_timeout() -> void:
	shoot()

func _on_particle_off_timeout() -> void:
	$Sang.emitting = false
