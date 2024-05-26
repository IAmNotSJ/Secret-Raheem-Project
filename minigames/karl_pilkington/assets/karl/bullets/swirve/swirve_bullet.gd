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
	
	rotation -= deg_to_rad(45) * delta * 2
	
	velocity.x = bullet_speed * cos(rotation)
	velocity.y = bullet_speed * sin(rotation)
	super(delta)

func _on_visible_on_screen_notifier_2d_screen_exited():
	pass
