extends CharacterBody2D
class_name Enemic

@export var health : int #: set = _set_health
@export var speed = 0
@export var Hitbox : Area2D
@export var health_bar : ProgressBar
var angle_impacte
var posicio_impacte : Vector2
var death_deccel : float
enum Estats {APARICIO,ATAC,MORT}
@export var estat : Estats = Estats.APARICIO


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	angle_impacte = 0
	if health_bar :
		health_bar.max_value = health
		health_bar.value = health
	#Hitbox.damage_taken.connect(_on_hitbox_damage_taken)
	death_deccel = 8.0
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _physics_process(delta: float) -> void:
	match estat:
		Estats.APARICIO:
			pass
		Estats.ATAC:
			atac(delta)
		Estats.MORT:
			death()

func take_damage(amount : int) -> void:
	health -= amount
	if health < 1 :
		$Particle_off.set_wait_time(1.0)
		$AnimationPlayer.play("Death")
		$Audio.stream = load("res://fx/cop.wav")
		$Audio.set_volume_db(-16)
		$Audio.set_pitch_scale(randf_range(0.8,1.2))
		$Audio.play()
		$Audio.stream = load("res://fx/monstre1.wav")
		$Audio.set_volume_db(-12)
		if estat != Estats.MORT:
			$"/root/GestorOnades".enemy_killed()
		estat = Estats.MORT
	else :
		$Particle_off.set_wait_time(0.3)
		$AnimationPlayer.play("Damage")
		$Audio.stream = load("res://fx/cop.wav")
		$Audio.set_volume_db(-16)
	$Audio.set_pitch_scale(randf_range(0.8,1.2))
	$Audio.play()
	$Sang.rotation = angle_impacte
	#var dist = 20.0 # pixels (mig sprite)
	#var dir = Vector2.RIGHT.rotated(angle_impacte) # direcció del projectil
	#var offset2d = dir * dist
	#$Sang.process_material.emission_shape_offset = Vector3(offset2d.x, offset2d.y, 0.0)	#$Sang.emiter.position = $Sang.position + Vector2.UP.rotated(angle_impacte)
	$Sang.global_position = posicio_impacte
	$Sang.emitting = true
	$Particle_off.start()

func atac(delta: float) -> void:
	pass
	
func shake(amount: float) -> void:
	var camera = get_viewport().get_camera_2d()
	camera.add_trauma(5.0)

func _on_hitbox_damage_taken(amount):
	take_damage(amount)

func _set_health(new_value : int):
	health = new_value
	if health_bar :
		health_bar.value = health

func death() -> void:
	pass

func death_displace() -> void:
	position += Vector2.UP.rotated(angle_impacte) * death_deccel
	if death_deccel > 0:
		death_deccel -= 0.6
	var anim_death =  (3 - death_deccel/2)
	self.scale =  Vector2(1,1) * anim_death if anim_death > 0 else Vector2(1,1)
	#self.global_scale.y += 4
	#self.global_scale.x -= 2

func retroces(angle : float) -> void:
	pass

func play_fx(stream_name : String, volume : int, from : float):
	if $Audio.stream == null or $Audio.stream.get_path() != stream_name:
		$Audio.stream = load(stream_name)
	if $Audio.get_volume_db() != volume:
		$Audio.set_volume_db(volume)
	$Audio.play(from)
