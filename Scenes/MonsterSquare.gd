extends Monster

const directions = [Vector2(1,0), Vector2(0,1), Vector2(-1,0), Vector2(0,-1)]

var dir_i = 0
var dir = 1

func _ready():
	._ready()
	dir_i = randi() % 4
	if randf() < 0.5:
		dir = -1

func try_moving(player_pos : Vector2, monster_pos : Vector2) -> MonsterAction:
	var action = MonsterAction.new()

	var next_movement = directions[dir_i]
	var next_pos = monster_pos + next_movement

	if next_pos == player_pos:
		action.type = MonsterActionType.ATTACK
	else:
		action.type = MonsterActionType.MOVE
		action.dir = next_movement
		dir_i = (dir_i + dir) % 4

	return action

func cor_attack(args : Array):
	yield(.cor_attack(args), "completed")
