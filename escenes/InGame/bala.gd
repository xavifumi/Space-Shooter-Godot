class_name Bala 
extends Node2D

@export var SPEED : int
@export var COLOR : Color
@export var DAMAGE : int


func _physics_process(delta):
	SPEED = 400
	position += Vector2.UP.rotated(rotation) * SPEED * delta


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

func change_color(color_to : Color):
	get_node("Sprite2D").modulate = color_to
	get_node("GPUParticles2D").process_material.color = color_to


func _on_body_entered(body: Node2D) -> void:
	var impacte = self.global_position
	queue_free()
	if body.has_method("take_damage"):
		body.angle_impacte = self.rotation
		body.posicio_impacte = impacte
		body.take_damage(DAMAGE)
	#print(body.health)
