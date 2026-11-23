class_name Powerup
extends Resource

enum Tipus { CURA, ARMA }

@export var nom: String
@export var icona: Texture2D
@export var tipus := Tipus.CURA
@export var valor := 2                  # puntos de vida (si es CURA)
@export var arma: Arma                  # si es ARMA
@export var durada := 15.0              # segundos con el arma; 0 = permanente
@export var color := Color.WHITE
