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

func build(player : Entity, dungeon):
	var room_count = room_counts[Global.current_stage]
	var start = randi() % 4

	var divider_count = 0
	var rooms = {}
	for i in range(start, start + room_count):
		rooms[room_positions[i % 4]] = true

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

	var pos = Vector2(1, 1)

	dungeon.add_child(player)
	dungeon.set_tile(player, pos)

	var number_crystals = floor(Global.current_stage / 2.0) + 1
	for i in range(number_crystals):
		pos = Vector2(randi()%8 - 4, randi()%8 - 4)
		while dungeon.tiles_entities.has(pos):
			pos = Vector2(randi()%8 - 4, randi()%8 - 4)
		var crystal = Crystal.instance()
		dungeon.set_tile(crystal, pos)
		dungeon.add_child(crystal)

		pos = Vector2(randi()%8 - 4, randi()%8 - 4)
		while dungeon.tiles_entities.has(pos) or dungeon.tiles_floor.has(pos):
			pos = Vector2(randi()%8 - 4, randi()%8 - 4)
		var plate_key = PlateKey.instance()
		plate_key.set_crystal(crystal)
		dungeon.tiles_floor[pos] = plate_key
		dungeon.add_child(plate_key)

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
