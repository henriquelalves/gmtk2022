extends Node

const Ground = preload("res://Scenes/Ground.tscn")
const Obstacle = preload("res://Scenes/Obstacle.tscn")
const Crystal = preload("res://Scenes/Crystal.tscn")

const PlateBounce = preload("res://Scenes/PlateBounce.tscn")
const PlateDamage = preload("res://Scenes/PlateDamage.tscn")
const PlateKey = preload("res://Scenes/PlateKey.tscn")

const MonsterIdle = preload("res://Scenes/MonsterIdle.tscn")
const MonsterRandCardinal = preload("res://Scenes/MonsterRandCardinal.tscn")
const MonsterRandom = preload("res://Scenes/MonsterRandom.tscn")
const MonsterSquare = preload("res://Scenes/MonsterSquare.tscn")

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
	TUTORIAL,
	EASY_1,
	EASY_2,
	EASY_3,
	NORMAL_1,
	NORMAL_2,
	NORMAL_3,
	HARD
}

const available_layouts = [
	[Layout.TUTORIAL],
	[Layout.EASY_1, Layout.EASY_2],
	[Layout.EASY_1, Layout.EASY_2, Layout.EASY_3],
	[Layout.EASY_2, Layout.EASY_3, Layout.NORMAL_1, Layout.NORMAL_2],
	[Layout.NORMAL_1, Layout.NORMAL_2, Layout.NORMAL_3],
	[Layout.NORMAL_1, Layout.NORMAL_2, Layout.NORMAL_3, Layout.HARD],
]

func build(player : Entity, dungeon):
	dungeon.add_child(player)

	var current_stage = min(Global.current_stage, 5)

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

		var ground = Ground.instance()
		dungeon.add_child(ground)
		ground.translation = dungeon.tile_to_pos(corner + Vector2.ONE / 2)

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

func place_entity(scene : PackedScene, pos : Vector2, dungeon) -> Node:
	var instance = scene.instance()
	dungeon.set_tile(instance, pos.round())
	dungeon.add_child(instance)
	return instance

func place_floor(scene : PackedScene, pos : Vector2, dungeon) -> Node:
	var instance = scene.instance()
	dungeon.tiles_floor[pos.round()] = instance
	dungeon.add_child(instance)
	return instance

func build_obstacle(pos : Vector2, dungeon):
	place_entity(Obstacle, pos, dungeon)

func build_crystal(pos_crystal : Vector2, pos_key : Vector2, dungeon):
	var crystal = place_entity(Crystal, pos_crystal, dungeon)
	var key = place_floor(PlateKey, pos_key, dungeon)
	key.set_crystal(crystal)

func build_plate_bounce(pos : Vector2, cardinal : int, dungeon):
	var plate_bounce = place_floor(PlateBounce, pos, dungeon)
	plate_bounce.set_cardinal(cardinal)

func build_plate_damage(pos : Vector2, dungeon):
	place_floor(PlateDamage, pos, dungeon)

func build_monster_idle(pos : Vector2, dungeon):
	place_entity(MonsterIdle, pos, dungeon)

func build_monster_rand_cardinal(pos : Vector2, dungeon):
	place_entity(MonsterRandCardinal, pos, dungeon)

func build_monster_random(pos : Vector2, dungeon):
	place_entity(MonsterRandom, pos, dungeon)

func build_monster_square(pos : Vector2, dungeon):
	place_entity(MonsterSquare, pos, dungeon)

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

	func build_obstacle(delta : Vector2):
		Builder.build_obstacle(pos(delta), dungeon)

	func build_crystal(delta_crystal : Vector2, delta_key : Vector2):
		Builder.build_crystal(pos(delta_crystal), pos(delta_key), dungeon)

	func build_plate_bounce(delta : Vector2, cardinal : int):
		cardinal = round(cardinal + phi / PI * 2)
		Builder.build_plate_bounce(pos(delta), cardinal % 4, dungeon)

	func build_plate_damage(delta : Vector2):
		Builder.build_plate_damage(pos(delta), dungeon)

	func build_monster_idle(delta : Vector2):
		Builder.build_monster_idle(pos(delta), dungeon)

	func build_monster_rand_cardinal(delta : Vector2):
		Builder.build_monster_rand_cardinal(pos(delta), dungeon)

	func build_monster_random(delta : Vector2):
		Builder.build_monster_random(pos(delta), dungeon)

	func build_monster_square(delta : Vector2):
		Builder.build_monster_square(pos(delta), dungeon)

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
	
	if Global.current_stage != 0:
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
		Layout.TUTORIAL:
			return build_layout_tutorial(crystals, space)

		Layout.EASY_1:
			return build_layout_easy_1(crystals, space)

		Layout.EASY_2:
			return build_layout_easy_2(crystals, space)

		Layout.EASY_3:
			return build_layout_easy_3(crystals, space)

		Layout.NORMAL_1:
			return build_layout_normal_1(crystals, space)

		Layout.NORMAL_2:
			return build_layout_normal_2(crystals, space)

		Layout.NORMAL_3:
			return build_layout_normal_3(crystals, space)

		Layout.HARD:
			return build_layout_hard(crystals, space)

func build_layout_tutorial(crystals : int, space : Space):
	space.build_crystal(Vector2(2, 4), Vector2(3, 4))
	space.build_monster_idle(Vector2(3, 2))
	return space.pos(Vector2(2, 1))

func build_layout_easy_1(crystals : int, space : Space):
	if crystals >= 1:
		space.build_crystal(Vector2(3, 2), Vector2(1, 4))

	if crystals >= 2:
		space.build_crystal(Vector2(4, 4), Vector2(4, 2))

	space.build_monster_idle(Vector2(3, 4))
	space.build_plate_damage(Vector2(1, 3))

	return space.pos(Vector2(3, 1))

func build_layout_easy_2(crystals : int, space : Space):
	if crystals >= 1:
		space.build_crystal(Vector2(0, 5), Vector2(2, 5))

	if crystals >= 2:
		space.build_crystal(Vector2(5, 5), Vector2(3, 5))

	space.build_monster_idle(Vector2(1, 1))
	space.build_monster_rand_cardinal(Vector2(3, 2))

	return space.pos(Vector2(2, 0))

func build_layout_easy_3(crystals : int, space : Space):
	if crystals >= 1:
		space.build_crystal(Vector2(2, 2), Vector2(1, 4))

	if crystals >= 2:
		space.build_crystal(Vector2(3, 3), Vector2(4, 1))

	space.build_plate_damage(Vector2(2, 3))
	space.build_plate_damage(Vector2(3, 2))
	space.build_plate_bounce(Vector2(1, 3), 3)
	space.build_plate_bounce(Vector2(4, 2), 1)

	return space.pos(Vector2(0, 0))

func build_layout_normal_1(crystals : int, space : Space):
	if crystals >= 1:
		space.build_crystal(Vector2(2, 1), Vector2(3, 5))

	if crystals >= 2:
		space.build_crystal(Vector2(2, 2), Vector2(0, 0))

	space.build_monster_rand_cardinal(Vector2(3, 4))
	space.build_monster_rand_cardinal(Vector2(4, 5))
	space.build_monster_rand_cardinal(Vector2(0, 2))

	return space.pos(Vector2(3, 3))

func build_layout_normal_2(crystals : int, space : Space):
	if crystals >= 1:
		space.build_crystal(Vector2(3, 4), Vector2(2, 1))

	if crystals >= 2:
		space.build_crystal(Vector2(4, 2), Vector2(4, 4))

	space.build_plate_bounce(Vector2(1, 3), 3)
	space.build_plate_bounce(Vector2(2, 3), 0)
	space.build_plate_bounce(Vector2(4, 1), 1)
	space.build_plate_bounce(Vector2(3, 1), 1)

	space.build_monster_random(Vector2(3, 2))
	space.build_monster_random(Vector2(0, 1))

	return space.pos(Vector2(1, 5))

func build_layout_normal_3(crystals : int, space : Space):
	if crystals >= 1:
		space.build_crystal(Vector2(5, 5), Vector2(4, 5))

	if crystals >= 2:
		space.build_crystal(Vector2(3, 4), Vector2(3, 3))

	space.build_monster_square(Vector2(4, 2))
	space.build_monster_square(Vector2(1, 4))

	space.build_plate_damage(Vector2(0, 2))
	space.build_plate_damage(Vector2(2, 2))

	return space.pos(Vector2(0, 1))

func build_layout_hard(crystals : int, space : Space):
	if crystals >= 1:
		space.build_crystal(Vector2(2, 5), Vector2(5, 3))

	if crystals >= 2:
		space.build_crystal(Vector2(3, 1), Vector2(2, 1))

	space.build_monster_square(Vector2(4, 4))
	space.build_monster_random(Vector2(1, 4))
	space.build_monster_rand_cardinal(Vector2(3, 0))

	space.build_plate_damage(Vector2(0, 2))
	space.build_plate_damage(Vector2(2, 2))
	space.build_plate_damage(Vector2(3, 2))
	space.build_plate_damage(Vector2(5, 2))
	space.build_plate_bounce(Vector2(1, 2), 0)

	return space.pos(Vector2(0, 3))

func choose_layout(current_stage : int) -> int:
	var options = available_layouts[current_stage]
	return options[randi() % options.size()]

func randi_range(a : int, b : int) -> int:
	return int(round(randf() * (b - a) + a))
