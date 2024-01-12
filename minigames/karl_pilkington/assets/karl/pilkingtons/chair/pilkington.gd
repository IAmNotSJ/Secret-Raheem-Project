extends PilkingtonBase

func _ready():
	bullet_scene = load("res://minigames/karl_pilkington/assets/karl/bullets/swirve/swirve_bullet.tscn")
func shoot():
	for i in range(4):
		var bullet = bullet_scene.instantiate()
		var dir = get_global_mouse_position() - global_position
		bullet.start(position, dir.angle())
		bullet.rotation += deg_to_rad(90 * i)
		get_tree().root.get_node("KarlPilkington").add_child(bullet)
