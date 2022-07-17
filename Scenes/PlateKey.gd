extends Plate

export(NodePath) var crystal_path
export(Color) var active_color

onready var crystal : Crystal = get_node(crystal_path) setget set_crystal
onready var mesh : MeshInstance = $Mesh

func activate(entity : Entity, dungeon):
	if crystal == null or crystal.is_active:
		return

	var material = mesh.get_active_material(0)
	material.albedo_color = active_color

	crystal.add_action("cor_activate", [0.2])

func set_crystal(value : Crystal):
	crystal = value
	crystal_path = value.get_path()
