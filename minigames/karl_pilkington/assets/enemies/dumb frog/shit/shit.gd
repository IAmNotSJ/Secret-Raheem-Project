extends EnemyBullet

@onready var smallShitScene = preload("res://minigames/karl_pilkington/assets/enemies/dumb frog/shit/shit_small.tscn")

const rotation_speed = 50

func _process(delta):
	rotation_degrees += rotation_speed * delta
	super(delta)
	
	if position == final_pos:
		destroy()

func destroy():
	for i in range(4):
		var shit = smallShitScene.instantiate()
		shit.global_position = global_position
		shit.angle = i * 90
		global.sceneManager.get_node("Pilkington").get_node("KarlPilkington").call_deferred("add_child", shit)
	super()
