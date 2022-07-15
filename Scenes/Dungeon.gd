extends Spatial

const Player = preload("res://Scenes/Player.tscn")
const Obstacle = preload("res://Scenes/Obstacle.tscn")

onready var player = null

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

func tile_to_pos(tile : Vector2):
	return Vector3(tile.x, 0, -tile.y)

func pos_to_tile(pos: Vector3):
	return Vector2(round(pos.x), round(-pos.z))

func _input(event):
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		if event.scancode == KEY_UP:
			move_player(Vector2(0,1))
		elif event.scancode == KEY_DOWN:
			move_player(Vector2(0,-1))
		elif event.scancode == KEY_RIGHT:
			move_player(Vector2(1,0))
		elif event.scancode == KEY_LEFT:
			move_player(Vector2(-1,0))

func move_player(dir: Vector2):
	var curr_tile = pos_to_tile(player.translation)
	var new_tile = curr_tile + dir

	if tiles_entities.has(new_tile):
		return

	tiles_entities.erase(curr_tile)
	tiles_entities[new_tile] = player
	player.translation = tile_to_pos(new_tile)
