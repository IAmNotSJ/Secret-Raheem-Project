extends EnemyAttack

@onready var vineArray = [$Flumpvine, $Flumpvine2]

var direction = 1

const max_direction_timer = Vector2(3, 9)
var direction_timer = global.rng.randf_range(max_direction_timer.x, max_direction_timer.y)

func _process(delta):
	direction_timer -= delta
	if direction_timer <= 0:
		direction_timer = global.rng.randf_range(max_direction_timer.x, max_direction_timer.y)
		direction *= -1
	for i in vineArray.size():
		vineArray[i].rotation_degrees += 50 * delta * direction
	super(delta)
