extends Sprite2D

const bulletScene = preload("res://minigames/karl_pilkington/assets/enemies/monika/bullet/bullet.tscn")

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
	var angleDistance = 14.4
	for i in range(25):
		var bullet = bulletScene.instantiate()
		bullet.angle = i * (angleDistance)
		bullet.global_position = global_position
		global.sceneManager.get_node("Pilkington").get_node("KarlPilkington").call_deferred("add_child", bullet)
