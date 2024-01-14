extends Sprite2D

const SPEED = 300
var angle:float = 0

var spin = false
const MAX_SPIN_TIMER = 2
var spin_timer = MAX_SPIN_TIMER

func _process(delta):
	rotation_degrees += 200 * delta
	if spin:
		spin_timer -= delta
		if spin_timer <= 0:
			position.x += SPEED * cos(angle) * delta
			position.y += SPEED * sin(angle) * delta
	else:
		position.x += SPEED * cos(angle) * delta
		position.y += SPEED * sin(angle) * delta



func _on_area_2d_area_entered(area):
	area.owner.hit()
	queue_free()


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
