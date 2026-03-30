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
	pass # Replace with function body.


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
