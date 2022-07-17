extends Node

onready var STARTING_TURNS = 20
onready var BONUS_TURNS_STAGE_FINISH = 10

onready var turns = STARTING_TURNS setget set_turns
onready var current_stage = 0 setget set_stage
onready var active_crystals = 0 setget set_crystals
onready var max_crystals = 0
onready var onboarding = false

signal update_ui

func reset():
	turns = STARTING_TURNS
	current_stage = 0
	active_crystals = 0
	max_crystals = 0

func set_turns(t):
	turns = t
	emit_signal("update_ui")

func set_stage(s):
	current_stage = s
	emit_signal("update_ui")

func set_crystals(c):
	active_crystals = c
	emit_signal("update_ui")
