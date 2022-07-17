extends Spatial

export (Array, NodePath) var dices
onready var camera = get_viewport().get_camera()

onready var prev_stage = 0
onready var next_stage = 0

func _ready():
	prev_stage = Global.current_stage - 1
	next_stage = Global.current_stage
	
	get_node(dices[prev_stage+1]).show()
	
	yield(animate_next_stage(), "completed")
	yield(get_tree().create_timer(2), "timeout")
	get_tree().change_scene("res://Scenes/Dungeon.tscn")

func animate_next_stage():
	var pos0 = $UIController/ArmPivot.rect_position
	var pos1 = camera.unproject_position(get_node(dices[prev_stage+1]).translation)
	var pos2 = camera.unproject_position(get_node(dices[next_stage+1]).translation)
	
	yield(get_tree().create_timer(1), "timeout")
	tween_pos(pos1)
	yield(get_tree().create_timer(1), "timeout")
	get_node(dices[prev_stage+1]).hide()
	tween_pos(pos2)
	yield(get_tree().create_timer(1), "timeout")
	get_node(dices[next_stage+1]).show()
	tween_pos(pos0)

func tween_pos(pos):
	$Tween.interpolate_property(\
		$UIController/ArmPivot,\
		"rect_position",\
		$UIController/ArmPivot.rect_position,\
		pos,\
		1,\
		Tween.TRANS_CUBIC,\
		Tween.EASE_OUT
	)
	$Tween.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
