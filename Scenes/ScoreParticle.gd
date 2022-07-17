extends TextureRect

onready var animation_player = $AnimationPlayer

func animate():
	var anim = animation_player.get_animation("Animate")
	anim = anim.duplicate() as Animation

	var v = anim.track_get_key_value(0,0)
	v[0] = rect_position.x
	anim.track_set_key_value(0,0,v)
	
	v = anim.track_get_key_value(1,0)
	v[0] = rect_position.y
	anim.track_set_key_value(1,0,v)
	
	animation_player.add_animation("Animate", anim)
	animation_player.play("Animate")
	
	yield(animation_player, "animation_finished")
	$AudioStreamPlayer.play()
