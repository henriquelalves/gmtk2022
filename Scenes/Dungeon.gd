extends Spatial

const Player = preload("res://Scenes/Player.tscn")
const Obstacle = preload("res://Scenes/Obstacle.tscn")

onready var player : Entity = null
onready var camera = $Pitch
onready var idle = true

onready var tiles_entities = {
}

onready var tiles_floor = {
}

# Called when the node enters the scene tree for the first time.
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

func tile_to_pos(tile : Vector2):
	return Vector3(tile.x, 0, -tile.y)

func pos_to_tile(pos: Vector3):
	return Vector2(round(pos.x), round(-pos.z))

func _process(delta):
	idle = true
	
	var actionables = get_tree().get_nodes_in_group("actionables")

	#TODO O T I M I Z A R 
	for actionable in actionables:
		var entity : Entity = actionable
		if entity.actions_queue.size() > 0:
			idle = false
			break

func check_tile(entity):
	pass

func _input(event):
	if not idle: return
	
	var turn = false
	
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		if event.scancode == KEY_UP:
			turn = true
			move_player(Vector2(0,1))
		elif event.scancode == KEY_DOWN:
			turn = true
			move_player(Vector2(0,-1))
		elif event.scancode == KEY_RIGHT:
			turn = true
			move_player(Vector2(1,0))
		elif event.scancode == KEY_LEFT:
			turn = true
			move_player(Vector2(-1,0))
	
	if turn:
		var actionables = get_tree().get_nodes_in_group("actionables")
		for actionable in actionables:
			actionable.play_actions()

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


func move_player(dir: Vector2):
	var curr_tile = pos_to_tile(player.translation)
	var new_tile = curr_tile + dir

	if tiles_entities.has(new_tile):
		return

	tiles_entities.erase(curr_tile)
	tiles_entities[new_tile] = player

	#player_check_attack(new_tile)

	player.actions_queue.append(["cor_move_entity", [tile_to_pos(new_tile)]])
	player.roll(dir)
	
	
#	player.get_node("Mesh").roll(dir)
#	player.roll(dir)
