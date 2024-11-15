extends Node2D

func _ready():
	DialogicUtil.autoload().Inputs.auto_advance.override_delay_for_current_event = 1.0
	Dialogic.Inputs.auto_advance.enabled_forced = true
	Dialogic.start("res://minigames/monika_shop/dialogue/timeline.dtl")
