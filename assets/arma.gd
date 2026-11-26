class_name Arma
extends Resource

@export var nom: String
@export var bales := 1                  # nº de proyectiles por disparo
@export var dispersio := 0.0            # abanico total en radianes (0.4 ≈ 23°)
@export var mult_dany := 1.0
@export var temps_recarrega := 1.0
@export var color := Color.WHITE
@export var so: AudioStream
