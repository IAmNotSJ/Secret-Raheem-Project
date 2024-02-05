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

var fakeBoost:bool

func _process(delta):
	if active:
		match state:
			IDLE:
				look_at_target(target, pupil, marker)
				if mainScene.boosted:
					attackTimer -= delta * 5
				else:
					attackTimer -= delta
				if attackTimer <= 0:
					attackTimer = ATTACK_TIMER
					state = SPIN
					$Animationplayer.play('spin')
					spin_timer = global.rng.randi_range(2, 7)
			SPIN:
				spin_timer -= delta
				look_at_target(target, pupil, marker)
				if spin_timer <= 0:
					state = DASH
					angleToPlayer = angleToTarget(target, marker)
			DASH:
				var boostModifier:int = 1
				if mainScene.boosted:
					boostModifier = 2
				velocity.x += SPEED * boostModifier * cos(angleToPlayer) * delta
				velocity.y += SPEED * boostModifier * sin(angleToPlayer) * delta
				
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

func _on_hurtbox_area_entered(area):
	hit_target(area)
