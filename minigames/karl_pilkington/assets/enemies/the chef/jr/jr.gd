extends EnemyAttack

const walk_speed = 100
const running_speed = 600
enum {
	MOVE,
	WINDUP,
	CHARGE,
	GOBACK
}

var state = MOVE

const max_patience = 1
var patience:float = max_patience

func _process(delta):
	match state:
		MOVE:
			if position.y <= 80:
				velocity.y = walk_speed
			if position.y >= 640:
				velocity.y = -walk_speed
			move_and_slide(delta)
			if $Sight.has_overlapping_areas():
				patience -= delta
				if patience <= 0:
					state = WINDUP
					$AnimationPlayer.play("wind_up")
		WINDUP:
			if !$AnimationPlayer.is_playing():
				state = CHARGE
				velocity.y = 0
				velocity.x = running_speed
				$AnimationPlayer.play("charge")
		CHARGE:
			move_and_slide(delta)
			if position.x >= 1200:
				state = GOBACK
				velocity.x = -walk_speed * 3
		GOBACK:
			move_and_slide(delta)
			if position.x <= 55:
				state = MOVE
				velocity.x = 0
				$AnimationPlayer.play("idle")
				patience = max_patience
				velocity.y = walk_speed
	super(delta)
