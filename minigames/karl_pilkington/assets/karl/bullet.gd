extends CharacterBody2D

var bullet_speed:int = 600

func start(_position, _direction):
	position = _position
	rotation = _direction
	velocity = Vector2(bullet_speed, 0).rotated(rotation)

func _physics_process(delta):
	move_and_collide(velocity*delta)

func _on_area_2d_area_entered(_area):
	queue_free()


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
