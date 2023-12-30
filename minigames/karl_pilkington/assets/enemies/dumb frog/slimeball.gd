extends Sprite2D

@onready var puddleScene = preload("res://minigames/karl_pilkington/assets/enemies/dumb frog/puddle.tscn")

const firing_speed = 400

var rng = RandomNumberGenerator.new()

var final_pos

func _process(delta):
	position = position.move_toward(final_pos, delta * firing_speed)
	
	if (position == final_pos):
		spawn_puddle()

func spawn_puddle():
	if is_instance_valid(get_tree().get_root().get_node("KarlPilkington").get_node("Cleft")):
		var puddle = puddleScene.instantiate()
		puddle.global_position = global_position
		get_tree().get_root().get_node("KarlPilkington").call_deferred("add_child", puddle)
		get_tree().get_root().get_node("KarlPilkington").get_node("Cleft").killOnDeath.append(puddle)
	
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	spawn_puddle()

func _on_area_2d_area_entered(_area):
	spawn_puddle()
