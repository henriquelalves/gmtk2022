extends Entity

class_name Monster

enum MonsterActionType {IDLE, ATTACK, MOVE}

export(int) var damage = 1

onready var sprite = $Sprite3D

func _ready():
	add_to_group("monsters")

func try_moving(player_pos : Vector2, monster_pos : Vector2) -> MonsterAction:
	return MonsterAction.new()

func cor_attack(args : Array):
	yield()

class MonsterAction:
	var type : int
	var dir : Vector2

	func _init():
		type = MonsterActionType.IDLE
		dir = Vector2(0,0)
