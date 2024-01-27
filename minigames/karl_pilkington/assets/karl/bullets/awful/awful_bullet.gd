extends BulletBase

func _ready():
	damage = global.rng.randf_range(0.05, 0.15)
	var leScale = global.rng.randf_range(1,1.5)
	scale = Vector2(leScale, leScale)
	super()
