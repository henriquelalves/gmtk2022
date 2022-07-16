extends Entity

class_name Monster

enum MonsterActionType {IDLE, ATTACK, MOVE}

export(int) var damage = 1
export(int) var health = 1

onready var alive = true
onready var sprite = $Sprite3D

func _ready():
	._ready()
	add_to_group("monsters")

func try_moving(player_pos : Vector2, monster_pos : Vector2) -> MonsterAction:
	return MonsterAction.new()

func cor_attack(args : Array):
	yield()

func cor_stomp(args : Array):
	$AnimationPlayer.play("stomp")
	yield($AnimationPlayer, "animation_finished")

func cor_dies(args : Array):
	$AnimationPlayer.play("fucking_dies")
	yield($AnimationPlayer, "animation_finished")
	hide()

func get_weakness():
	return ['1','2','3','4','5','6']

class MonsterAction:
	var type : int
	var dir : Vector2

	func _init():
		type = MonsterActionType.IDLE
		dir = Vector2(0,0)
