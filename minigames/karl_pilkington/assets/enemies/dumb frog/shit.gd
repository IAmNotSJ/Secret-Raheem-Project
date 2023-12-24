extends Sprite2D

@onready var smallShitScene = preload("res://minigames/karl_pilkington/assets/enemies/dumb frog/shit_small.tscn")

const rotation_speed = 50
const firing_speed = 600

var final_pos

func _process(delta):
	rotation_degrees += rotation_speed * delta
	position = position.move_toward(final_pos, delta * firing_speed)
	
	if position == final_pos:
		destroy()

func destroy():
	for i in range(4):
		var shit = smallShitScene.instantiate()
		shit.global_position = global_position
		shit.direction = i * 90
		get_tree().root.get_node("KarlPilkington").call_deferred("add_child", shit)
	queue_free()


func _on_area_2d_area_entered(area):
	area.owner.hit()
	destroy()


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
