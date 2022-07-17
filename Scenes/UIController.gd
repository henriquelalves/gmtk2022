extends CanvasLayer

onready var main_camera = get_viewport().get_camera()
onready var ScoreParticle = preload("res://Scenes/ScoreParticle.tscn")
onready var particles = $Particles

onready var damage_control : Control = $Damage
onready var damage_label : Label = $Damage/Label
onready var damage_anim : AnimationPlayer = $Damage/AnimationPlayer

onready var activated_crystals

onready var skip_all = false

signal _skip_step

func _ready():
	Global.connect("update_ui", self, "_on_update_ui")
	yield(get_tree(),"idle_frame")
	_on_update_ui()

func _on_update_ui():
	$NumberOfTurns.text = "Turns left: %d" % Global.turns
	$Objectives.text = "(%d/%d) Activate the crystals!" % [Global.active_crystals, Global.max_crystals]

func on_monster_killed(monster_pos, score):
	for i in range(score):
		var score_particle = particles.get_child(i % 6)
		score_particle.rect_position = main_camera.unproject_position(monster_pos)
		score_particle.animate()
		yield(get_tree().create_timer(0.1),"timeout")

func on_damaged(damage, player_pos):
	damage_label.text = "%d" % -damage
	damage_control.rect_position = main_camera.unproject_position(player_pos)
	damage_anim.play("Fade")

func hand_animation():
	$AnimationPlayer.play("HandMoving")

func on_onboarding():
#	var monster_2d = main_camera.unproject_position(monster_pos)
#	var crystal_2d = main_camera.unproject_position(crystal_pos)
#
#	var monster_offset = Vector2(-100,100)
#	var crystal_offset = Vector2(-100,100)
#
#	$OnboardingOverlay/Intro3.rect_position = monster_2d + monster_offset
#	$OnboardingOverlay/Intro4.rect_position = monster_2d + monster_offset
#	$OnboardingOverlay/Intro5.rect_position = crystal_2d + crystal_offset
#	$OnboardingOverlay/Intro6.rect_position = crystal_2d + crystal_offset

	$OnboardingOverlay.show()
	$OnboardingOverlay/AnimationPlayer.play("FadeIn")
	yield($OnboardingOverlay/AnimationPlayer,"animation_finished")
	show_skip()
	yield(onboarding_step(1), "completed")
	yield(onboarding_step(2), "completed")
	yield(onboarding_step(3), "completed")
	yield(onboarding_step(4), "completed")
	yield(onboarding_step(5), "completed")
	yield(onboarding_step(6), "completed")
	yield(onboarding_step(7), "completed")
	$OnboardingOverlay/AnimationPlayer.play_backwards("FadeIn")
	yield($OnboardingOverlay/AnimationPlayer,"animation_finished")
	$OnboardingOverlay.hide()

func _input(event):
	if event is InputEventKey and event.is_pressed():
		if event.scancode == KEY_ESCAPE:
			skip_all = true
		emit_signal("_skip_step")


func onboarding_step(i):
	if not skip_all:
		var intro = get_node("OnboardingOverlay/Intro%d" % i)
		intro.show()
		var intro_player = intro.get_node("AnimationPlayer")
		intro_player.play("FadeIn")
		yield(intro_player, "animation_finished")

		var timer = get_tree().create_timer(4)
		timer.connect("timeout", self, "emit_signal", ["_skip_step"])

		yield(self, "_skip_step")

		if timer != null:
			timer.disconnect("timeout", self, "emit_signal")

		intro_player.play_backwards("FadeIn")
		yield(intro_player, "animation_finished")
		intro.hide()
	yield(get_tree(),"idle_frame")

func show_skip():
#	yield(get_tree().create_timer(1),"timeout")
	$OnboardingOverlay/SkipLabel/AnimationPlayer.play("FadeIn")
