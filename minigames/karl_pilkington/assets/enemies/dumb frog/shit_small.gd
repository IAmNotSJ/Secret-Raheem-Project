extends Sprite2D

const rotation_speed = 50
const firing_speed = 500

var direction:int = 0

func _process(delta):
	position.x += firing_speed * cos(deg_to_rad(direction)) * delta
	position.y += firing_speed * sin(deg_to_rad(direction)) * delta

func destroy():
	queue_free()

func _on_area_2d_area_entered(area):
	area.owner.hit()
	destroy()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
