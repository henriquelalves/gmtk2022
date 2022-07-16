extends Plate

export(NodePath) var crystal_path

onready var crystal : Crystal = get_node(crystal_path) setget set_crystal

func activate(entity : Entity, dungeon):
	if crystal == null or crystal.is_active:
		return

	crystal.add_action("cor_activate", [0.2])

func set_crystal(value : Crystal):
	crystal = value
	crystal_path = value.get_path()
