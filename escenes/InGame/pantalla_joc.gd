extends Node2D

@onready var pantalla_millores = $PantallaMillores
var menu_final:StringName = "uid://bwahv3l1q2y1m"
var playlist = ["res://music/BattleMusic.mp3", 
"res://music/BossTheme.mp3", 
"res://music/Chase.mp3", 
"res://music/Cool.mp3", 
"res://music/Ruins.mp3"] 
var fx_explosio = load("res://fx/explosio.wav")
var current_song
var jugador
var tipus_control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SistemaMillores.reset()
	start_jukebox()
	jugador = get_node("Jugador/Nau")
	#jugador.position = DisplayServer.screen_get_size()/2
	jugador.position = Vector2(Game.WORLD_WIDTH/2, Game.WORLD_HEIGHT/2 )
	tipus_control = "A"
	await get_tree().create_timer(0.5).timeout
	jugador.animation_player.play('teleport_in')
	await jugador.animation_player.animation_finished
	$"/root/GestorOnades".start_game()
	$"/root/GestorOnades".wave_finished.connect(_on_wave_finished)
	#$"/root/GestorOnades".wave_started.connect(_on_wave_started)

func _on_wave_finished(wave):
	#get_tree().paused = true
	#show_upgrade_menu()
	await get_tree().create_timer(1.0).timeout    # pequeña pausa para saborear la victoria
	pantalla_millores.mostrar()
	await pantalla_millores.triada
	$"/root/GestorOnades".start_next_wave()

func _on_wave_started(wave):
	pass

func show_upgrade_menu():
	pass

func _on_upgrade_selected():
	get_tree().paused = false
	$"/root/GestorOnades".start_next_wave()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$CanvasLayer/Background.player_velocity = $"Jugador/Nau".velocity
	if jugador.health <= 0 and not jugador.dead:
		_morir()

func _morir() -> void:
	jugador.dead = true
	jugador.animation_player.play("death")
	%Musica.stream = fx_explosio
	%Musica.set_volume_db(10)
	%Musica.play()
	await get_tree().create_timer(3.0).timeout
	LoadingScreen.load_scene(menu_final)

func start_jukebox() -> void:
	current_song = load(playlist.pick_random())
	current_song.set_loop(true)
	%Musica.set_stream(current_song)
	%Musica.set_volume_db(-20)
	%Musica.play()
