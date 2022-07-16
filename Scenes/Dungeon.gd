extends Spatial

const Player = preload("res://Scenes/Player.tscn")
const Obstacle = preload("res://Scenes/Obstacle.tscn")
const MonsterScene = preload("res://Scenes/MonsterRandCardinal.tscn")

onready var camera = $Pitch
onready var player : Entity = null

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

func build_floor():
	player = Player.instance()
	add_child(player)

	var rand_pos = Vector2(-5, 0)
	set_tile(player, rand_pos)

	for i in range(4):
		rand_pos = Vector2(randi()%6 - 3, randi()%6 - 3)
		var obstacle = Obstacle.instance()
		set_tile(obstacle, rand_pos)
		add_child(obstacle)

	for i in range(2):
		rand_pos = Vector2(randi()%6 - 3, randi()%6 - 3)
		var monster = MonsterScene.instance()
		set_tile(monster, rand_pos)
		add_child(monster)

	for key in tiles_entities:
		tiles_entities[key].translation = tile_to_pos(key)

	camera.follow(player)

func _process(delta):
	var actionables = get_tree().get_nodes_in_group("actionables")

	var idle = true

	for actionable in actionables:
		var entity : Entity = actionable
		if entity.actions_queue.size() > 0:
			idle = false
			break

	if not idle or input == Vector2.ZERO:
		return

	process_turn_logic()

func process_turn_logic():
	# player attack

	# player move
	if move_entity(player, input):
		player.roll(input)
	input = Vector2.ZERO

	# check tile player

	# monsters move+attack
	var monsters = get_tree().get_nodes_in_group("monsters")
	for monster in monsters:
		monster = monster as Monster
		var monster_action = monster.try_moving(entities_tiles[player], entities_tiles[monster])
		match monster_action.type:
			Monster.MonsterActionType.IDLE:
				pass
			Monster.MonsterActionType.ATTACK:
				pass
			Monster.MonsterActionType.MOVE:
				print(monster_action.dir)
				move_entity(monster, monster_action.dir)

	# check tile monsters

	# start actions
	var actionables = get_tree().get_nodes_in_group("actionables")
	print(actionables)
	for actionable in actionables:
		actionable.play_actions()

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
			get_tree().change_scene("res://Scenes/Dungeon.tscn")

func move_entity(entity : Entity, dir : Vector2):
	var cur_tile = entities_tiles[entity]
	var new_tile = cur_tile + dir

	if tiles_entities.has(new_tile):
		entity.add_action("cor_shake", [0.2])
		return false

	set_tile(entity, new_tile)

	#player_check_attack(new_tile)
	print("foi")
	entity.add_action("cor_move", [tile_to_pos(new_tile), 0.2])
	return true

func tile_to_pos(tile : Vector2):
	return Vector3(tile.x, 0, -tile.y)

func pos_to_tile(pos: Vector3):
	return Vector2(round(pos.x), round(-pos.z))
