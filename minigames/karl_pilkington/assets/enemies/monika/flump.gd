extends Sprite2D

@onready var vineArray = [$Flumpvine, $Flumpvine2]

func _process(delta):
	for i in vineArray.size():
		vineArray[i].rotation_degrees += 50 * delta


func _on_area_2d_area_entered(area):
	area.owner.hit()
