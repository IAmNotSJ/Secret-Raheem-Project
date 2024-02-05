extends EnemyBase

@onready var miniKeyScene = preload("res://minigames/karl_pilkington/assets/enemies/dumb frog/mini/mini_key.tscn")
@onready var shitScene = preload("res://minigames/karl_pilkington/assets/enemies/dumb frog/shit/shit.tscn")
@onready var slimeScene = preload("res://minigames/karl_pilkington/assets/enemies/dumb frog/slime/slimeball.tscn")
@onready var goldScene = preload("res://minigames/karl_pilkington/assets/enemies/dumb frog/gold/gold.tscn")

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
	spawn_mini()
	

func die():
	$AnimationPlayer.play("dead")
	super()

func spawn_mini():
	var daMini = miniKeyScene.instantiate()
	spawn_entity(daMini, $Marker2D.global_position, true)

func shoot_shit():
	var shit = shitScene.instantiate()
	spawn_entity(shit, $Marker2D.global_position, false)
	shit.final_pos = get_shoot_position(false)

func shoot_slime():
	var slime = slimeScene.instantiate()
	spawn_entity(slime, $Marker2D.global_position, false)
	slime.final_pos = get_shoot_position()

func goldsplode():
	for i in range(14):
		var bullet = goldScene.instantiate()
		spawn_entity(bullet, $Marker2D.global_position, false)
		bullet.angle = i * (360/ 14)

func get_shoot_position(direct:bool = false):
	var player_pos = target.position
	if (direct):
		player_pos += (target.velocity / rng.randf_range(1.5, 2.5))
	return player_pos
