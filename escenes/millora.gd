class_name Millora
extends Resource

@export var id: StringName
@export var nom: String
@export_multiline var descripcio: String
@export var icona: Texture2D
@export var stat: StringName          # &"max_speed", &"damage", &"reload_time", &"max_health", &"dash_cooldown"...
@export var suma := 0.0               # bonus plano por acumulación
@export var multiplica := 1.0         # bonus multiplicativo por acumulación
@export var maxim_stacks := 3
@export var pes := 1.0                # probabilidad relativa de salir
