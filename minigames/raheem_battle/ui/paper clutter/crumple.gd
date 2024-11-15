extends RigidBody2D

func _ready():
	var rand = randf_range(0.8, 1.2)
	$Sprite.scale = Vector2(rand, rand)
	$Collision.scale = Vector2(rand, rand)


func _on_sleeping_state_changed():
	print('Paper sleeping state Changed')
