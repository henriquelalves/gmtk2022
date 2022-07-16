extends Entity

class_name Door

export(bool) var is_open = false

onready var mesh = $Mesh

func _ready():
	._ready()
	add_to_group("doors")

func cor_open(args : Array):
	var duration = args[0]
	var time = 0

	while true:
		time = min(time + get_process_delta_time(), duration)
		var weight = time / duration

		mesh.translation = Vector3(0, 0.5 - weight * 0.95, 0)

		if time >= duration:
			break

		yield(get_tree(), "idle_frame")

	is_open = true
