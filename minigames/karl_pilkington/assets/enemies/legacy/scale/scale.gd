extends LegacyMember

@onready var animationPlayer = $CanvasGroup/AnimationPlayer
enum {
	IDLE,
	CHARGE,
	RETRACT
}
var state = IDLE

const max_patience = 3
var patience = max_patience

const max_wait = 3
var wait_timer = max_wait

var fakeBoost:bool

func _ready():
	reset()
	super()
func _process(delta):
	if active:
		match state:
			IDLE:
				print(patience)
				if mainScene.boosted:
					patience -= delta * 2.5
				else:
					patience -= delta
				if patience <= 0:
					position.y = target.position.y - 55
					patience = max_patience
					animationPlayer.play('shoot')
					state = CHARGE
			CHARGE:
				if !animationPlayer.is_playing():
					wait_timer -= delta
				if wait_timer <= 0:
					animationPlayer.play('retract')
					state = RETRACT
			RETRACT:
				if !animationPlayer.is_playing():
					wait_timer = max_wait
					state = IDLE
					reset()

func reset():
	animationPlayer.play('idle')
	var rand = rng.randi_range(0,1)
	if rand == 0:
		position.x = 1280
		scale.x = -1
	else:
		position.x = 0
		scale.x = 1

func change_boost(val):
	if val:
		animationPlayer.speed_scale = 2.5
	else:
		animationPlayer.speed_scale = 1

func _on_hurtbox_area_entered(area):
	hit_target(area)
