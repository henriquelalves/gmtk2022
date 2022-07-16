extends Plate

export(int) var cardinal setget set_cardinal

onready var mesh : MeshInstance = $Mesh
onready var is_ready : bool = true

var is_active : bool

func _ready():
	set_cardinal(cardinal)

func activate(entity : Entity, dungeon):
	if is_active:
		return

	var direction : Vector2
	is_active = true

	match cardinal:
		0: direction = Vector2(0, +1)
		1: direction = Vector2(-1, 0)
		2: direction = Vector2(0, -1)
		3: direction = Vector2(+1, 0)

	dungeon.move_entity(entity, direction)
	is_active = false

func set_cardinal(value : int):
	if is_ready:
		mesh.transform.basis = Basis(Vector3.UP, value * PI / 2)
	cardinal = value
