extends Sprite2D

var angle
const SPEED = 750

func _process(delta):
	position.x += SPEED * cos(deg_to_rad(angle)) * delta
	position.y += SPEED * sin(deg_to_rad(angle)) * delta

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()


func _on_area_2d_area_entered(area):
	area.owner.hit()
	queue_free()
