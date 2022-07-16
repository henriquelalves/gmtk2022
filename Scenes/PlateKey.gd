extends Plate

export(NodePath) var door_path

onready var door : Door = get_node(door_path) setget set_door

func activate():
	if door == null or door.is_open:
		return

	door.add_action("cor_open", [0.2])

func set_door(value : Door):
	door = value
	door_path = value.get_path()
