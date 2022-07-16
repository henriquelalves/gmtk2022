extends Monster

onready var cardinal = Vector2.UP
onready var moved = false

func _ready():
	if randf() < 0.5:
		cardinal = Vector2.RIGHT

func try_moving(player_pos : Vector2, monster_pos : Vector2) -> MonsterAction:
	var next_movement = cardinal
	if moved:
		next_movement *= -1
	moved = !moved

	var next_pos = monster_pos + next_movement

	var action = MonsterAction.new()

	if next_pos == player_pos:
		action.type = MonsterActionType.ATTACK
	else:
		action.type = MonsterActionType.MOVE
		action.dir = next_movement

	return action


func cor_attack(args : Array):
	yield(.cor_attack(args), "completed")
