extends Spatial

const Player = preload("res://Scenes/Player.tscn")
const Obstacle = preload("res://Scenes/Obstacle.tscn")
const MonsterScene = preload("res://Scenes/MonsterIdle.tscn")
const PlateBounce = preload("res://Scenes/PlateBounce.tscn")
const PlateDamage = preload("res://Scenes/PlateDamage.tscn")
const PlateKey = preload("res://Scenes/PlateKey.tscn")
const Crystal = preload("res://Scenes/Crystal.tscn")

onready var camera = $Pitch
onready var player : Entity = null
onready var ui_controller = $UIController

var input : Vector2

var tiles_entities = {}
var entities_tiles = {}

var tiles_floor = {}

func _ready():
	randomize()
	build_floor()

func set_tile(entity, tile):
	if not entities_tiles.has(entity):
		entities_tiles[entity] = tile
		tiles_entities[tile] = entity
	else:
		var old_tile = entities_tiles[entity]
		tiles_entities.erase(old_tile)
		tiles_entities[tile] = entity
		entities_tiles[entity] = tile

func kill_entity(entity):
	var tile = entities_tiles[entity]
	tiles_entities.erase(tile)
	entities_tiles.erase(entity)

func build_floor():
	player = Player.instance()
	add_child(player)

	var rand_pos = Vector2(-6, 0)
	set_tile(player, rand_pos)

	for i in range(4):
		rand_pos = Vector2(randi()%8 - 4, randi()%8 - 4)
		while tiles_entities.has(rand_pos):
			rand_pos = Vector2(randi()%8 - 4, randi()%8 - 4)
		var obstacle = Obstacle.instance()
		set_tile(obstacle, rand_pos)
		add_child(obstacle)

	for i in range(4):
		rand_pos = Vector2(randi()%8 - 4, randi()%8 - 4)
		while tiles_entities.has(rand_pos):
			rand_pos = Vector2(randi()%8 - 4, randi()%8 - 4)
		var monster = MonsterScene.instance()
		set_tile(monster, rand_pos)
		add_child(monster)

	var number_crystals = floor(Global.current_stage / 2.0) + 1
	for i in range(number_crystals):
		rand_pos = Vector2(randi()%8 - 4, randi()%8 - 4)
		while tiles_entities.has(rand_pos):
			rand_pos = Vector2(randi()%8 - 4, randi()%8 - 4)
		var crystal = Crystal.instance()
		set_tile(crystal, rand_pos)
		add_child(crystal)

		rand_pos = Vector2(randi()%8 - 4, randi()%8 - 4)
		while tiles_entities.has(rand_pos) or tiles_floor.has(rand_pos):
			rand_pos = Vector2(randi()%8 - 4, randi()%8 - 4)
		var plate_key = PlateKey.instance()
		plate_key.set_crystal(crystal)
		tiles_floor[rand_pos] = plate_key
		add_child(plate_key)

	for i in range(4):
		rand_pos = Vector2(randi()%8 - 4, randi()%8 - 4)
		while tiles_entities.has(rand_pos) or tiles_floor.has(rand_pos):
			rand_pos = Vector2(randi()%8 - 4, randi()%8 - 4)
		var plate_bounce = PlateBounce.instance()
		plate_bounce.set_cardinal(randi() % 4)
		tiles_floor[rand_pos] = plate_bounce
		add_child(plate_bounce)

	for i in range(4):
		rand_pos = Vector2(randi()%8 - 4, randi()%8 - 4)
		while tiles_entities.has(rand_pos) or tiles_floor.has(rand_pos):
			rand_pos = Vector2(randi()%8 - 4, randi()%8 - 4)
		var plate_damage = PlateDamage.instance()
		tiles_floor[rand_pos] = plate_damage
		add_child(plate_damage)

	for key in tiles_entities:
		tiles_entities[key].translation = tile_to_pos(key)

	for key in tiles_floor:
		tiles_floor[key].translation = tile_to_pos(key)

	camera.follow(player)

func _process(delta):
	var actionables = get_tree().get_nodes_in_group("actionables")
	var idle = true

	for actionable in actionables:
		var entity : Entity = actionable
		if entity.actions_queue.size() > 0:
			idle = false
			break

	var crystals = get_tree().get_nodes_in_group("crystals")
	var next_stage = true
	for crystal in crystals:
		if not crystal.is_active:
			next_stage = false
			break
	if next_stage:
		next_stage()

	if not idle or input == Vector2.ZERO:
		return

	process_turn_logic()

func next_stage():
	Global.turns += Global.BONUS_TURNS_STAGE_FINISH
	Global.current_stage += 1
	get_tree().change_scene("res://Scenes/Dungeon.tscn")

func process_turn_logic():
	# player attack
	var cur_tile = entities_tiles[player]
	var new_tile = cur_tile + input

	# simulate roll to attack
	player.roll(input)
	if tiles_entities.has(new_tile):
		var monster = tiles_entities[new_tile]
		if monster is Monster:
			var top = int(player.get_upper_face())
			if monster.health - top <= 0:
				monster.alive = false
				monster.add_action("cor_dies", [])
				Global.turns += int(player.get_upper_face())
				kill_entity(monster)
				ui_controller.on_monster_killed(monster.translation, player.get_upper_face())
			else:
				monster.health -= top
				monster.add_action("cor_stomp", [])
				player.add_action("cor_half_move", [tile_to_pos(new_tile), 0.2])
	player.roll(-input)

	# player move
	move_entity(player, input)
	input = Vector2.ZERO

	# check tile player

	# monsters move+attack
	var monsters = get_tree().get_nodes_in_group("monsters")
	for monster in monsters:
		if not monster.alive: continue
		monster = monster as Monster
		var monster_action = monster.try_moving(entities_tiles[player], entities_tiles[monster])
		match monster_action.type:
			Monster.MonsterActionType.IDLE:
				pass
			Monster.MonsterActionType.ATTACK:
				player.add_action("cor_shake", [0.2])
				Global.turns -= 1
			Monster.MonsterActionType.MOVE:
				move_entity(monster, monster_action.dir)

	# check tile monsters

	# start actions
	var actionables = get_tree().get_nodes_in_group("actionables")
	for actionable in actionables:
		actionable.play_actions()

	Global.turns -= 1

func _input(event):
	if input != Vector2.ZERO:
		return

	if not (event is InputEventKey) or not event.is_pressed() or event.is_echo():
		return

	match event.scancode:
		KEY_UP:
			input = Vector2(0,+1)
		KEY_DOWN:
			input = Vector2(0,-1)
		KEY_RIGHT:
			input = Vector2(+1,0)
		KEY_LEFT:
			input = Vector2(-1,0)
		KEY_ESCAPE:
			Global.turns = Global.STARTING_TURNS
			get_tree().change_scene("res://Scenes/Dungeon.tscn")

func move_entity(entity : Entity, dir : Vector2):
	var cur_tile = entities_tiles[entity]
	var new_tile = cur_tile + dir
	new_tile = Vector2(round(new_tile.x), round(new_tile.y))

	if tiles_entities.has(new_tile):
		if entity.has_method("cor_shake"):
			entity.add_action("cor_shake", [0.2])
		return false

	set_tile(entity, new_tile)
	entity.add_action("cor_move", [tile_to_pos(new_tile), 0.2])
	entity.roll(dir)

	if tiles_floor.has(new_tile):
		tiles_floor[new_tile].step(entity, self)

func tile_to_pos(tile : Vector2):
	return Vector3(tile.x, 0, -tile.y)

func pos_to_tile(pos: Vector3):
	return Vector2(round(pos.x), round(-pos.z))
