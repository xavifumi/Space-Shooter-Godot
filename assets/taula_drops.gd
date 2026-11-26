class_name TaulaDrops
extends Resource

@export_range(0.0, 1.0) var probabilitat := 0.25   # prob. de soltar algo
@export var powerups: Array[Powerup] = []
@export var pesos: Array[float] = []               # mismo orden que powerups

func triar() -> Powerup:
	if powerups.is_empty() or randf() > probabilitat:
		return null
	var total := 0.0
	for i in powerups.size():
		total += pesos[i] if i < pesos.size() else 1.0
	var r := randf() * total
	for i in powerups.size():
		r -= pesos[i] if i < pesos.size() else 1.0
		if r <= 0.0:
			return powerups[i]
	return powerups.back()
