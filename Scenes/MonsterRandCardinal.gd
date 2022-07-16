extends Monster

onready var cardinal = Vector2.UP
onready var moved = false
onready var wait = 0

func _ready():
	._ready()
	if randf() < 0.5:
		cardinal = Vector2.RIGHT

func get_weakness():
	return ['2','4','6']

func try_moving(player_pos : Vector2, monster_pos : Vector2) -> MonsterAction:
	var action = MonsterAction.new()
	
	if wait == 0:
		wait = 1
		action.type = MonsterActionType.IDLE
		return action
	else:
		wait = 0

	var next_movement = cardinal
	if moved:
		next_movement *= -1

	var next_pos = monster_pos + next_movement

	if next_pos == player_pos:
		action.type = MonsterActionType.ATTACK
	else:
		action.type = MonsterActionType.MOVE
		action.dir = next_movement
		moved = !moved

	return action

func cor_attack(args : Array):
	yield(.cor_attack(args), "completed")
