extends Sprite2D



func _on_area_2d_area_entered(area):
	if "walk_speed" in area.owner:
		area.owner.walk_speed = 100

func _on_area_2d_area_exited(area):
	if "walk_speed" in area.owner:
		area.owner.walk_speed = 350
