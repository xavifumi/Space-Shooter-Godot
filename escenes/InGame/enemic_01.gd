extends Enemic

var jugador : Node2D
var carrega_atac : Timer
var pupila 
@export var max_speed := 200.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	jugador = get_node("../../Jugador/Nau")
	carrega_atac = get_node("AttackCooldown")
	health = 3

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#$Grafic.rotation = get_angle_to(jugador.position) - PI/2
	
	$Grafic/Sprite2D.flip_h = false if (rad_to_deg(get_angle_to(jugador.position ) + PI/2)) > 0 and (rad_to_deg(get_angle_to(jugador.position ) + PI/2)) < 180 else true
	
	if health < 1:
		$AttackCooldown.stop()
		if $Grafic/Crack.visible == false:
			$Grafic/Crack.start()
		$Grafic/Crack.visible = true
		#$Grafic/Sprite2D.visible = false
		

func atac()->void:
	if carrega_atac.is_stopped():
		carrega_atac.start()
	

func _on_attack_cooldown_timeout() -> void:
	pass

func _on_particle_off_timeout() -> void:
	$Sang.emitting = false
