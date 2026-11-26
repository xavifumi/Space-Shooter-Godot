extends CanvasLayer

signal triada(m: Millora)

@onready var cartes: Array = $Centre/HBox.get_children()
var _ops: Array[Millora] = []

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for i in cartes.size():
		cartes[i].pressed.connect(_triar.bind(i))
	hide()

func mostrar() -> void:
	_ops = SistemaMillores.opcions(cartes.size())
	for i in cartes.size():
		var c: Button = cartes[i]
		c.visible = i < _ops.size()
		if c.visible:
			var m := _ops[i]
			var n := SistemaMillores.stacks(m)
			c.text = "%s\n\n%s\n(%d/%d)" % [m.nom, m.descripcio, n + 1, m.maxim_stacks]
			c.icon = m.icona
			c.expand_icon = true
	show()
	get_tree().paused = true
	cartes[0].grab_focus()    # permite elegir también con teclado/mando

func _triar(i: int) -> void:
	var m := _ops[i]
	SistemaMillores.aplicar(m)
	get_tree().paused = false
	hide()
	triada.emit(m)
