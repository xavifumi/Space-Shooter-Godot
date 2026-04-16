extends Node

# Config
const MAX_WAVES = 20

# Estat
var current_wave: int = 0
var enemies_to_spawn: int = 0
var enemies_alive: int = 0
var difficulty: float = 1.0

# Control spawn
var spawn_interval: float = 1.0
var spawning: bool = false

signal wave_started(wave)
signal wave_finished(wave)
signal all_waves_completed()

func start_game():
	current_wave = 0
	difficulty = 1.0
	#start_next_wave()

func start_next_wave():
	current_wave += 1
	print("new wave: " + str(current_wave))
	
	if current_wave > MAX_WAVES:
		emit_signal("all_waves_completed")
		return
	
	# Escalar dificultat
	difficulty = 1.0 + (current_wave * 0.2)
	
	# Enemics per onada (exemple)
	enemies_to_spawn = 5 + current_wave * 3
	enemies_alive = 0
	
	spawning = true
	
	emit_signal("wave_started", current_wave)
	
	spawn_loop()

func spawn_loop():
	while enemies_to_spawn > 0:
		await get_tree().create_timer(spawn_interval).timeout
		spawn_enemy()
		print( "to spawn: "+ str(enemies_to_spawn) + " - alive: " + str(enemies_alive))
		enemies_to_spawn -= 1
		enemies_alive += 1
	
	spawning = false

func spawn_enemy():
	# Aquest mètode hauria de cridar el teu spawner real
	get_tree().call_group("generador", "spawn_enemy", difficulty)

func enemy_killed():
	enemies_alive -= 1
	print("Enemy Killed!")
	print( "to spawn: "+ str(enemies_to_spawn) + " - alive: " + str(enemies_alive))
	
	if enemies_alive <= 0 and enemies_to_spawn <= 0:
		wave_completed()

func wave_completed():
	print("wave Complete!")
	emit_signal("wave_finished", current_wave)
