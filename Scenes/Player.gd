extends Entity

class_name Player

# Cube Layout:
# 0
# 1
# 5 3
#   4
# 	2

# Cardinals
#  0
# 1 3
#  2

const chart_side = [
	[4, 2, 1, 3],
	[0, 2, 5, 3],
	[4, 5, 1, 0],
	[1, 5, 4, 0],
	[3, 5, 2, 0],
	[1, 2, 4, 3],
]

const chart_spin = [
	[3, 0, 0, 2],
	[0, 1, 0, 1],
	[0, 2, 3, 0],
	[3, 0, 0, 2],
	[0, 1, 0, 1],
	[0, 2, 3, 0],
]

onready var mesh = $Mesh

var symbols = ['1', '3', '5', '2', '4', '6']

var side = 0
var spin = 0

func get_top() -> String:
	return symbols[side]

func set_bottom(symbol : String):
	symbols[5 - side] = symbol

func roll(direction : Vector2):
	var cardinal = (get_cardinal(-direction) - spin) % 4

	spin = chart_spin[side][cardinal] + spin
	side = chart_side[side][cardinal]

func get_cardinal(direction: Vector2) -> int:
	if direction.y > 0:
		return 0

	if direction.x < 0:
		return 1

	if direction.y < 0:
		return 2

	if direction.x > 0:
		return 3

	return -1

func get_upper_face() -> String:
	return get_top()

func cor_move(args : Array): # args = [Vector3, float]
	var pos_a = translation
	var pos_b = args[0]

	var dir = pos_b - pos_a

	var basis_a = mesh.transform.basis
	var basis_b = basis_a.rotated(Vector3(dir.z, 0, -dir.x), PI / 2)

	var duration = args[1]
	var time = 0

	while true:
		time = min(time + get_process_delta_time(), duration)
		var weight = time / duration

		translation = pos_a + dir * weight
		mesh.transform.basis = basis_a.slerp(basis_b, weight)
		mesh.translation = Vector3(0, 0.5 + sin(weight * PI) / 4, 0)

		if time >= duration:
			break

		yield(get_tree(), "idle_frame")

func cor_half_move(args : Array): # args = [Vector3, float]
	var pos_original = translation
	var pos_a = translation
	var pos_b = args[0]

	var dir = pos_b - pos_a

	var basis_a = mesh.transform.basis
	var basis_b = basis_a.rotated(Vector3(dir.z, 0, -dir.x), PI / 2)

	var duration = args[1]
	var time = 0

	while true:
		time = min(time + get_process_delta_time(), duration)
		var weight = time / (duration)

		translation = pos_a + dir * weight
		mesh.transform.basis = basis_a.slerp(basis_b, weight)
		mesh.translation = Vector3(0, 0.5 + sin(weight * PI) / 4, 0)

		if time >= (duration):
			break

		yield(get_tree(), "idle_frame")

	pos_b = pos_original
	pos_a = translation
	dir = pos_b - pos_a
	time = 0

	while true:
		time = min(time + get_process_delta_time(), duration)
		var weight = time / (duration)

		translation = pos_a + dir * weight

		if time >= (duration):
			break

		yield(get_tree(), "idle_frame")

func cor_shake(args : Array):
	var duration = args[0]
	var time = 0

	var zero = Vector3(0, 0.5, 0)
	var intensity = 0.02

	while true:
		time = min(time + get_process_delta_time(), duration)

		mesh.translation = zero + (2 * Vector3(randf(), randf(), randf()) - Vector3.ONE) * intensity

		if time >= duration:
			mesh.translation = zero
			break

		yield(get_tree(), "idle_frame")
