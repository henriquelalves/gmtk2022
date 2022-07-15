extends Spatial

const Player = preload("res://Scenes/Player.tscn")
const Obstacle = preload("res://Scenes/Obstacle.tscn")

onready var player = null
onready var camera = $Pitch

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
	player.target_position = Vector3()

	for i in range(4):
		rand_pos = Vector2(randi()%6 - 3, randi()%6 - 3)
		var obstacle = Obstacle.instance()
		tiles_entities[rand_pos] = obstacle
		add_child(obstacle)

	for key in tiles_entities:
		tiles_entities[key].translation = tile_to_pos(key)
		if tiles_entities[key].get("target_position") != null:
			tiles_entities[key].target_position = tile_to_pos(key)

	camera.follow(player)

func tile_to_pos(tile : Vector2):
	return Vector3(tile.x, 0, -tile.y)

func pos_to_tile(pos: Vector3):
	return Vector2(round(pos.x), round(-pos.z))

func _process(delta):
	for tile in tiles_entities.keys():
		if tiles_entities[tile].get("target_position") != null:
			var entity = tiles_entities[tile]
			var new_pos = entity.target_position
			var cur_pos = entity.translation
			entity.translation = lerp(cur_pos, new_pos, delta * 8)

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
	var curr_tile = pos_to_tile(player.target_position)
	var new_tile = curr_tile + dir

	print(new_tile)

	if tiles_entities.has(new_tile):
		return

	tiles_entities.erase(curr_tile)
	tiles_entities[new_tile] = player

	player.target_position = tile_to_pos(new_tile)
	player.get_node("Mesh").roll(dir)
