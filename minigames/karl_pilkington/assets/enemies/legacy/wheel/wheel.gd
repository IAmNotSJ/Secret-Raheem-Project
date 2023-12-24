extends LegacyMember

@onready var pupil = $Pupil
@onready var marker = $Marker2D

enum {
	IDLE,
	SPIN,
	DASH,
	COOLDOWN
}

var state = IDLE

var angleToPlayer
var spin_timer

const DASH_TIMER = 1
var dash_timer = DASH_TIMER

const FRICTION = 300

func _process(delta):
	if active:
		match state:
			IDLE:
				look_at_target(target, pupil, marker)
				attackTimer -= delta
				if attackTimer <= 0:
					attackTimer = ATTACK_TIMER
					state = SPIN
					$Animationplayer.play('spin')
					spin_timer = rng.randi_range(2, 7)
			SPIN:
				spin_timer -= delta
				look_at_target(target, pupil, marker)
				if spin_timer <= 0:
					state = DASH
					angleToPlayer = angleToTarget(target, marker)
			DASH:
				velocity.x += SPEED * cos(angleToPlayer) * delta
				velocity.y += SPEED * sin(angleToPlayer) * delta
				
				move_and_slide()
				
				position.x = clamp(position.x, 0, 1280)
				position.y = clamp(position.y, 0, 720)
				
				dash_timer -= delta
				if dash_timer <= 0:
					print('dash done')
					dash_timer = DASH_TIMER
					state = COOLDOWN
					$Animationplayer.stop()
			COOLDOWN:
				#velocity.x = move_toward(velocity.x, 0, delta * FRICTION)
				#velocity.y = move_toward(velocity.y, 0, delta * FRICTION)
				
				velocity = velocity.move_toward(Vector2.ZERO, delta * FRICTION)
				
				move_and_slide()
				
				position.x = clamp(position.x, 0, 1280)
				position.y = clamp(position.y, 0, 720)
				
				if velocity == Vector2.ZERO:
					state = IDLE
			

func _on_hitbox_area_entered(_area):
	if active:
		hurt()
		$EffectsPlayer.play('hurt')


func _on_hurtbox_area_entered(area):
	area.owner.hit()
