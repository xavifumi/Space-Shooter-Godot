class_name Bala 
extends Node2D

@export var SPEED : int = 400
@export var COLOR : Color
@export var DAMAGE : int


func _physics_process(delta):
	position += Vector2.UP.rotated(rotation) * SPEED * delta


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

func change_color(color_to : Color):
	COLOR = color_to
	$Sprite2D.modulate = color_to
	$GPUParticles2D.modulate = color_to

func _on_body_entered(body: Node2D) -> void:
	var impacte = self.global_position
	queue_free()
	if body.has_method("take_damage"):
		body.angle_impacte = self.rotation
		body.posicio_impacte = impacte
		body.take_damage(DAMAGE)
	#print(body.health)
