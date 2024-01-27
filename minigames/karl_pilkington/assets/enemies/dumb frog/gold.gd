extends Sprite2D

const SPEED = 300
var angle:float = 0

func initialize(daAngle:float):
	angle = daAngle

func _process(delta):
	position.x += SPEED * cos(angle) * delta
	position.y += SPEED * sin(angle) * delta

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()


func _on_area_2d_area_entered(area):
	area.owner.hit()
	queue_free()
