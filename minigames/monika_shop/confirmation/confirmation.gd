extends ColorRect

@onready var top = $top

func start(item):
	top.text = "Would You Like To Buy " + item.name + "?"
	visible = true
