extends Node

onready var STARTING_TURNS = 20
onready var BONUS_TURNS_STAGE_FINISH = 10

onready var turns = STARTING_TURNS setget set_turns

signal update_ui

func set_turns(t):
	turns = t
	emit_signal("update_ui")
