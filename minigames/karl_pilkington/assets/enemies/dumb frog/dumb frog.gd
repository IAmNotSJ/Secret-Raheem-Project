extends EnemyBase

@onready var miniKeyScene = preload("res://minigames/karl_pilkington/assets/enemies/dumb frog/mini_key.tscn")
@onready var waftScene = preload("res://minigames/karl_pilkington/assets/enemies/dumb frog/waft_wall.tscn")
@onready var shitScene = preload("res://minigames/karl_pilkington/assets/enemies/dumb frog/shit.tscn")
@onready var slimeScene = preload("res://minigames/karl_pilkington/assets/enemies/dumb frog/slimeball.tscn")
@onready var goldScene = preload("res://minigames/karl_pilkington/assets/enemies/dumb frog/gold.tscn")

@onready var gameAnims = $GameAnims

var shooting_timer
var slime_timer

var hitcount:int = 0
var hitCounts = [
14,
7,
0
]

func _ready():
	shooting_timer = rng.randf_range(5, 17)
	slime_timer = rng.randf_range(2, 5)
	gameAnims.play('intro')
	super()

func _process(delta):
	shooting_timer -= delta
	if shooting_timer <= 0:
		shooting_timer = rng.randf_range(5, 9)
		shoot_shit()
	slime_timer -= delta
	if slime_timer <= 0:
		slime_timer = rng.randf_range(5, 9)
		shoot_slime()

func hurt(damage):
	$AnimationPlayer.play("hurt")
	super(damage)
	if health <= hitCounts[hitcount]:
		goldsplode()
		hitcount += 1
	spawn_frog()
	

func die():
	$AnimationPlayer.play("dead")
	super()

func spawn_frog():
	var key = miniKeyScene.instantiate()
	key.target = target
	killOnDeath.append(key)
	key.global_position = $Marker2D.global_position
	get_tree().get_root().get_node("Pilkington").get_node("KarlPilkington").call_deferred("add_child", key)

func shoot_shit():
	var shit = shitScene.instantiate()
	shit.global_position = $Marker2D.global_position
	shit.final_pos = get_shoot_position(false)
	get_tree().root.get_node("Pilkington").get_node("KarlPilkington").call_deferred("add_child", shit)

func shoot_slime():
	var slime = slimeScene.instantiate()
	slime.global_position = $Marker2D.global_position
	slime.final_pos = get_shoot_position()
	get_tree().root.get_node("Pilkington").get_node("KarlPilkington").call_deferred("add_child", slime)

func goldsplode():
	for i in range(14):
		var bullet = goldScene.instantiate()
		bullet.angle = i * (360/ (14-1))
		bullet.global_position = global_position
		get_tree().root.get_node("Pilkington").get_node("KarlPilkington").call_deferred("add_child", bullet)

func get_shoot_position(direct:bool = false):
	var player_pos = target.position
	if (direct):
		player_pos += (target.velocity / rng.randf_range(1.5, 2.5))
	return player_pos
