class_name PilkingtonBase extends CharacterBody2D

signal hurt
signal heal

@onready var parent  = global.sceneManager.get_node("Pilkington")
@onready var center = $Center

@export_category("Players")

@export var effectPlayer:AnimationPlayer
@export var hurtPlayer:AudioStreamPlayer
@export var shootPlayer:AudioStreamPlayer
@export_category("Stats")
@export var walk_speed:int = 350
@export var max_bullet_timer:float = 1
@export var tears_per_shot:int = 1
@export_category("Options")
@export var walk_anim:bool = true
@export var has_special:bool = false
@export var include_bar:bool = true : 
	set(value) : 
		$TextureProgressBar.visible = value

var spritePath = "res://minigames/karl_pilkington/assets/karl/pilkingtons/sprites/standard/sprites.tscn"
var sprites

const max_timer_disappear_timer = 1
const max_cooldown = 1.5
var canShoot:bool = true

const fartScene = preload("res://minigames/karl_pilkington/assets/items/garlic/cloud.tscn")
const max_fart_timer = 10
var fart_timer = 0

var items:Dictionary = {
	"Awful" : false,
	"Chair" : false,
	"Coin" : false,
	"Garlic" : false,
	"Mini" : false,
	"Shield" : false,
	"Weed" : false
}

var stats:Dictionary = {
	"Attack" : 1,
	"Speed" : 1,
	"Size" : 1,
}
var upgrades = []

var input_vector:Vector2 = Vector2.ZERO
var intended_angle:float = 0

var bullet_scene = preload("res://minigames/karl_pilkington/assets/karl/bullets/standard/basic_bullet.tscn")

var bullet_timer = max_bullet_timer

var cooldown_timer = max_cooldown
var timer_disappear_timer = max_timer_disappear_timer

var health = 5

func initialize():
	pass

func _input(event):
	input_vector = Vector2.ZERO
	intended_angle = 0
	if health != 0:
		input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
		
		if input_vector.x == 1:
			intended_angle = 0.25
		elif input_vector.x == -1:
			intended_angle = -0.25
		
		if walk_anim:
			if input_vector != Vector2.ZERO:
				sprites.animationPlayer.play("run")
			else:
				sprites.animationPlayer.play("idle")
		
		if Input.is_action_just_pressed("karl_special"):
			if items["Garlic"]:
				spawn_fart()
	if event is InputEventMouseMotion:
		parent.get_node("KarlPilkington").crosshair.global_position = get_global_mouse_position()
func _physics_process(delta):
	cooldown_timer -= delta
	if items["Garlic"]:
		fart_timer -= delta
	
	if input_vector != Vector2.ZERO:
		velocity = input_vector * walk_speed * stats["Speed"]
	else:
		velocity = Vector2.ZERO
	
	if bullet_timer > 0:
		bullet_timer -= delta
		$TextureProgressBar.value = (max_bullet_timer - bullet_timer) * 100
		
	if bullet_timer <= 0 and canShoot:
		timer_disappear_timer -= delta
		if timer_disappear_timer <= 0:
			$TextureProgressBar.modulate.a -= delta
		if Input.is_action_pressed('click'):
			timer_disappear_timer = max_timer_disappear_timer
			$TextureProgressBar.modulate.a = 1
			shoot(tears_per_shot)
			bullet_timer = max_bullet_timer
	
	rotation = lerp(rotation, intended_angle, 0.4)
	move_and_slide()
	
	position.x = clamp(position.x, 0, 1280)
	position.y = clamp(position.y, 0, 720)

func shoot(amount):
	for i in range(amount):
		var bullet = bullet_scene.instantiate()
		var angle = (get_global_mouse_position() - global_position).angle()
		if items["Awful"]:
			angle += global.rng.randf_range(deg_to_rad(-10), deg_to_rad(10))
		if items["Chair"]:
			angle += deg_to_rad(90 * i)
		bullet.start(position, angle, stats["Attack"])
		parent.get_node("KarlPilkington").crosshair.animationPlayer.play('shoot')
		global.sceneManager.get_node("Pilkington").get_node("KarlPilkington").add_child(bullet)
	playShootSound()

func hit():
	if (cooldown_timer <= 0):
		health -= 1
		if health != 0:
			effectPlayer.play('hit')
		hurt.emit()
		playHurtSound()
		cooldown_timer = max_cooldown
	if health == 0:
		sprites.animationPlayer.play('dead')
		await sprites.animationPlayer.animation_finished
		parent.changeScene("res://minigames/karl_pilkington/gameover/game_over.tscn", false)

func add_health(amount):
	health += amount
	heal.emit()

func add_upgrade(upgrade):
	match upgrade.state:
		"HEALTH":
			add_health(1)
		"SPEED":
			stats["Speed"] += 0.3
		"ATTACK":
			stats["Attack"] += 0.5
		"SIZE":
			scale -= Vector2(0.3, 0.3)
	if upgrade.cooldown > 0:
		var timer = Timer.new()
		timer.wait_time = upgrade.cooldown
		timer.one_shot = true
		timer.autostart = true
		parent.add_child(timer)
		upgrades.append(upgrade)
		timer.timeout.connect(remove_upgrade.bind(timer))
	print(upgrades)

func remove_upgrade(daTimer):
	print('timer out!')
	var upgrade = upgrades[0]
	match upgrade.state:
		"SPEED":
			stats["Speed"] -= 0.3
		"ATTACK":
			stats["Attack"] -= 0.5
		"SIZE":
			scale += Vector2(0.3, 0.3)
	upgrades.erase(upgrade)
	upgrade.queue_free()
	daTimer.queue_free()

func spawn_fart():
	if fart_timer <= 0:
		fart_timer = max_fart_timer
		var fart = fartScene.instantiate()
		fart.global_position = global_position
		global.sceneManager.get_node("Pilkington").get_node("KarlPilkington").add_child(fart)

func playHurtSound():
	hurtPlayer.stream = load("res://minigames/karl_pilkington/sounds/karlsounds/augh" + str(global.rng.randi_range(1,5)) + ".ogg")
	hurtPlayer.play()
func playShootSound():
	shootPlayer.play()

func add_item(path):
	var item = load(path).instantiate()
	add_child(item)
	if item.sprites != " ":
		spritePath = item.sprites
	print(spritePath)
	change_sprites(spritePath)
	
	items[item.name] = true

func change_sprites(path):
	var sprite = load(path).instantiate()
	add_child(sprite)
	sprites = sprite
