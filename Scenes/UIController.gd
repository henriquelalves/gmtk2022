extends CanvasLayer

onready var main_camera = get_viewport().get_camera()
onready var ScoreParticle = preload("res://Scenes/ScoreParticle.tscn")
onready var particles = $Particles

func _ready():
	Global.connect("update_ui", self, "_on_update_ui")
	_on_update_ui()

func _on_update_ui():
	$NumberOfTurns.text = "Turns left: %d" % Global.turns

func on_monster_killed(monster_pos, score):
	for i in range(score):
		var score_particle = particles.get_child(i % 6)
		score_particle.rect_position = main_camera.unproject_position(monster_pos)
		score_particle.animate()
		yield(get_tree().create_timer(0.1),"timeout")
	
	
