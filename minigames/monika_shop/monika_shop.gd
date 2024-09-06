extends Node2D

func _ready():
	Dialogic.Inputs.auto_advance.enabled_forced = true
	Dialogic.start("res://minigames/monika_shop/dialogue/timeline.dtl")

