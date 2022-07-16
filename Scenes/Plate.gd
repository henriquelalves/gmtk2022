extends Spatial

class_name Plate

export(Array, String) var valid_symbols

func step(entity : Entity, dungeon):
	if valid_symbols == null or valid_symbols.empty() or valid_symbols.has(entity.get_top()):
		activate(entity, dungeon)

func activate(entity : Entity, dungeon):
	pass
