extends EnemyBase

@onready var shootingMarker = $ShootingMarker

const bulletScene = preload("res://minigames/karl_pilkington/assets/enemies/carl pilkington/bullet/bullet.tscn")

enum {
	IDLE,
	AVOID
}

var precision:float = 0.3

const max_attack_timer = 15
var attack_Timer = max_attack_timer

const max_shooting_timer = 0.2
var shooting_timer = max_shooting_timer

func _process(delta):
	shooting_timer -= delta
	if shooting_timer <= 0:
		shooting_timer = max_shooting_timer
		shoot()

func shoot():
	var degToPilk:float = 0
	spawn_bullet(bulletScene.instantiate(), shootingMarker.global_position, degToPilk)
