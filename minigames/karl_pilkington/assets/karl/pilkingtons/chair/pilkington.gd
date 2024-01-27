extends PilkingtonBase

func _ready():
	bullet_scene = load("res://minigames/karl_pilkington/assets/karl/bullets/swirve/swirve_bullet.tscn")

func _unhandled_input(_event):
	input_vector = Vector2.ZERO
	intended_angle = 0
	if health != 0:
			
		input_vector.x = Input.get_action_strength("right") - Input.get_action_strength("left")
		input_vector.y = Input.get_action_strength("down") - Input.get_action_strength("up")
		
		if input_vector.x == 1:
			intended_angle = 0.25
		elif input_vector.x == -1:
			intended_angle = -0.25

func shoot():
	for i in range(4):
		var bullet = bullet_scene.instantiate()
		var dir = get_global_mouse_position() - global_position
		bullet.start(position, dir.angle())
		bullet.rotation += deg_to_rad(90 * i)
		get_tree().root.get_node("Pilkington").get_node("KarlPilkington").add_child(bullet)
	playShootSound()
