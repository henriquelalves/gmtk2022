extends Spatial

class_name Entity

export(bool) var actionable

var actions_queue : Array = []

func _ready():
	if actionable:
		add_to_group("actionables")

func get_top() -> String:
	return ''

func roll(direction : Vector2):
	pass

func add_action(name : String, args : Array):
	actions_queue.append([name, args])

func play_actions():
	while not actions_queue.empty():
		var action = actions_queue[0]

		var name = action[0]
		var args = action[1]

		yield(call(name, args), "completed")
		actions_queue.pop_front()

func cor_move(args : Array): # args = [Vector3]
	var next_pos = args[0]

	while true:
		var delta = get_process_delta_time()
		translation = lerp(translation, next_pos, delta * 14)

		if abs((translation - next_pos).length()) <= 10e-3:
			translation = next_pos
			break

		yield(get_tree(), "idle_frame")

func cor_dies(args : Array):
	yield()

func cor_shake(args : Array):
	var duration = args[0]
	var time = 0

	var zero = translation
	var intensity = 0.02

	while true:
		time = min(time + get_process_delta_time(), duration)

		translation = zero + (2 * Vector3(randf(), randf(), randf()) - Vector3.ONE) * intensity

		if time >= duration:
			translation = zero
			break

		yield(get_tree(), "idle_frame")
