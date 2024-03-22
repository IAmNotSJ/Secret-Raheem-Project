extends EnemyBullet

@onready var puddleScene = preload("res://minigames/karl_pilkington/assets/enemies/dumb frog/slime/puddle.tscn")

func _process(delta):
	super(delta)
	if (position == final_pos):
		spawn_puddle()

func spawn_puddle():
	if is_instance_valid(global.sceneManager.get_node("Pilkington").get_node("KarlPilkington").get_node("Cleft")):
		var puddle = puddleScene.instantiate()
		puddle.global_position = global_position
		global.sceneManager.get_node("Pilkington").get_node("KarlPilkington").call_deferred("add_child", puddle)
		global.sceneManager.get_node("Pilkington").get_node("KarlPilkington").get_node("Cleft").killOnDeath.append(puddle)
	
	queue_free()

func destroy():
	spawn_puddle()
