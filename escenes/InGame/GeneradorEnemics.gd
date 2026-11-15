extends Node2D

@export var enemy_scene: Array[PackedScene] =[]

func spawn_enemy(difficulty):
	var enemy_tipus = enemy_scene.pick_random()
	var enemy = enemy_tipus.instantiate()
	
	# Posició random (exemple)
	#var screenSize = get_viewport().get_visible_rect().size
	#enemy.position = Vector2(randf_range(20, screenSize.x -20), randf_range(20, screenSize.y -20))
	enemy.position = Vector2(randf_range(20, Game.WORLD_WIDTH -20), randf_range(20, Game.WORLD_HEIGHT -20))
	
		
	# Escalar dificultat
	enemy.speed *= difficulty
	enemy.health *= difficulty
	
	add_child(enemy)
