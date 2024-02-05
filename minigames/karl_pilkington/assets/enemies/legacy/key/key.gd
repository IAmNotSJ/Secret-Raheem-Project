extends LegacyMember

@onready var pupil = $Pupil
@onready var marker = $Marker2D

@onready var bulletScene = preload("res://minigames/karl_pilkington/assets/enemies/legacy/basic_bullet.tscn")
@onready var bulletTexture = preload("res://minigames/karl_pilkington/assets/enemies/legacy/key/bullet.png")

var SHOOT_TIMER = 0.25
var shootTimer = SHOOT_TIMER
var shots = 5

var pos = Vector2(662, 91)

func _process(delta):
	if active:
		global_position = global_position.move_toward(pos, delta * SPEED)
		look_at_target(target, pupil, marker)
		attackTimer -= delta
		if attackTimer <= 0:
			shootTimer -= delta
			if shootTimer <= 0:
				shootTimer = SHOOT_TIMER
				shoot()
				shots -= 1
				if !shots > 0:
					attackTimer = ATTACK_TIMER
					if mainScene.boosted:
						shots = 8
					else:
						shots = 5

func shoot():
	var bullet = bulletScene.instantiate()
	bullet.global_position = pupil.global_position
	var angleTo = angleToTarget(target, marker)
	bullet.start(rad_to_deg(angleTo), bulletTexture, 600)
	mainScene.call_deferred("add_child", bullet)
