extends Sprite2D

const FIRING_SPEED = 600
var angle

func start(daAngle:float):
	angle = daAngle

func _physics_process(delta):
	position.x += FIRING_SPEED * cos(deg_to_rad(angle)) * delta
	position.y += FIRING_SPEED * sin(deg_to_rad(angle)) * delta

func _on_area_2d_area_entered(area):
	queue_free()
	area.owner.hit()


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()


