extends BulletBase

const MAX_CHANGE_TIMER = 0.3
var change_timer = MAX_CHANGE_TIMER


func _physics_process(delta):
	change_timer -= delta
	if change_timer <= 0:
		change_timer = MAX_CHANGE_TIMER
		change_scale()
	super(delta)

func change_scale():
	var leScale = global.rng.randf_range(0, 2)
	scale = Vector2(leScale * 1.2, leScale * 1.2)
	damage = leScale 
