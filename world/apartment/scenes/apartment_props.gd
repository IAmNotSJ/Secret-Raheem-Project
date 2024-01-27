extends Node2D

@onready var scene = load("res://world/apartment/scenes/apartment_props.tscn")

@onready var wibr = get_tree().get_root().get_node("Apartment").get_node("Wibr")

func _ready():
	if global.tpTimes != 6 or global.items["Key"]:
		$Key.queue_free()
func _on_area_2d_area_exited(area):
	print("BITCH!")
	var props = scene.instantiate()
	var offset = Vector2()
	offset += Vector2(-750, -300)
	offset += Vector2(wibr.velocity * 3)
	props.global_position = area.owner.global_position + offset
	get_tree().get_root().get_node("Apartment").call_deferred("add_child", props)
	global.costTeleported = true
	global.tpTimes += 1
	if global.tpTimes > 6:
		global.tpTimes = 1
	queue_free()

func _on_dialogue_interacted():
	print('what')
	$Key.queue_free()
