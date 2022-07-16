extends CanvasLayer

func _ready():
	Global.connect("update_ui", self, "_on_update_ui")
	_on_update_ui()

func _on_update_ui():
	$NumberOfTurns.text = "Number of turns: %d" % Global.turns
