extends PilkingtonBase

func _ready():
	bullet_scene = load("res://minigames/karl_pilkington/assets/karl/bullets/awful/awful_bullet.tscn")

func _physics_process(delta):
	cooldown_timer -= delta
	
	if input_vector != Vector2.ZERO:
		velocity = input_vector * walk_speed
	else:
		velocity = Vector2.ZERO
	
	#Why wasn't this working in unhandled input? le fuck?
	#update: i am stupid
	if bullet_timer > 0:
		bullet_timer -= delta
		
	if bullet_timer <= 0:
		if Input.is_action_pressed('click'):
			shoot()
			bullet_timer = max_bullet_timer
	
	rotation = lerp(rotation, intended_angle, 0.4)
	move_and_slide()
	
	position.x = clamp(position.x, 0, 1280)
	position.y = clamp(position.y, 0, 720)

func shoot():
	var bullet = bullet_scene.instantiate()
	var dir = get_global_mouse_position() - global_position
	bullet.start(position, dir.angle() + global.rng.randf_range(deg_to_rad(-10), deg_to_rad(10)))
	get_tree().root.get_node("Pilkington").get_node("KarlPilkington").add_child(bullet)
	playShootSound()
