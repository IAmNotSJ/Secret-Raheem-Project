extends Control

@export var price:float = 100

# MAKE SURE TO INCLUDE MONIKA'S TITLE
@export var message:Array[String] = []

func _on_mouse_entered():
	$visible.position.y = -10
	var timeline : DialogicTimeline = DialogicTimeline.new()
	timeline.events = message
	Dialogic.start(timeline)

func _on_mouse_exited():
	$visible.position.y = 0
