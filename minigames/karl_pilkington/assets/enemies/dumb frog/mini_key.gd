extends CharacterBody2D

const HOP_SPEED = 400

enum {
	IDLE,
	JUMP
}

var target
var target_position

var state = IDLE
var stateTimer = 5

func _physics_process(delta):
	velocity = velocity.move_toward(Vector2.ZERO, delta * 20)
	move_and_slide()
	
func idle_state():
	velocity = Vector2.ZERO
func jump_state():
	target_position = (target.position - position).normalized()
	velocity = target_position * HOP_SPEED

func _on_hurtbox_area_entered(area):
	print("BAM")
	area.owner.hit()
