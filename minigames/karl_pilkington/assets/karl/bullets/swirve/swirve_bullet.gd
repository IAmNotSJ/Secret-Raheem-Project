extends BulletBase

var delete_timer:float = 5

func start(_position, _direction, _damage):
	type = SWIRVE
	super(_position, _direction, _damage)


func _physics_process(delta):
	delete_timer -= delta
	if delete_timer <= 0:
		queue_free()
	rotation_degrees += 60 * delta
	#bullet_speed += delta * 80
	position.x += bullet_speed * cos(rotation - deg_to_rad(30)) * delta
	position.y += bullet_speed * sin(rotation - deg_to_rad(30)) * delta

func _on_visible_on_screen_notifier_2d_screen_exited():
	pass
