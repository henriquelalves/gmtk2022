extends Entity

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

var symbols = ['1', '3', '5', '2', '4', '6']

var side = 0
var spin = 0
var idle = true

func get_top():
	return symbols[side]

func set_bottom(symbol : String):
	symbols[5 - side] = symbol

func roll(direction : Vector2):
	var cardinal = (get_cardinal(-direction) - spin) % 4

	spin = chart_spin[side][cardinal] + spin
	side = chart_side[side][cardinal]

func get_cardinal(direction: Vector2):
	if direction.y > 0:
		return 0

	if direction.x < 0:
		return 1

	if direction.y < 0:
		return 2

	if direction.x > 0:
		return 3

func get_upper_face():
	return get_top()

func cor_move(args : Array): # args = [Vector3]
	var new_pos = args[0]
	var dir = Vector2(new_pos.x - translation.x, new_pos.z - translation.z)
	$Mesh.roll(dir)

	yield(.cor_move(args), "completed")
