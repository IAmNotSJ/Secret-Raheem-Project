extends EnemyBullet


var spin = false
const MAX_SPIN_TIMER = 2
var spin_timer = MAX_SPIN_TIMER

func _process(delta):
	rotation_degrees += 200 * delta
	if !moving:
		spin_timer -= delta
		if spin_timer <= 0:
			moving = true
	super(delta)
