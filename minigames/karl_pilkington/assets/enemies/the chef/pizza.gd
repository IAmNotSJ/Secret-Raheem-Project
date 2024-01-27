extends Sprite2D

const SPEED = 200
var target
var angle:float = 0

func _process(delta):
	var direction = target.global_position - $Marker2D.global_position
	var angleTo = $Marker2D.transform.x.angle_to(direction)
	angle = angleTo
	rotation = angle
	
	position.x += SPEED * cos(angle) * delta
	position.y += SPEED * sin(angle) * delta


func _on_area_2d_area_entered(area):
	area.owner.hit()
