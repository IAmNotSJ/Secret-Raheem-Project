class_name OverworldBase extends Node2D

func _ready():
	if Overworld.positions[name] != Vector2.ZERO:
		$Wibr.position = Overworld.positions[name]
	else:
		print('what')
