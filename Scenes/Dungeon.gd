extends Spatial

const Player = preload("res://Scenes/Player.tscn")
const Obstacle = preload("res://Scenes/Obstacle.tscn")

onready var camera = $Pitch
onready var player : Entity = null

var input : Vector2

var tiles_entities = {}
var tiles_floor = {}

func _ready():
	randomize()
	build_floor()

func build_floor():
	player = Player.instance()
	add_child(player)

	var rand_pos = Vector2(-5, 0)
	tiles_entities[rand_pos] = player

	for i in range(4):
		rand_pos = Vector2(randi()%6 - 3, randi()%6 - 3)
		var obstacle = Obstacle.instance()
		tiles_entities[rand_pos] = obstacle
		add_child(obstacle)

	for key in tiles_entities:
		tiles_entities[key].translation = tile_to_pos(key)

	camera.follow(player)

func _process(delta):
	var actionables = get_tree().get_nodes_in_group("actionables")

	#TODO O T I M I Z A R
	var idle = true
	for actionable in actionables:
		var entity : Entity = actionable
		if entity.actions_queue.size() > 0:
			idle = false
			break

	if not idle or input == Vector2.ZERO:
		return

	move_player(input)
	input = Vector2.ZERO

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

func player_check_attack(tile):
	pass

# turn player
# turn monster

# player input
# player attack
# player move
# check tile player
# monsters move+attack
# check tile monsters

func move_player(dir : Vector2):
	var cur_tile = pos_to_tile(player.translation)
	var new_tile = cur_tile + dir

	if tiles_entities.has(new_tile):
		return

	tiles_entities.erase(cur_tile)
	tiles_entities[new_tile] = player

	#player_check_attack(new_tile)

	player.add_action("cor_move", [tile_to_pos(new_tile)])
	player.roll(dir)

func tile_to_pos(tile : Vector2):
	return Vector3(tile.x, 0, -tile.y)

func pos_to_tile(pos: Vector3):
	return Vector2(round(pos.x), round(-pos.z))
