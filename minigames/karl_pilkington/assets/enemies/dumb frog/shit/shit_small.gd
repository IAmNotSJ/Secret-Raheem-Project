extends EnemyBullet

const rotation_speed = 50

var direction:int = 0

func _process(delta):
	super(delta)
	rotation_degrees += rotation_speed * delta
