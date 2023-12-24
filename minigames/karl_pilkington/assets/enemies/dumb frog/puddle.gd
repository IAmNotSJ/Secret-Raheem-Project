extends Sprite2D



func _on_area_2d_area_entered(area):
	area.owner.walk_speed = 100

func _on_area_2d_area_exited(area):
	area.owner.walk_speed = 350
