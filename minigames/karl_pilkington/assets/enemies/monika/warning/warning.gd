extends EnemyAttack

const MAX_WARN_TIMER = 1
var warn_timer = MAX_WARN_TIMER

enum {
	WARN,
	ATTACK
}
var state = WARN

func _process(delta):
	match state:
		WARN:
			warn_timer -= delta
			if warn_timer <= 0:
				$AnimationPlayer.play('attack')
				state = ATTACK
				z_index = 0
		ATTACK:
			if !$AnimationPlayer.is_playing():
				queue_free()
	super(delta)
