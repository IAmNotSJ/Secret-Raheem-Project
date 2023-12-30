class_name BasicBullet extends Sprite2D

var SPEED = 400

var angle

func initialize(daAngle, tex, speed):
	texture = tex
	angle = daAngle
	SPEED = speed

func _physics_process(delta):
	position.x += SPEED * cos(angle) * delta
	position.y += SPEED * sin(angle) * delta


func _on_area_2d_area_entered(area):
	area.owner.hit()
	queue_free()


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
