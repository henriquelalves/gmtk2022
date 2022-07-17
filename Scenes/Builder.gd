extends Node

const Obstacle = preload("res://Scenes/Obstacle.tscn")
const PlateBounce = preload("res://Scenes/PlateBounce.tscn")
const PlateDamage = preload("res://Scenes/PlateDamage.tscn")
const PlateKey = preload("res://Scenes/PlateKey.tscn")
const Crystal = preload("res://Scenes/Crystal.tscn")

const room_size = 6

const room_positions = [
	Vector2(-1, -1),
	Vector2( 0, -1),
	Vector2( 0,  0),
	Vector2(-1,  0)
]

const room_counts = [
	1,
	1,
	2,
	2,
	3,
	4
]

const crystal_counts = [
	1,
	2,
	2,
	3,
	4,
	6
]

enum Divider {
	NONE,
	DOOR,
	TRAP
}

const divider_weight = {
	Divider.NONE: 0.5,
	Divider.DOOR: 0.3,
	Divider.TRAP: 0.2
}

enum Layout {
	EXAMPLE
}

const available_layouts = [
	[Layout.EXAMPLE],
	[Layout.EXAMPLE],
	[Layout.EXAMPLE],
	[Layout.EXAMPLE],
	[Layout.EXAMPLE],
	[Layout.EXAMPLE]
]

func build(player : Entity, dungeon):
	dungeon.add_child(player)

	var current_stage = randi() % 6 # Global.current_stage

	var room_count = room_counts[current_stage]
	var start = randi() % 4
	var spawn = (start + randi() % room_count) % 4

	var divider_count = 0
	var crystal_remainder = crystal_counts[current_stage]

	var rooms = {}
	for i in range(start, start + room_count):
		rooms[room_positions[i % 4]] = true

	var index = 0
	for key in rooms:
		var length = room_size + 1
		var corner = key * length

		for i in range(0, length):
			if not rooms.has(key + Vector2(-1, 0)):
				build_obstacle(corner + Vector2(0, i), dungeon)

			if not rooms.has(key + Vector2(0, -1)):
				build_obstacle(corner + Vector2(i + 1, 0), dungeon)

			if not rooms.has(key + Vector2(+1, 0)):
				build_obstacle(corner + Vector2(length, i + 1), dungeon)

			if not rooms.has(key + Vector2(0, +1)):
				build_obstacle(corner + Vector2(i, length), dungeon)

		if rooms.has(key + Vector2(-1, 0)):
			divider_count = build_divider(corner, Vector2(0, 1), divider_count, dungeon)

		if rooms.has(key + Vector2(0, -1)):
			divider_count = build_divider(corner, Vector2(1, 0), divider_count, dungeon)

		var crystal_min = max(crystal_remainder - 2 * (room_count - 1), 0)
		var crystal_count = randi_range(crystal_min, min(crystal_remainder, 2))

		var spawn_pos = build_layout(corner + Vector2.ONE, crystal_count, current_stage, dungeon)
		if room_positions[spawn] == key:
			dungeon.set_tile(player, spawn_pos)

		room_count -= 1
		crystal_remainder -= crystal_count

	for key in dungeon.tiles_entities:
		dungeon.tiles_entities[key].translation = dungeon.tile_to_pos(key)

	for key in dungeon.tiles_floor:
		dungeon.tiles_floor[key].translation = dungeon.tile_to_pos(key)

func build_obstacle(pos : Vector2, dungeon):
	var object = Obstacle.instance()
	dungeon.add_child(object)
	dungeon.set_tile(object, pos)

func build_plate_damage(pos : Vector2, dungeon):
	var object = PlateDamage.instance()
	dungeon.add_child(object)
	dungeon.set_tile(object, pos)

func build_crystal(pos_crystal : Vector2, pos_key : Vector2, dungeon):
	var crystal = Crystal.instance()
	var key = PlateKey.instance()
	key.set_crystal(crystal)

	dungeon.add_child(crystal)
	dungeon.add_child(key)

	dungeon.set_tile(crystal, pos_crystal)
	dungeon.set_tile(key, pos_key)

func build_divider(pos : Vector2, dir : Vector2, count : int, dungeon):
	if count == 3:
		build_obstacle(Vector2.ZERO, dungeon)
		for i in range(0, room_size):
				build_obstacle(pos + dir * (i + 1), dungeon)
		return count

	match choose_divider():
		Divider.DOOR:
			build_divider_door(pos, dir, dungeon)

		Divider.TRAP:
			build_divider_trap(pos, dir, dungeon)

	return count + 1

func build_divider_door(pos : Vector2, dir : Vector2, dungeon):
	var opening = randi() % room_size
	for i in range(0, room_size):
		if i != opening:
			build_obstacle(pos + dir * (i + 1), dungeon)

func build_divider_trap(pos : Vector2, dir : Vector2, dungeon):
	for i in range(randi() % 2, room_size, 2):
		build_plate_damage(pos + dir * (i + 1), dungeon)

func choose_divider() -> int:
	var sum = randf()
	for option in [Divider.NONE, Divider.DOOR, Divider.TRAP]:
		sum -= divider_weight[option]
		if sum < 0:
			return option

	return Divider.NONE

func build_layout(corner : Vector2, crystals : int, current_stage : int,  dungeon):
	match choose_layout(current_stage):
		Layout.EXAMPLE:
			return build_layout_example(corner, crystals, dungeon)

func build_layout_example(corner : Vector2, crystals : int, dungeon):
	if crystals >= 1:
		build_crystal(corner + Vector2(2, 2), corner + Vector2(2, 3), dungeon)

	if crystals >= 2:
		build_crystal(corner + Vector2(4, 2), corner + Vector2(4, 3), dungeon)

	return corner

func choose_layout(current_stage : int) -> int:
	var sum = randf()
	for option in available_layouts[current_stage]:
		sum -= divider_weight[option]
		if sum < 0:
			return option

	return Layout.EXAMPLE

func randi_range(a : int, b : int) -> int:
	return int(round(randf() * (b - a) + a))
