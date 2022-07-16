extends Spatial

class_name Plate

export(Array, String) var valid_symbols

func step(symbol : String):
	if valid_symbols.empty() or valid_symbols.has(symbol):
		activate()

func activate():
	pass
