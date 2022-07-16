extends Plate

export(int) var cardinal setget set_cardinal

onready var mesh : MeshInstance = $Mesh
onready var is_ready : bool = true

func _ready():
	set_cardinal(cardinal)

func activate(entity : Entity, dungeon):
	var direction : Vector2
	match cardinal:
		0: direction = Vector2(0, +1)
		1: direction = Vector2(-1, 0)
		2: direction = Vector2(0, -1)
		3: direction = Vector2(+1, 0)

	dungeon.move_entity(entity, direction)

func set_cardinal(value : int):
	if is_ready:
		mesh.transform.basis = Basis(Vector3.UP, value * PI / 2)
	cardinal = value
