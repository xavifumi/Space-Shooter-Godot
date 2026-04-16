extends Node2D

var playlist = ["res://music/BattleMusic.mp3", 
"res://music/BossTheme.mp3", 
"res://music/Chase.mp3", 
"res://music/Cool.mp3", 
"res://music/Ruins.mp3"] 
var current_song
var jugador
var tipus_control
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_jukebox()
	jugador = get_node("Jugador/Nau")
	jugador.position = DisplayServer.screen_get_size()/2
	tipus_control = "A"
	$"/root/GestorOnades".start_game()
	$"/root/GestorOnades".wave_finished.connect(_on_wave_finished)
	#$"/root/GestorOnades".wave_started.connect(_on_wave_started)

func _on_wave_finished(wave):
	#get_tree().paused = true
	#show_upgrade_menu()
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
	if jugador.health <= 0:
			get_tree().change_scene_to_file("res://escenes/game_over.tscn")
			


func start_jukebox() -> void:
	current_song = load(playlist.pick_random())
	current_song.set_loop(true)
	%Musica.set_stream(current_song)
	%Musica.set_volume_db(-20)
	%Musica.play()
