extends Control

var joc: StringName = "uid://nojofhtnwike"
var puntuacio
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AudioStreamPlayer.play(10.0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _input(event:InputEvent) -> void:

	if event is InputEventKey:
		if event.keycode == KEY_SPACE:
			#get_tree().change_scene_to_file("res://escenes/InGame/pantallaJoc.tscn")
			#SceneLoader.load_scene(joc)
			LoadingScreen.load_scene(joc)
