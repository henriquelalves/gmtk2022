extends Entity

class_name Crystal

export(bool) var is_active = false
export(Color) var active_color

onready var mesh : MeshInstance = $Mesh

func _ready():
	._ready()
	add_to_group("crystals")

func cor_activate(args : Array):
	var duration = args[0]
	var time = 0

	var material = mesh.get_active_material(0)
	var color = material.albedo_color

	while true:
		time = min(time + get_process_delta_time(), duration)
		var weight = time / duration

		material.albedo_color = color.linear_interpolate(active_color, weight)

		if time >= duration:
			break

		yield(get_tree(), "idle_frame")

	is_active = true
