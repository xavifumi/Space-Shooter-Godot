extends CharacterBody2D

@export var dash_speed := 3000.0
@export var max_speed := 200.0
@export var arma_base: Arma          # arrastra aquí res://armes/laser.tres en el Inspector
var actual_speed : float
var steering_factor := 3.0
var actual_damage : int
var angle_impacte
var posicio_impacte

var _vida_max_anterior := 10
@export var health : int
var health_bar
var dash_bar
var dash_reload
var body_count := 0
var sprite
var crosshair
var reload
var reloading := false
var dashing := false
var damaging := false
var dead := false
var pantalla
var fx
var colisio
@onready var animation_player = $AnimationPlayer
var arma: Arma
var _timer_arma: Timer
#@onready var Fake3D = $SpriteStack2D

const CAPA_JUGADOR := 1
const CAPA_ENEMICS := 2

@onready var pivot: Node3D = $SubViewport/Pivot
@onready var ear_l: Node3D = $SubViewport/Pivot/robot_mouse_head/EarL
@onready var ear_r: Node3D = $SubViewport/Pivot/robot_mouse_head/EarR
@export var ear_pitch_amount := 0.9    # rad de cabeceo a velocidad máxima
@export var ear_yaw_turn := 0.8        # rad de giro de las orejas al virar
@export var ear_splay := 0.35          # rad que se abren hacia fuera con la velocida
var heading := 0.0
var ear_base_l: Vector3
var ear_base_r: Vector3


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
	dash_bar.max_value = get_node("DashReload").wait_time * 10
	dash_bar.value = dash_bar.max_value
	dash_reload = get_node("DashReload")
	SistemaMillores.canviat.connect(_recalcular_vida)

	_set_health(health)
	actual_damage = 1

	# Arma inicial (si no la has asignado en el Inspector, intenta cargarla por ruta)
	if arma_base == null:
		arma_base = load("res://armes/laser.tres")
	arma = arma_base

	_timer_arma = Timer.new()
	_timer_arma.one_shot = true
	_timer_arma.timeout.connect(func(): arma = arma_base)
	add_child(_timer_arma)
	
	ear_base_l = ear_l.rotation
	ear_base_r = ear_r.rotation
	sprite.texture = $SubViewport.get_texture()   # no hace falta si ya la asignaste en el editor
	ear_l.rotation.y = 1.0

func _physics_process(delta: float) -> void:
	movement(delta)

	colisio = move_and_collide(velocity * delta)
	if colisio:
		var colisionador = colisio.get_collider()
		if colisionador is Enemic:
			take_damage(1)

	# Recolocar los objetos del mundo en su copia más cercana al jugador
	for n in get_tree().get_nodes_in_group("wrappable"):
		n.global_position = Game.nearest_copy(n.global_position, global_position)


func _process(_delta: float) -> void:
	var speed := velocity.length()
	var fx_motor = get_node("Fx_motor")
	var volume_db
	if speed > 5.0:
		if not fx_motor.playing:
			fx_motor.play()
		volume_db = clamp(remap(speed, 0.0, 200.0, -30.0, -15.0), -30.0, -15.0)
		fx_motor.volume_db = volume_db
		var pitch = clamp(remap(speed, 0.0, 300.0, 0.8, 1.5), 0.8, 1.5)
		fx_motor.pitch_scale = lerp(fx_motor.pitch_scale, pitch, 0.1)
	else:
		if fx_motor.playing:
			fx_motor.stop()

	$RichTextLabel.text = str(dash_reload.get_time_left())

	if velocity.length() > 0.0:
		get_node("CollisionPolygon2D").rotation = velocity.angle()
		#Fake3D.y_rotations = -rad_to_deg(velocity.angle()-PI/2)
		get_node("CollisionPolygon2D/SpriteReactor").scale.y = wrapf(velocity.length() / 50, 0, 0.7)
		get_node("CollisionPolygon2D/SpriteReactor").scale.x = wrapf(velocity.length() / 50, 0, 0.5)

	crosshair.rotation = get_local_mouse_position().angle() + PI / 2
	crosshair.get_node("Crosshair2").rotation = -crosshair.rotation

	if dash_reload.is_stopped():
		dash_bar.get_theme_stylebox("fill").set_bg_color(Color(0.10, 0.64, 0.92, 1))
	else:
		dash_bar.get_theme_stylebox("fill").set_bg_color(Color(0.10, 0.64, 0.92, 0.3))
	dash_bar.value = dash_bar.max_value - dash_reload.get_time_left() * 10
	_actualitzar_nau_3d(_delta)

func _actualitzar_nau_3d(delta: float) -> void:
	sprite.global_rotation = 0.0

	var speed := velocity.length()
	var diff := 0.0
	if speed > 5.0:
		var target := velocity.angle() + PI / 2.0
		diff = angle_difference(heading, target)
		heading = lerp_angle(heading, target, 12.0 * delta)
	pivot.rotation.y = -heading

	var speed_ratio := clampf(speed / max_speed, 0.0, 1.0)
	var bank := clampf(diff * 0.5, -0.5, 0.5) * speed_ratio
	pivot.rotation.z = lerpf(pivot.rotation.z, bank, 8.0 * delta)

	# fold = 1 en reposo (plegadas), 0 a máxima velocidad (pose base, "lanzando fuego")
	var fold := 1.0 - speed_ratio
	var turn := clampf(diff, -1.0, 1.0)

	var pitch := ear_base_l.x + fold * ear_pitch_amount
	var yaw_l := turn * ear_yaw_turn + fold * ear_splay
	var yaw_r := turn * ear_yaw_turn - fold * ear_splay

	var k := 14.0 * delta
	ear_l.rotation.x = lerpf(ear_l.rotation.x, pitch, k)
	ear_r.rotation.x = lerpf(ear_r.rotation.x, pitch, k)
	ear_l.rotation.y = lerpf(ear_l.rotation.y, ear_base_l.y + yaw_l, k)
	ear_r.rotation.y = lerpf(ear_r.rotation.y, ear_base_r.y + yaw_r, k)
	
	
func movement(delta: float) -> void:
	if not dead:
		var direction := Vector2(
			Input.get_axis("ui_left", "ui_right"),
			Input.get_axis("ui_up", "ui_down")
		)
		if direction.length() > 1.0:
			direction = direction.normalized()

		actual_speed = SistemaMillores.valor(&"max_speed", max_speed) if not dashing else dash_speed
		var desired_velocity := actual_speed * direction
		velocity += (desired_velocity - velocity) * steering_factor * delta


func _input(event: InputEvent) -> void:
	if dead:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if not reloading:
				shoot()
	if event is InputEventKey:
		if event.keycode == KEY_SHIFT:
			dash()


func aplicar_powerup(p: Powerup) -> void:
	match p.tipus:
		Powerup.Tipus.CURA:
			var max_vida := roundi(SistemaMillores.valor(&"max_health", 10))
			health = mini(health + p.valor, max_vida)
			health_bar.value = health
		Powerup.Tipus.ARMA:
			if p.arma == null:
				return
			arma = p.arma
			if p.durada > 0.0:
				_timer_arma.start(p.durada)
			else:
				arma_base = p.arma
				_timer_arma.stop()


func _set_ghost(actiu: bool) -> void:
	set_collision_mask_value(CAPA_ENEMICS, not actiu)
	set_collision_layer_value(CAPA_JUGADOR, not actiu)


func play_fx(stream_name : String, volume : int, from : float):
	if fx.stream == null or fx.stream.get_path() != stream_name:
		fx.stream = load(stream_name)
	if fx.get_volume_db() != volume:
		fx.set_volume_db(volume)
	fx.play(from)


func shake(amount: float) -> void:
	var camera = get_viewport().get_camera_2d()
	camera.add_trauma(5.0)


func dash():
	if dash_reload.is_stopped():
		dashing = true
		get_node("Dash").start()
		play_fx("res://fx/teleport.wav", -12, 0.8)


func shoot():
	if dead:
		return
	if arma == null:
		arma = arma_base
	if arma == null:
		push_error("El jugador no tiene arma asignada (arma_base)")
		return

	const BULLET = preload("res://escenes/InGame/bala.tscn")
	var n := arma.bales + roundi(SistemaMillores.valor(&"bales_extra", 0))
	for i in n:
		var offset := 0.0 if n == 1 else lerpf(-arma.dispersio * 0.5, arma.dispersio * 0.5, float(i) / (n - 1))
		var b = BULLET.instantiate()
		b.DAMAGE = maxi(1, roundi(SistemaMillores.valor(&"damage", actual_damage) * arma.mult_dany))
		b.position = position
		b.rotation = crosshair.rotation + offset
		b.change_color(arma.color)
		b.set_collision_mask_value(2, true)
		add_sibling(b)
	if arma.so:
		fx.stream = arma.so
		fx.play()
	reloading = true
	reload.start(SistemaMillores.valor(&"reload_time", arma.temps_recarrega))


func take_damage(amount : int) -> void:
	if $Damage_time.is_stopped():
		health -= amount
		play_fx("res://fx/cop.wav", -15, 0.0)
		$AnimationPlayer.play("Damage")
		damaging = true
		_set_ghost(true)
		$Damage_time.start()
		shake(0.001)
		if health_bar:
			health_bar.value = health


func _on_hitbox_damage_taken(amount):
	take_damage(amount)


func _set_health(new_value : int):
	health = new_value
	if health_bar:
		health_bar.value = health


func _recalcular_vida() -> void:
	var nova := roundi(SistemaMillores.valor(&"max_health", 10))
	health += nova - _vida_max_anterior    # al subir el máximo, también te curas esa cantidad
	_vida_max_anterior = nova
	health_bar.max_value = nova
	health_bar.value = health


func _on_area_entered(_area_that_entered: Area2D) -> void:
	pass


func _on_reload_timeout() -> void:
	reloading = false


func _on_dash_timeout() -> void:
	dash_reload.start(SistemaMillores.valor(&"dash_cooldown", 3.0))    # tu wait_time base
	dashing = false


func _on_dash_reload_timeout() -> void:
	pass


func _on_damage_time_timeout() -> void:
	$AnimationPlayer.play("idle")
	damaging = false
	_set_ghost(false)
