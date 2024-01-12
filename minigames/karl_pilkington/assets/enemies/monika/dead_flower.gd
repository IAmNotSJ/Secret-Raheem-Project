extends Sprite2D

const bulletScene = preload("res://minigames/karl_pilkington/assets/enemies/monika/spore.tscn")

const rotation_speed = 50
const SPEED = 70
var targetPos:Vector2

var rng = RandomNumberGenerator.new()

func _process(delta):
	rotation_degrees += rotation_speed * delta
	global_position = global_position.move_toward(targetPos, SPEED * delta)
	
	if global_position == targetPos:
		explode()
		queue_free()

func explode():
	var leRange = rng.randi_range(20, 25)
	var angleDistance = (360 / (leRange - 1))
	for i in range(leRange):
		var bullet = bulletScene.instantiate()
		bullet.angle = i * (angleDistance)
		bullet.global_position = global_position
		get_tree().root.get_node("KarlPilkington").call_deferred("add_child", bullet)
