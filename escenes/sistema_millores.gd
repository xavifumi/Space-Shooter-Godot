extends Node

signal canviat

const CARPETA := "res://millores/"
var totes: Array[Millora] = []
var triades := {}    # id -> nº de veces elegida

func _ready() -> void:
	for f in DirAccess.get_files_at(CARPETA):
		var nom := f.trim_suffix(".remap")    # en el juego exportado los .tres aparecen como .tres.remap
		if nom.ends_with(".tres"):
			totes.append(load(CARPETA + nom))

func reset() -> void:
	triades.clear()
	canviat.emit()

func stacks(m: Millora) -> int:
	return triades.get(m.id, 0)

func aplicar(m: Millora) -> void:
	triades[m.id] = stacks(m) + 1
	canviat.emit()

# Devuelve el valor base modificado por todas las mejoras de ese stat
func valor(stat: StringName, base: float) -> float:
	var suma := 0.0
	var mult := 1.0
	for m in totes:
		var n := stacks(m)
		if n > 0 and m.stat == stat:
			suma += m.suma * n
			mult *= pow(m.multiplica, n)
	return (base + suma) * mult

# Elige n mejoras distintas, ponderadas por 'pes', sin superar el máximo de acumulaciones
func opcions(n := 3) -> Array[Millora]:
	var pool: Array[Millora] = totes.filter(func(m): return stacks(m) < m.maxim_stacks)
	var res: Array[Millora] = []
	while res.size() < n and not pool.is_empty():
		var total := 0.0
		for m in pool:
			total += m.pes
		var r := randf() * total
		var tria: Millora = pool.back()
		for m in pool:
			r -= m.pes
			if r <= 0.0:
				tria = m
				break
		res.append(tria)
		pool.erase(tria)
	return res
