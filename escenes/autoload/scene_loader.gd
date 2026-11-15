extends CanvasLayer

var transition_in
var transition_out

func _ready() -> void:
	transition_in= 'mosaic'
	transition_out= 'mosaic'

func load_scene(target: String) -> void:
	$AnimationPlayer.play(transition_in)
	await $AnimationPlayer.animation_finished
	get_tree().change_scene_to_file(target)
	#$AnimationPlayer.play_backwards('transition')
	$AnimationPlayer.play(transition_out, -1, -2.0, true)

func set_transitions(transitionIn: String, transitionOut: String) -> void:
	transition_in= transitionIn
	transition_out= transitionOut
