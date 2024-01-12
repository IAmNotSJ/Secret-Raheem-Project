extends Node2D

@onready var scene = load("res://world/apartment_props.tscn")

@onready var wibr = get_tree().get_root().get_node("Apartment").get_node("Wibr")

func _on_area_2d_area_exited(area):
	print("BITCH!")
	var props = scene.instantiate()
	var offset = Vector2()
	offset += Vector2(-750, -300)
	offset += Vector2(wibr.velocity * 3)
	props.global_position = area.owner.global_position + offset
	get_tree().get_root().get_node("Apartment").call_deferred("add_child", props)
	queue_free()
