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
var block_input : bool = false

var tiles_entities = {}
var entities_tiles = {}

var tiles_floor = {}

func _ready():
	randomize()
	build_floor()

	Global.active_crystals = 0
	Global.max_crystals = get_tree().get_nodes_in_group("crystals").size()

	intro_animation()

func intro_animation():
	block_input = true
	player.hide()
	$UIController.hand_animation()
	yield(get_tree().create_timer(1.1), "timeout")
	player.show()

	if Global.onboarding:
		yield($UIController.on_onboarding(), "completed")
		Global.onboarding = false

	block_input = false

func end_animation():
	block_input = true
	$UIController.hand_animation()
	yield(get_tree().create_timer(1.1), "timeout")
	player.hide()
	yield(get_tree().create_timer(2), "timeout")
	next_stage()

func game_over_animation():
	block_input = true
	$UIController.hand_animation()
	yield(get_tree().create_timer(1.1), "timeout")
	player.hide()
	yield(get_tree().create_timer(2), "timeout")
	Global.current_stage += 1
	get_tree().change_scene("res://Scenes/Transition.tscn")

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

func damage_player(damage):
	ui_controller.on_damaged(damage, player.translation)

func build_floor():
	player = Player.instance()
	player.connect("damaged", self, "damage_player")
	camera.follow(player)
	Builder.build(player, self)

func _process(delta):
	if block_input: return

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
		end_animation()

	if not idle or input == Vector2.ZERO:
		return

	process_turn_logic()

func next_stage():
	if Global.current_stage < 5:
		Global.turns += Global.BONUS_TURNS_STAGE_FINISH
	Global.current_stage += 1
	get_tree().change_scene("res://Scenes/Transition.tscn")

func process_turn_logic():
	# player attack
	var cur_tile = entities_tiles[player]
	var new_tile = cur_tile + input
	new_tile = new_tile.round()

	# simulate roll to attack
	player.roll(input)
	if tiles_entities.has(new_tile):
		var monster = tiles_entities[new_tile]
		if monster is Monster:
			var top = int(player.get_upper_face())
			if monster.health - top <= 0:
				monster.alive = false
				monster.add_action("cor_dies", [])
				Global.turns += int(player.get_upper_face()) * 2
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
				player.add_action("cor_damage", [0.2, 1])
				Global.turns -= 1
			Monster.MonsterActionType.MOVE:
				move_entity(monster, monster_action.dir)

	# check tile monsters

	# start actions
	var actionables = get_tree().get_nodes_in_group("actionables")
	for actionable in actionables:
		actionable.play_actions()

	Global.turns -= 1
	if Global.turns <= 0:
		game_over_animation()

func _input(event):
	if block_input: return

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
#		KEY_ESCAPE:
#			Global.turns = Global.STARTING_TURNS
#			get_tree().change_scene("res://Scenes/Dungeon.tscn")

func move_entity(entity : Entity, dir : Vector2):
	var cur_tile = entities_tiles[entity]
	var new_tile = cur_tile + dir
	new_tile = new_tile.round()

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
