class_name PilkingtonBase extends CharacterBody2D

signal hurt

var walk_speed = 350
const max_bullet_timer = 1
const max_timer_disappear_timer = 1
const max_cooldown = 1.5

var input_vector:Vector2 = Vector2.ZERO
var intended_angle:float = 0

var bullet_scene = preload("res://minigames/karl_pilkington/assets/karl/bullets/standard/basic_bullet.tscn")

var bullet_timer = max_bullet_timer

var cooldown_timer = max_cooldown
var timer_disappear_timer = max_timer_disappear_timer

var health = 5

func initialize():
	pass

func _unhandled_input(_event):
	input_vector = Vector2.ZERO
	intended_angle = 0
		
	input_vector.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	input_vector.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	
	if input_vector.x == 1:
		intended_angle = 0.25
	elif input_vector.x == -1:
		intended_angle = -0.25
	
	if input_vector != Vector2.ZERO:
		$AnimationPlayer.play("run")
	else:
		$AnimationPlayer.play("idle")

func _physics_process(delta):
	cooldown_timer -= delta
	
	if input_vector != Vector2.ZERO:
		velocity = input_vector * walk_speed
	else:
		velocity = Vector2.ZERO
	
	#Why wasn't this working in unhandled input? le fuck?
	if bullet_timer > 0:
		bullet_timer -= delta
		$TextureProgressBar.value = (max_bullet_timer - bullet_timer) * 100
		
	if bullet_timer <= 0:
		timer_disappear_timer -= delta
		if timer_disappear_timer <= 0:
			$TextureProgressBar.modulate.a -= delta
		if Input.is_action_pressed('click'):
			timer_disappear_timer = max_timer_disappear_timer
			$TextureProgressBar.modulate.a = 1
			shoot()
			bullet_timer = max_bullet_timer
	
	rotation = lerp(rotation, intended_angle, 0.4)
	move_and_slide()
	
	position.x = clamp(position.x, 0, 1280)
	position.y = clamp(position.y, 0, 720)
	

func shoot():
	var bullet = bullet_scene.instantiate()
	var dir = get_global_mouse_position() - global_position
	bullet.start(position, dir.angle())
	get_tree().root.get_node("KarlPilkington").add_child(bullet)

func hit():
	if (cooldown_timer <= 0):
		health -= 1
		hurt.emit()
		cooldown_timer = max_cooldown
