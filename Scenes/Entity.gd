extends Spatial

class_name Entity

export(bool) var actionable

var actions_queue : Array = []

func _ready():
	if actionable: add_to_group("actionables")

func play_actions():
	while actions_queue.size() > 0:
		var action = actions_queue[0] # action => [ "cor_name", X ]
		yield(call(action[0], action[1]), "completed")
		actions_queue.pop_front()

func cor_move_entity(args : Array): # args = [Vector3]
	var new_pos = args[0]

	var finished = false

	while not finished:
		var cur_pos = translation
		var delta = get_process_delta_time()
		translation = lerp(cur_pos, new_pos, delta * 14)

		if abs((cur_pos - new_pos).length()) <= 10e-3:
			translation = new_pos
			finished = true

		yield(get_tree(),"idle_frame")
