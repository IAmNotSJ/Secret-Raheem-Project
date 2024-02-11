extends Area2D

var alpha:float = 1

func _process(_delta):
	get_parent().modulate.a = lerp(get_parent().modulate.a, alpha, 0.4)

func _on_area_entered(_area):
	alpha = 0.3
func _on_area_exited(_area):
	alpha = 1
