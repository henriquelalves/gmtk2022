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

func add_entity(scene : PackedScene, pos : Vector2, dungeon) -> Node:
	var instance = scene.instance()
	dungeon.set_tile(instance, pos.round())
	dungeon.add_child(instance)
	return instance

func add_floor(scene : PackedScene, pos : Vector2, dungeon) -> Node:
	var instance = scene.instance()
	dungeon.tiles_floor[pos.round()] = instance
	dungeon.add_child(instance)
	return instance

func build_obstacle(pos : Vector2, dungeon):
	add_entity(Obstacle, pos, dungeon)

func build_plate_damage(pos : Vector2, dungeon):
	add_floor(PlateDamage, pos, dungeon)

func build_crystal(pos_crystal : Vector2, pos_key : Vector2, dungeon):
	var crystal = add_entity(Crystal, pos_crystal, dungeon)
	var key = add_floor(PlateKey, pos_key, dungeon)
	key.set_crystal(crystal)

class Space:
	var origin : Vector2
	var phi : float
	var dungeon

	func _init(origin : Vector2, phi : float, dungeon):
		self.origin = origin
		self.phi = phi
		self.dungeon = dungeon

	func pos(delta : Vector2) -> Vector2:
		return origin + delta.rotated(phi)

	func build_obstacle(pos : Vector2):
		Builder.build_obstacle(pos(pos), dungeon)

	func build_plate_damage(pos : Vector2):
		Builder.build_plate_damage(pos(pos), dungeon)

	func build_crystal(pos_crystal : Vector2, pos_key : Vector2):
		Builder.build_crystal(pos(pos_crystal), pos(pos_key), dungeon)

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

func build_layout(corner : Vector2, crystals : int, current_stage : int, dungeon):
	var phi = 0
	match randi() % 4:
		1:
			corner += Vector2(room_size - 1, 0)
			phi = PI / 2
		2:
			corner += Vector2(room_size - 1, room_size - 1)
			phi = PI
		3:
			corner += Vector2(0, room_size - 1)
			phi = PI * 3 / 2

	var space = Space.new(corner, phi, dungeon)
	match choose_layout(current_stage):
		Layout.EXAMPLE:
			return build_layout_example(crystals, space)

func build_layout_example(crystals : int, space : Space):
	if crystals >= 1:
		space.build_crystal(Vector2(2, 2), Vector2(2, 3))

	if crystals >= 2:
		space.build_crystal(Vector2(4, 2), Vector2(4, 3))

	return space.pos(Vector2.ZERO)

func choose_layout(current_stage : int) -> int:
	var sum = randf()
	for option in available_layouts[current_stage]:
		sum -= divider_weight[option]
		if sum < 0:
			return option

	return Layout.EXAMPLE

func randi_range(a : int, b : int) -> int:
	return int(round(randf() * (b - a) + a))
