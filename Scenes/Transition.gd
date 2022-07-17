extends Spatial

export (Array, NodePath) var dices
onready var camera = get_viewport().get_camera()

onready var prev_stage = 0
onready var next_stage = 0

func _ready():
	set_process_input(false)
	prev_stage = Global.current_stage - 1
	next_stage = Global.current_stage
	
	if prev_stage >= 0:
		get_node(dices[prev_stage]).show()
	
	if Global.turns > 0:
		if Global.current_stage != 0:
			$AudioFanfare.play()
		if prev_stage == 5:
			victory()
		else:
			yield(animate_next_stage(), "completed")
			yield(get_tree().create_timer(2), "timeout")
			get_tree().change_scene("res://Scenes/Dungeon.tscn")
	else:
		game_over()

func victory():
	$UIController/Victory/Label2.text = "You finished the game with %d turns remaining!" % Global.turns
	
	yield(get_tree().create_timer(1),"timeout")
	$UIController/Victory/AnimationPlayer.play("FadeIn")
	yield(get_tree().create_timer(1),"timeout")
	set_process_input(true)

func game_over():
	yield(get_tree().create_timer(1),"timeout")
	var pos = camera.unproject_position(get_node(dices[prev_stage]).translation)
	$UIController/Explosion.position = pos
	$UIController/Explosion.show()
	$UIController/Explosion/AnimationPlayer.play("Explode")
	$AudioExplosion.play()
	yield(get_tree().create_timer(0.1),"timeout")
	get_node(dices[prev_stage]).hide()
	yield(get_tree().create_timer(1),"timeout")
	$UIController/GameOver/AnimationPlayer.play("FadeIn")
	yield(get_tree().create_timer(1),"timeout")
	set_process_input(true)

func _input(event):
	if event is InputEventKey and event.is_pressed():
		Global.reset()
		get_tree().change_scene("res://Scenes/Transition.tscn")

func animate_next_stage():
	var pos0 = $UIController/ArmPivot.rect_position
	var pos1 = null
	if prev_stage >= 0:
		pos1 = camera.unproject_position(get_node(dices[prev_stage]).translation)
	var pos2 = camera.unproject_position(get_node(dices[next_stage]).translation)
	
	yield(get_tree().create_timer(1), "timeout")
	if pos1 != null:
		tween_pos(pos1)
		yield(get_tree().create_timer(1), "timeout")
		get_node(dices[prev_stage]).hide()
	tween_pos(pos2)
	yield(get_tree().create_timer(1), "timeout")
	get_node(dices[next_stage]).show()
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
