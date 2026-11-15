extends CharacterBody2D

@export var dash_speed := 3000.0
@export var max_speed := 200.0
var actual_speed : float
#velocity := Vector2(0, 0)
var steering_factor := 3.0
var actual_damage : int
var angle_impacte
var posicio_impacte

@export var health : int
var health_bar
var dash_bar
var dash_reload
var body_count := 0
var sprite
var crosshair
@export var reload_time := 1
var reload
var reloading := false
var dashing := false
var damaging := false
var pantalla
var fx
var colisio
@onready var animation_player = $AnimationPlayer


func _ready() -> void: 
	sprite = get_node("CollisionPolygon2D/Sprite2D")
	reload = get_node("Reload")
	crosshair = get_node("UI/Crosshair")
	health_bar = get_node("UI/HealthBar")
	fx = get_node("FX")
	health = 10
	health_bar.max_value = health
	health_bar.value = health
	dash_bar = get_node("UI/DashBar")
	dash_bar.max_value = get_node("DashReload").wait_time*10
	dash_bar.value = dash_bar.max_value
	dash_reload = get_node("DashReload")
	
	#self.area_entered.connect(_on_area_entered)
	_set_health(health)
	actual_damage = 1
	#pantalla = get_tree().get_node("Pantalla").tipus_pantalla if get_tree().get_node("Pantalla") else "C"


#ANCHOR: _process_definition
func _process(delta: float) -> void:
#END: _process_definition

	movement(delta)
	
	var speed := velocity.length()
	var fx_motor = get_node("Fx_motor")
	var volume_db
	#print(speed)
	if speed > 5.0:  # llindar per evitar soroll quan quasi no es mou
		if not fx_motor.playing:
			fx_motor.play()

		volume_db = remap(speed, 0.0, 200.0, -30.0, -15.0)
		volume_db = clamp(volume_db, -30.0, -15.0)
		fx_motor.volume_db = volume_db
		
		var pitch := remap(speed, 0.0, 300.0, 0.8, 1.5)
		pitch = clamp(pitch, 0.8, 1.5)
		fx_motor.pitch_scale = lerp(fx_motor.pitch_scale, pitch, 0.1)
	else:
		if fx_motor.playing:
			fx_motor.stop()
	$RichTextLabel.text = str(dash_reload.get_time_left())
	if velocity.length() > 0.0:
		#get_node("Fx_motor").set_volume_db(volume_db)
		get_node("CollisionPolygon2D").rotation = velocity.angle()
		get_node("CollisionPolygon2D/SpriteReactor").scale.y = wrapf(velocity.length()/50, 0, 0.7 )
		get_node("CollisionPolygon2D/SpriteReactor").scale.x = wrapf(velocity.length()/50, 0, 0.5 )
		#get_node("UI/RichTextLabel").text = str(steering * delta)

	crosshair.rotation = get_local_mouse_position().angle() + PI/2
	crosshair.get_node("Crosshair2").rotation = -crosshair.rotation
	
	#if dashing:
	if dash_reload.is_stopped():
		dash_bar.get_theme_stylebox("fill").set_bg_color(Color(0.10,0.64,0.92,1))

	else:
		dash_bar.get_theme_stylebox("fill").set_bg_color(Color(0.10,0.64,0.92,0.3))
	dash_bar.value = dash_bar.max_value - dash_reload.get_time_left()*10
	colisio = move_and_collide(velocity*delta)
	if colisio:
		var colisionador = colisio.get_collider()
		if colisionador is Enemic:
			take_damage(1)

func movement(delta: float) -> void:
	if pantalla == "A" or "C":
		var direction := Vector2(0, 0)
		direction.x = Input.get_axis("ui_left", "ui_right")
		direction.y = Input.get_axis("ui_up", "ui_down")

		if direction.length() > 1.0:
			direction = direction.normalized()

		actual_speed = dash_speed if dashing  else max_speed

		var desired_velocity := actual_speed * direction
		var steering := desired_velocity - velocity
		velocity += steering * steering_factor * delta
		position += velocity * delta
		
		var viewport_size := get_viewport_rect().size
		#position.x = wrapf(position.x, 0 - sprite.texture.get_width()/3, viewport_size.x + sprite.texture.get_width()/3)
		#position.y = wrapf(position.y, 0 - sprite.texture.get_height()/3, viewport_size.y + sprite.texture.get_height()/3)
		position.x = wrapf(position.x, 0.0, Game.WORLD_WIDTH)
		position.y = wrapf(position.y, 0.0, Game.WORLD_HEIGHT)
		
	if pantalla == "B":
		pass

func _input(event:InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if not reloading:
				shoot()
	if event is InputEventKey:
		if event.keycode == KEY_SHIFT:
			print(dash_reload.is_stopped())
			dash()

func play_fx(stream_name : String, volume : int, from : float):
	if fx.stream.get_path() != stream_name:
		fx.stream = load(stream_name)
	if fx.get_volume_db() != volume:
		fx.set_volume_db(volume)
	fx.play(from)

func shake(amount: float) -> void:
	var camera = get_viewport().get_camera_2d()
	camera.add_trauma(5.0)

func dash():
	if dash_reload.is_stopped() :
		dashing = true
		get_node("Dash").start()
		play_fx("res://fx/teleport.wav", -12, 0.8)

func shoot():
	const BULLET = preload("res://escenes/InGame/bala.tscn")
	var new_bullet = BULLET.instantiate()
	new_bullet.DAMAGE = actual_damage
	new_bullet.position = self.position
	new_bullet.rotation = crosshair.rotation
	new_bullet.change_color(Color(1.0, 1.0, 1.0, 1.0))
	new_bullet.set_collision_mask_value(2, true)
	add_sibling(new_bullet)
	play_fx("res://fx/laser1.wav", -12, 0.0)
	reloading = true
	reload.start()

func take_damage(amount : int) -> void:
	if $Damage_time.is_stopped():
		health -= amount
		play_fx("res://fx/cop.wav", -15, 0.0)
		$AnimationPlayer.play("Damage")
		damaging = true
		$Damage_time.start()
		shake(0.001)
		if health_bar :
			health_bar.value = health
			if health_bar.value <= health_bar.max_value * 0.6  and health_bar.value > health_bar.max_value * 0.3:
				pass
	

func _on_hitbox_damage_taken(amount):
	take_damage(amount)

func _set_health(new_value : int):
	health = new_value
	if health_bar :
		health_bar.value = health


func _on_area_entered(area_that_entered: Area2D) -> void:
	pass
#	if area_that_entered.is_in_group("gem"):
#		set_gem_count(gem_count + 1)
#	elif area_that_entered.is_in_group("healing_item"):
#		set_health(health + 10)

func _on_reload_timeout() -> void:
	reloading = false

func _on_dash_timeout() -> void:
	dash_reload.start()
	dashing = false

func _on_dash_reload_timeout() -> void:
	pass # Replace with function body.

func _on_damage_time_timeout() -> void:
	$AnimationPlayer.play("idle")
	damaging = false
