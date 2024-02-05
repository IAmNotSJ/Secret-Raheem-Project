extends EnemyAttack

const HOP_SPEED = 400

enum {
	IDLE,
	JUMP
}
var state = IDLE

var target
var target_position

func _physics_process(delta):
	velocity = velocity.move_toward(Vector2.ZERO, delta * 20)
	move_and_slide(delta)

func idle_state():
	velocity = Vector2.ZERO
func jump_state():
	target_position = (target.position - position).normalized()
	velocity = target_position * HOP_SPEED
