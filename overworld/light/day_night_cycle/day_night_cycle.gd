extends CanvasModulate

@export var lightGradient:GradientTexture1D

func _process(_delta):
	var colorTime = (sin(Overworld.time - PI/2) + 1) / 2
	color = lightGradient.gradient.sample(colorTime)
	#print(colorTime)

func time_ticked():
	pass
